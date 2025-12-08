/*
Author: HERRERA D., LEUNG V., ARAVAI S.
Course: DATA2201 Relational Databases
Date: December 12, 2025
Project Name: SKS National Bank
Instructor: Michael Dorsey
*/

USE SKS_BANK_DB;
GO

--============================================================ HELPER & TEST CASES STORED PROCEDURES ============================================================

-- Create login, user, and role
CREATE OR ALTER PROCEDURE CreateLoginUserRole
    @Login NVARCHAR(128),
    @Password NVARCHAR(128),
    @Role NVARCHAR(128)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    -- Drop existing user, login, and role if they exist
    IF EXISTS (SELECT * FROM sys.database_principals WHERE name = @Login)
    BEGIN
        SET @sql = 'DROP USER ' + QUOTENAME(@Login) + ';';
        EXEC (@sql);
    END;

    IF EXISTS (SELECT * FROM sys.server_principals WHERE name = @Login)
    BEGIN
        SET @sql = 'DROP LOGIN ' + QUOTENAME(@Login) + ';';
        EXEC (@sql);
    END;

    IF EXISTS (SELECT * FROM sys.database_principals WHERE name = @Role AND type = 'R')
    BEGIN
        SET @sql = 'DROP ROLE ' + QUOTENAME(@Role) + ';';
        EXEC (@sql);
    END;

    -- Create new login, user, and role
    SET @sql = 'CREATE LOGIN ' + QUOTENAME(@Login) + ' WITH PASSWORD = ''' + @Password + ''';';
    EXEC (@sql);

    SET @sql = 'CREATE USER ' + QUOTENAME(@Login) + ' FOR LOGIN ' + QUOTENAME(@Login) + ';';
    EXEC (@sql);

    SET @sql = 'CREATE ROLE ' + QUOTENAME(@Role) + ';';
    EXEC (@sql);

    SET @sql = 'ALTER ROLE ' + QUOTENAME(@Role) + ' ADD MEMBER ' + QUOTENAME(@Login) + ';';
    EXEC (@sql);
END;
GO

-- Apply permission 
CREATE OR ALTER PROCEDURE ApplyPermissions
    @Role NVARCHAR(128),
    @Tables NVARCHAR(MAX),
    @GrantOrDeny NVARCHAR(10), -- 'GRANT', 'DENY', or 'REVOKE'
    @Permissions NVARCHAR(MAX)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX), @table NVARCHAR(128);
    DECLARE cur CURSOR FOR SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@Tables, ',');

    OPEN cur;
    FETCH NEXT FROM cur INTO @table;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF UPPER(@GrantOrDeny) = 'REVOKE'
            SET @sql = 'REVOKE ' + @Permissions + ' ON dbo.' + QUOTENAME(@table) + ' FROM ' + QUOTENAME(@Role) + ';';
        ELSE
            SET @sql = @GrantOrDeny + ' ' + @Permissions + ' ON dbo.' + QUOTENAME(@table) + ' TO ' + QUOTENAME(@Role) + ';';

        EXEC (@sql);

        FETCH NEXT FROM cur INTO @table;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

-- Generic permission test
CREATE OR ALTER PROCEDURE TestPermission
    @Action NVARCHAR(10),
    @Table NVARCHAR(128),
    @Clause NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    BEGIN TRY
        IF @Action = 'SELECT'
            SET @sql = 'SELECT TOP 5 * FROM dbo.' + QUOTENAME(@Table) + ';';
        ELSE IF @Action = 'INSERT'
            SET @sql = 'INSERT INTO dbo.' + QUOTENAME(@Table) + ' ' + @Clause + ';';
        ELSE IF @Action = 'UPDATE'
           SET @sql = 'UPDATE dbo.' + QUOTENAME(@Table) + ' SET ' + @Clause + ';';
        ELSE IF @Action = 'DELETE'
            SET @sql = 'DELETE FROM dbo.' + QUOTENAME(@Table) + ' ' + @Clause + ';';
        ELSE
            THROW 50001, 'Invalid action type.', 1;

        EXEC sp_executesql @sql;

        PRINT @Action + ' on ' + @Table + ' SUCCEEDED.';
    END TRY
    BEGIN CATCH
        PRINT @Action + ' on ' + @Table + ' DENIED as expected.';
    END CATCH
END;
GO

-- Customer positive test case scenario
CREATE OR ALTER PROCEDURE RunCustomerPositiveTestCase
    @UserName NVARCHAR(128)
AS
BEGIN
    EXEC AS USER = @UserName;

    PRINT '--- Customer should have SELECT access on allowed tables ---';

    EXEC TestPermission 'SELECT', 'Customer';
    EXEC TestPermission 'SELECT', 'EmployeeCustomer';
    EXEC TestPermission 'SELECT', 'AccountOwner';
    EXEC TestPermission 'SELECT', 'Account';
    EXEC TestPermission 'SELECT', 'Overdraft';
    EXEC TestPermission 'SELECT', 'LoanCustomer';
    EXEC TestPermission 'SELECT', 'Loan';
    EXEC TestPermission 'SELECT', 'LoanPayment';
    EXEC TestPermission 'SELECT', 'Branch';
    EXEC TestPermission 'SELECT', 'City';
    EXEC TestPermission 'SELECT', 'Province';
    EXEC TestPermission 'SELECT', 'Country';

    REVERT;
END;
GO

-- Customer negative test case scenario
CREATE OR ALTER PROCEDURE RunCustomerNegativeTestCase
    @UserName NVARCHAR(128)
AS
BEGIN
    EXEC AS USER = @UserName;

    PRINT '--- Customer should NOT be able to modify restricted tables ---';

    EXEC TestPermission 'SELECT', 'Employee';				
    EXEC TestPermission 'SELECT', 'EmployeeLocation';
    EXEC TestPermission 'DELETE', 'Employee', 'WHERE Id = 1';
    EXEC TestPermission 'DELETE', 'Loan', 'WHERE LoanId = 1';
    EXEC TestPermission 'UPDATE', 'Account', 'Balance = Balance + 100';
    EXEC TestPermission 'INSERT', 'Customer', '(Id, FirstName, LastName, CityId, HomeAddress, PostalCode) VALUES (9999, ''Liam'', ''Martin'', 1, ''12 Bay St, Toronto'', ''M5H2N2'')';

    PRINT '--- End of Negative Scenario ---';

    REVERT;
END;
GO

-- Accountant positive test case scenario
CREATE OR ALTER PROCEDURE RunAccountantPositiveTestCase
    @UserName NVARCHAR(128)
AS
BEGIN
    EXEC AS USER = @UserName;

    PRINT '--- Accountant should have SELECT, INSERT, UPDATE, DELETE access on allowed tables ---';

    EXEC TestPermission 'SELECT', 'Customer';
    EXEC TestPermission 'SELECT', 'Employee';
    EXEC TestPermission 'SELECT', 'EmployeeLocation';
    EXEC TestPermission 'SELECT', 'EmployeeCustomer';
    EXEC TestPermission 'SELECT', 'AccountOwner';
    EXEC TestPermission 'SELECT', 'Account';
    EXEC TestPermission 'SELECT', 'Overdraft';
    EXEC TestPermission 'SELECT', 'LoanCustomer';
    EXEC TestPermission 'SELECT', 'Loan';
    EXEC TestPermission 'SELECT', 'LoanPayment';
    EXEC TestPermission 'SELECT', 'Branch';
    EXEC TestPermission 'SELECT', 'City';
    EXEC TestPermission 'SELECT', 'Province';
    EXEC TestPermission 'SELECT', 'Country';

	EXEC TestPermission 'INSERT', 'Customer', '(Id, FirstName, LastName, CityId, HomeAddress, PostalCode) VALUES (8888, ''Victor'', ''Frankenstein'', 1, ''12 Bay St, Toronto'', ''M5H2N2'')';
	EXEC TestPermission 'UPDATE', 'Customer', 'FirstName = ''VictorUpdated'' WHERE Id = 8888';
	EXEC TestPermission 'DELETE', 'Customer', 'WHERE Id = 8888';

    PRINT '--- End of Positive Scenario ---';

    REVERT;
END;
GO

-- Accountant negative test case scenario
CREATE OR ALTER PROCEDURE RunAccountantNegativeTestCase
    @UserName NVARCHAR(128)
AS
BEGIN
    EXEC AS USER = @UserName;

    PRINT '--- Accountant should NOT be able to modify restricted tables ---';

    EXEC TestPermission 'UPDATE', 'Account', 'Balance = Balance + 100';
    EXEC TestPermission 'UPDATE', 'Loan', 'Amount = Amount + 500';
    EXEC TestPermission 'DELETE', 'Account', 'WHERE Id = 1';
    EXEC TestPermission 'DELETE', 'LoanCustomer', 'WHERE LoanId = 1';
    EXEC TestPermission 'INSERT', 'Account', '(Id, BranchId, IsSavings, AccountNumber, Balance, LastAccessed, InterestRate, OverdraftLimit, Type) VALUES (9999, 1, 1, ''SAV10001'', 10000.00, ''2025-10-17 10:00:00'', 1.25, 0.00, ''Savings'')';
    EXEC TestPermission 'INSERT', 'LoanPayment', '(Id, LoanId, PaymentDate, Amount) VALUES (9999, 1, GETDATE(), 200)';

    PRINT '--- End of Negative Scenario ---';

    REVERT;
END;
GO

--============================================================ CUSTOMER SECTION ============================================================

/*
	Create a login and user named “customer_group_F”
	Their password should be “customer”. 
	Their user account should only be able to read tables that are related to customers, based on your ERD. (For example, tables related to customer information, accounts, loans, and payments).
*/

-- Params: Login, Password, Role
EXEC CreateLoginUserRole 'customer_group_F', 'customer', 'customer_readonly_role';
GO

GRANT EXECUTE ON dbo.TestPermission TO customer_readonly_role;
GO

DECLARE @customerTables NVARCHAR(MAX) = 
'Customer,EmployeeCustomer,AccountOwner,Account,Overdraft,LoanCustomer,Loan,LoanPayment,Branch,City,Province,Country';

-- Params: Role, Table, GrantOrDeny, Permission
EXEC ApplyPermissions 'customer_readonly_role', @customerTables, 'REVOKE', 'SELECT,INSERT,UPDATE,DELETE';
EXEC ApplyPermissions 'customer_readonly_role', @customerTables, 'GRANT', 'SELECT';
GO

--============================================================ ACCOUNTANT SECTION ============================================================

/*
	Create a login and user named “accountant_group_F”
	Their password should be “accountant”.
	Their user account should be able to read all tables.
	Their user account should not be able to update, insert or delete in tables that are related to accounts, payments and loans, based on your ERD. 
	Those permissions should be revoked.
*/

-- Params: Login, Password, Role
EXEC CreateLoginUserRole 'accountant_group_F', 'accountant', 'accountant_role';
GO

GRANT EXECUTE ON dbo.TestPermission TO accountant_role;
GO

-- Accountant-related tables
DECLARE @accountantTables NVARCHAR(MAX) = 
'Employee,EmployeeLocation,Customer,EmployeeCustomer,AccountOwner,Account,Overdraft,LoanCustomer,Loan,LoanPayment,Branch,City,Province,Country';

-- Params: Role, Table, GrantOrDeny, Permission
EXEC ApplyPermissions 'accountant_role', @accountantTables, 'REVOKE', 'SELECT,INSERT,UPDATE,DELETE';
EXEC ApplyPermissions 'accountant_role', @accountantTables, 'GRANT', 'SELECT,INSERT,UPDATE,DELETE';

-- Accountant-related restricted tables
DECLARE @restrictedTables NVARCHAR(MAX) = 
'Account,Overdraft,Loan,LoanCustomer,LoanPayment,AccountOwner';

-- Params: Role, Table, GrantOrDeny, Permission
EXEC ApplyPermissions 'accountant_role', @restrictedTables, 'DENY', 'INSERT,UPDATE,DELETE';
GO

--============================================================ TESTING SECTION ============================================================

-- Provide SQL statements that test the enforcement of the privileges on the two users created above.

-- CUSTOMER TEST CASES

-- Run Positive Test for Customer
EXEC RunCustomerPositiveTestCase 'customer_group_F';

-- Run Negative Test for Customer
EXEC RunCustomerNegativeTestCase 'customer_group_F';


-- ACCOUNTANT TEST CASES

-- Run Positive Test for Accountant
EXEC RunAccountantPositiveTestCase 'accountant_group_F';

-- Run Negative Test for Accountant
EXEC RunAccountantNegativeTestCase 'accountant_group_F';