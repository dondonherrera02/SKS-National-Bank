/*
Author: HERRERA D., LEUNG V., ARAVAI S.
Course: DATA2201 Relational Databases
Date: October 31, 2025
Project Name: SKS National Bank
Instructor: Michael Dorsey
*/


/*
User Story 1 Branch Performance Summary

As a regional manager,
I want to see each branch total money deposited, total loan amount, and number of customers,
so I can check how each branch is doing and find the best ones.

Acceptance Criteria:
Displays branch, city, total deposits, and total loans
Includes customer count per branch
Includes branches with zero activity
*/

-- Stored Procedure
CREATE PROCEDURE uspBranchPerformanceSummary
AS
BEGIN
    SELECT 
        b.Name AS BranchName,
        c.Name AS CityName,
        b.TotalDeposit,
        b.TotalLoans,
        COUNT(DISTINCT ao.CustomerId) AS CustomerCount
    FROM Branch b
    LEFT JOIN City c ON b.CityId = c.Id
    LEFT JOIN Account a ON b.Id = a.BranchId
    LEFT JOIN AccountOwner ao ON a.Id = ao.AccountId
    GROUP BY b.Name, c.Name, b.TotalDeposit, b.TotalLoans
END
GO

-- Test Script
EXEC uspBranchPerformanceSummary;
GO


/*
User Story 2 Employee Hierarchy

As an HR administrator,
I want to see how managers and employees are connected,
so I can check who reports to whom and understand the companys structure.

Acceptance Criteria:
Input: Manager ID
Lists direct reports
*/

-- Table Valued Function
CREATE FUNCTION fnEmployeeHierarchy (@ManagerId INT)
RETURNS TABLE
AS
RETURN
    SELECT 
        e.Id AS EmployeeId,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        e.ManagerId
    FROM Employee e
    WHERE e.ManagerId = @ManagerId
GO

-- Test Script
SELECT * FROM fnEmployeeHierarchy(1);
GO


/*
User Story 3  Employee Location Audit

As a compliance officer,
I want to see all employees with their assigned office or branch,
so I can make sure everyone is in the right place and the records are correct.

Acceptance Criteria:
Name, location, Branch or Office
Includes employees missing a location
*/

-- Stored Procedure
CREATE PROCEDURE uspEmployeeLocationAudit
AS
BEGIN
    SELECT 
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        b.Name AS LocationName,
        CASE WHEN b.IsBranch = 1 THEN 'Branch' ELSE 'Office' END AS LocationType
    FROM Employee e
    LEFT JOIN EmployeeLocation el ON e.Id = el.EmployeeId
    LEFT JOIN Branch b ON el.LocationId = b.Id
    ORDER BY b.CityId
END
GO

-- Test Script
EXEC uspEmployeeLocationAudit;
GO


/*
User Story 4  Customer Portfolio Summary

As a financial advisor,
I want to see each customers total account and loan balances,
so I can give them better financial advice.

Acceptance Criteria:
Shows name, deposits, loans, net worth
*/

-- Table Valued Function
CREATE FUNCTION fnCustomerPortfolioSummary (@CustomerId INT)
RETURNS TABLE
AS
RETURN
    SELECT 
        c.Id AS CustomerId,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        ISNULL(SUM(a.Balance), 0) AS TotalDeposit,
        ISNULL(SUM(l.Amount), 0) AS TotalLoan,
        ISNULL(SUM(a.Balance), 0) - ISNULL(SUM(l.Amount), 0) AS NetWorth
    FROM Customer c
    LEFT JOIN AccountOwner ao ON c.Id = ao.CustomerId
    LEFT JOIN Account a ON ao.AccountId = a.Id
    LEFT JOIN LoanCustomer lc ON c.Id = lc.CustomerId
    LEFT JOIN Loan l ON lc.LoanId = l.Id
    WHERE c.Id = @CustomerId
    GROUP BY c.Id, c.FirstName, c.LastName
GO

-- Test Script
SELECT * FROM fnCustomerPortfolioSummary(1);
GO


/*
User Story 5  Loan Payment History

As a loan officer,
I want to see all the payments made on a loan,
so I can confirm the repayments and see how much is still owed.

Acceptance Criteria:
Input: Loan ID
List of payments in order, outstanding balance for each
*/

-- Stored Procedure
CREATE PROCEDURE uspLoanPaymentHistory (@LoanId INT)
AS
BEGIN
    SELECT
        lp.PaymentNumber,
        lp.PaymentDate,
        lp.Amount,
        l.Amount - (
            SELECT SUM(p.Amount)
            FROM LoanPayment p
            WHERE p.LoanId = lp.LoanId
              AND p.PaymentNumber <= lp.PaymentNumber
        ) AS OutstandingBalance
    FROM LoanPayment lp
    INNER JOIN Loan l ON lp.LoanId = l.Id
    WHERE lp.LoanId = @LoanId
    ORDER BY lp.PaymentNumber
END
GO

-- Test Script
EXEC uspLoanPaymentHistory 1;
GO

/*
User Story 6  Overdraft Reports by Branch

As a risk manager,
I want to see all overdraft cases by branch and customer,
so I can control financial risks and plan ways to reduce them.

Acceptance Criteria:
Branch, account, customer, date, amount
Only chequing accounts
*/

