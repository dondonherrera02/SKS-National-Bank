/*
Author: HERRERA D., LEUNG V., ARAVAI S.
Course: DATA2201 Relational Databases
Date: December 12, 2025
Project Name: SKS National Bank
Instructor: Michael Dorsey
*/

/*
	Create a new table called “Audit” to track changes made in the database. At minimum, this table should contain the following 3 pieces of information:
	Primary key.
	An explanation of exactly what happened in the database.
	Timestamp.

*/

USE SKS_BANK_DB;
GO

--------------------------------------------------------------
-- 1. CREATE AUDIT TABLE
--------------------------------------------------------------
IF OBJECT_ID('dbo.Audit', 'U') IS NOT NULL
    DROP TABLE dbo.Audit;
GO

CREATE TABLE dbo.Audit (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EventDetails VARCHAR(500) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------------
-- 2. TRIGGER 1: Audit log for new savings account creation
/* As a branch officer, I want the system to automatically log every new savings account created,
so that I can review who created an account, for which customer, and in which branch. */
--------------------------------------------------------------
IF OBJECT_ID('dbo.trg_NewSavingsAccountCreated', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_NewSavingsAccountCreated;
GO

CREATE TRIGGER dbo.trg_NewSavingsAccountCreated
ON dbo.AccountOwner
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Audit (EventDetails)
    SELECT 'New account created. Account ID: ' + CAST(a.Id AS NVARCHAR(10)) + ', Type: Savings' + ', Customer Name: ' + ISNULL(c.FirstName,'') + ' ' + ISNULL(c.LastName,'') + ', Branch Name: ' + ISNULL(b.Name,'')
    FROM inserted i
		JOIN dbo.Account a ON i.AccountID = a.Id
		JOIN dbo.Branch b ON b.Id = a.BranchId
		JOIN dbo.Customer c ON i.CustomerID = c.Id
    WHERE a.isSavings = 1;
END;
GO


--------------------------------------------------------------
-- 3. TRIGGER 2: Audit log for savings account balance update
/* As a banking supervisor, I want the system to automatically log every balance update on savings accounts,
so that I can monitor changes and ensure no unauthorized or suspicious activity occurs. */
--------------------------------------------------------------
IF OBJECT_ID('dbo.trg_SavingsAccountBalanceUpdate', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_SavingsAccountBalanceUpdate;
GO

CREATE TRIGGER dbo.trg_SavingsAccountBalanceUpdate
ON dbo.Account
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Audit (EventDetails)
    SELECT 'Savings Account ' + ISNULL(i.AccountNumber, 'N/A') + ' updated. Old Balance: ' + CAST(ISNULL(d.Balance, 0) AS VARCHAR(30)) + ', New Balance: ' + CAST(ISNULL(i.Balance, 0) AS VARCHAR(30)) + ', Customer: ' + ISNULL(c.FirstName,'') + ' ' + ISNULL(c.LastName,'') + ', Branch: ' + ISNULL(b.Name,'')
    FROM inserted i
		JOIN deleted d ON i.Id = d.Id
		JOIN dbo.AccountOwner ao ON i.Id = ao.AccountID
		JOIN dbo.Customer c ON ao.CustomerID = c.Id
		JOIN dbo.Branch b ON i.BranchId = b.Id
    WHERE i.Balance <> d.Balance
      AND i.isSavings = 1;
END;
GO

--------------------------------------------------------------
-- 4. TRIGGER 3: Audit Log for employee deletion
/* As a human resources administrator, I want the system to log employee removals from branch assignments,
so that I can keep historical records of employee branch associations.*/
--------------------------------------------------------------
IF OBJECT_ID('dbo.trg_EmployeeDelete', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_EmployeeDelete;
GO

CREATE TRIGGER dbo.trg_EmployeeDelete
ON dbo.EmployeeLocation
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Audit (EventDetails)
    SELECT 'Employee removed. Name: ' + ISNULL(e.FirstName, 'N/A') + ' ' + ISNULL(e.LastName, 'N/A')  + ', EmployeeId: ' + ISNULL(e.EmployeeId, 'N/A') + ', Branch: ' + ISNULL(b.Name, 'N/A')
    FROM deleted d
		JOIN dbo.Employee e ON d.EmployeeId = e.Id
		JOIN dbo.Branch b ON d.LocationId = b.Id;
END;
GO


--------------------------------------------------------------
-- 5. TEST STATEMENTS
--------------------------------------------------------------

-- (1) Create a NEW ACCOUNT for Liam Martin (Customer ID = 1)
-- Add a new savings account for Liam in Branch 1
INSERT INTO dbo.Account (Id, BranchId, IsSavings, AccountNumber, Balance, LastAccessed, InterestRate, OverdraftLimit, Type)
VALUES (11, 1, 1, 'SAV10006', 5000.00, GETDATE(), 1.50, 0.00, 'Savings');
GO

-- Link new account to Liam (CustomerId = 1)
INSERT INTO dbo.AccountOwner (AccountId, CustomerId) VALUES (11, 1);
GO

-- (2) UPDATE that account with an additional 100
UPDATE dbo.Account
SET Balance = Balance + 100
WHERE Id = 11;
GO

-- (3) DELETE Employee Jack Taylor (EmployeeId = EMP010)
DELETE FROM dbo.EmployeeLocation WHERE EmployeeId = (SELECT Id FROM dbo.Employee WHERE EmployeeId = 'EMP010'); -- remove from EmployeeLocation
DELETE FROM dbo.EmployeeCustomer WHERE EmployeeId = (SELECT Id FROM dbo.Employee WHERE EmployeeId = 'EMP010'); -- remove from EmployeeCustomer
DELETE FROM dbo.Employee WHERE EmployeeId = 'EMP010';
GO

-- (4) VIEW AUDIT LOG ENTRIES
SELECT * FROM dbo.Audit ORDER BY CreatedDate DESC;
GO