--Stored Procedure
CREATE PROCEDURE uspOverdraftReportByBranch
AS
BEGIN
    SELECT 
        b.Name AS BranchName,
        a.AccountNumber,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        o.Amount,
        o.Date
    FROM Overdraft o
    INNER JOIN Account a ON o.ChequingAccountId = a.Id
    INNER JOIN Branch b ON a.BranchId = b.Id
    INNER JOIN AccountOwner ao ON a.Id = ao.AccountId
    INNER JOIN Customer c ON ao.CustomerId = c.Id
    WHERE a.IsSavings = 0
END
GO

-- Test Script
EXEC uspOverdraftReportByBranch;
GO


/*
User Story 7  Loan-to-Deposit Ratio by Branch

As a bank analyst,
I want to see the loan-to-deposit ratio for each branch,
so I can check how much each branch is lending compared to its deposits and understand its financial risk.

Acceptance Criteria:
Branch, loans, deposits, ratio
Flags zero deposit branches

Note: 
Loan-to-deposit ratio (Ratio) = TotalLoans / TotalDeposit.
This value shows what percentage of deposits have been given out as loans at each branch.
Higher ratios mean more lending, lower ratios mean more deposits held in reserve.

Ref: https://www.investopedia.com/terms/l/loan-to-deposit-ratio.asp
*/

-- Table Valued Function
CREATE FUNCTION fnLoanDepositRatioSummary ()
RETURNS TABLE
AS
RETURN
    SELECT
        b.Name AS BranchName,
        b.TotalLoans,
        b.TotalDeposit,
        CASE WHEN b.TotalDeposit = 0 THEN NULL ELSE b.TotalLoans / b.TotalDeposit END AS Ratio
    FROM Branch b
GO

-- Test Script
SELECT * FROM fnLoanDepositRatioSummary();
GO


/*
User Story 8  Employee Customer Coverage

As a branch supervisor,
I want to see which employees handle which customers,
so I can divide the work fairly and monitor customer interactions.

Acceptance Criteria:
Shows employee, branch, customer list
Supports filter by employee
*/

-- Stored Procedure
CREATE PROCEDURE uspEmployeeCustomerCoverage (@EmployeeId INT = NULL)
AS
BEGIN
    SELECT 
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        b.Name AS BranchName,
        c.FirstName + ' ' + c.LastName AS CustomerName
    FROM EmployeeCustomer ec
    INNER JOIN Employee e ON ec.EmployeeId = e.Id
    INNER JOIN Customer c ON ec.CustomerId = c.Id
    INNER JOIN EmployeeLocation el ON e.Id = el.EmployeeId
    INNER JOIN Branch b ON el.LocationId = b.Id
    WHERE (@EmployeeId IS NULL OR e.Id = @EmployeeId)
    ORDER BY e.Id, b.Id, c.Id
END
GO

-- Test Scripts
EXEC uspEmployeeCustomerCoverage;
EXEC uspEmployeeCustomerCoverage 1;
GO


/*
User Story 9 Customer Account Health

As an account manager,
I want to find customers who still owe money or have overdrafts,
so I can contact them first and review their accounts.

Acceptance Criteria:
Shows customer, account type, balance, overdraft, loan info
*/

-- Stored Procedure
CREATE PROCEDURE uspCustomerAccountHealth
AS
BEGIN
    SELECT 
        c.FirstName + ' ' + c.LastName AS CustomerName,
        a.Type AS AccountType,
        a.Balance,
        o.Amount AS OverdraftAmount,
        l.Amount AS OutstandingLoan
    FROM Customer c
    LEFT JOIN AccountOwner ao ON c.Id = ao.CustomerId
    LEFT JOIN Account a ON ao.AccountId = a.Id
    LEFT JOIN Overdraft o ON a.Id = o.ChequingAccountId
    LEFT JOIN LoanCustomer lc ON c.Id = lc.CustomerId
    LEFT JOIN Loan l ON lc.LoanId = l.Id
END
GO

-- Test Script
EXEC uspCustomerAccountHealth;
GO


/*
User Story 10 Branch Financial Snapshot

As a branch manager,
I want to see a summary of deposits, loans, overdrafts, and the last loan payment for my branch,
so I can quickly check how my branch is doing.

Acceptance Criteria:
Input: Branch ID
KPIs: deposits, loans, overdrafts, last payment date
*/

-- Scalar Function
CREATE FUNCTION fnBranchFinancialSnapshot (@BranchId INT)
RETURNS VARCHAR(400)
AS
BEGIN
    DECLARE @Snapshot VARCHAR(400);
    WITH BranchData AS (
        SELECT 
            b.TotalDeposit,
            b.TotalLoans,
            (SELECT COUNT(*) FROM Overdraft o INNER JOIN Account a ON o.ChequingAccountId = a.Id WHERE a.BranchId = @BranchId) AS OverdraftCount,
            (SELECT MAX(PaymentDate) FROM LoanPayment lp INNER JOIN Loan l ON lp.LoanId = l.Id WHERE l.BranchId = @BranchId) AS LastLoanPayment
        FROM Branch b
        WHERE b.Id = @BranchId
    )
    SELECT @Snapshot = 'Total Deposits: ' + CAST(TotalDeposit AS VARCHAR) + 
                       ', Total Loans: ' + CAST(TotalLoans AS VARCHAR) +
                       ', Overdrafts: ' + CAST(OverdraftCount AS VARCHAR) + 
                       ', Last Loan Payment: ' + COALESCE(CONVERT(VARCHAR, LastLoanPayment, 23), 'N/A')
    FROM BranchData;
    RETURN @Snapshot;
END
GO

-- Test Script
SELECT dbo.fnBranchFinancialSnapshot(1) AS Snapshot;
GO
