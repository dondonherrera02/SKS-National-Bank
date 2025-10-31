/*
Author: HERRERA D., LEUNG V., ARAVAI S.
Course: DATA2201 – Relational Databases
Date: October 31, 2025
Project Name: SKS National Bank
Instructor: Michael Dorsey
*/

USE [SKS_BANK_DB]
GO

-- Country
INSERT INTO Country (Id, Name) VALUES
(1, 'Canada');

-- Province
INSERT INTO Province (Id, Name, CountryId) VALUES
(1, 'Ontario', 1),
(2, 'Quebec', 1),
(3, 'British Columbia', 1),
(4, 'Alberta', 1),
(5, 'Manitoba', 1);

-- City
INSERT INTO City (Id, Name, ProvinceId) VALUES
(1, 'Toronto', 1),
(2, 'Ottawa', 1),
(3, 'Montreal', 2),
(4, 'Quebec City', 2),
(5, 'Vancouver', 3),
(6, 'Victoria', 3),
(7, 'Calgary', 4),
(8, 'Edmonton', 4),
(9, 'Winnipeg', 5),
(10, 'Brandon', 5);

-- Branch
INSERT INTO Branch (Id, CityId, Name, PostalCode, IsBranch, TotalLoans, TotalDeposit) VALUES
(1, 1, 'Toronto Downtown', 'M5H2N2', 1, 500000.00, 2000000.00),
(2, 2, 'Ottawa Central', 'K1P1J1', 1, 300000.00, 1200000.00),
(3, 3, 'Montreal Main', 'H3B2Y5', 1, 400000.00, 1500000.00),
(4, 4, 'Quebec City East', 'G1R2K5', 1, 250000.00, 900000.00),
(5, 5, 'Vancouver West', 'V6B1A1', 1, 600000.00, 2200000.00),
(6, 6, 'Victoria Harbour', 'V8W1N6', 1, 200000.00, 800000.00),
(7, 7, 'Calgary North', 'T2P1J9', 1, 350000.00, 1100000.00),
(8, 8, 'Edmonton South', 'T5J2G8', 1, 320000.00, 1000000.00),
(9, 9, 'Winnipeg Central', 'R3C1A5', 1, 180000.00, 700000.00),
(10, 10, 'Brandon West', 'R7A5Y6', 1, 120000.00, 500000.00);

-- Employee
INSERT INTO Employee (Id, FirstName, LastName, CityId, HomeAddress, PostalCode, EmployeeId, ManagerId, StartDate) VALUES
(1, 'Alice', 'Smith', 1, '123 King St, Toronto', 'M5H2N2', 'EMP001', NULL, '2022-01-10'),
(2, 'Bob', 'Johnson', 2, '456 Queen St, Ottawa', 'K1P1J1', 'EMP002', 1, '2022-03-15'),
(3, 'Carol', 'Williams', 3, '789 St Catherine, Montreal', 'H3B2Y5', 'EMP003', 1, '2022-05-20'),
(4, 'David', 'Brown', 4, '101 Grande Allée, Quebec City', 'G1R2K5', 'EMP004', 1, '2022-07-25'),
(5, 'Eve', 'Jones', 5, '202 Burrard St, Vancouver', 'V6B1A1', 'EMP005', 1, '2022-09-30'),
(6, 'Frank', 'Miller', 6, '303 Douglas St, Victoria', 'V8W1N6', 'EMP006', 1, '2022-11-05'),
(7, 'Grace', 'Davis', 7, '404 8 Ave SW, Calgary', 'T2P1J9', 'EMP007', 1, '2023-01-10'),
(8, 'Henry', 'Wilson', 8, '505 Jasper Ave, Edmonton', 'T5J2G8', 'EMP008', 1, '2023-03-15'),
(9, 'Ivy', 'Moore', 9, '606 Portage Ave, Winnipeg', 'R3C1A5', 'EMP009', 1, '2023-05-20'),
(10, 'Jack', 'Taylor', 10, '707 18th St, Brandon', 'R7A5Y6', 'EMP010', 1, '2023-07-25');

-- EmployeeLocation
INSERT INTO EmployeeLocation (EmployeeId, LocationId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- Customer
INSERT INTO Customer (Id, FirstName, LastName, CityId, HomeAddress, PostalCode) VALUES
(1, 'Liam', 'Martin', 1, '12 Bay St, Toronto', 'M5H2N2'),
(2, 'Olivia', 'Clark', 2, '34 Elgin St, Ottawa', 'K1P1J1'),
(3, 'Noah', 'Lee', 3, '56 Sherbrooke St, Montreal', 'H3B2Y5'),
(4, 'Emma', 'Walker', 4, '78 St Jean, Quebec City', 'G1R2K5'),
(5, 'Mason', 'Hall', 5, '90 Granville St, Vancouver', 'V6B1A1'),
(6, 'Sophia', 'Young', 6, '23 Government St, Victoria', 'V8W1N6'),
(7, 'Lucas', 'King', 7, '45 4th Ave, Calgary', 'T2P1J9'),
(8, 'Ava', 'Wright', 8, '67 Whyte Ave, Edmonton', 'T5J2G8'),
(9, 'Ethan', 'Scott', 9, '89 Main St, Winnipeg', 'R3C1A5'),
(10, 'Isabella', 'Green', 10, '21 Princess Ave, Brandon', 'R7A5Y6');

-- EmployeeCustomer
INSERT INTO EmployeeCustomer (EmployeeId, CustomerId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- Account
INSERT INTO Account (Id, BranchId, IsSavings, AccountNumber, Balance, LastAccessed, InterestRate, OverdraftLimit, Type) VALUES
(1, 1, 1, 'SAV10001', 10000.00, '2025-10-17 10:00:00', 1.25, 0.00, 'Savings'),
(2, 2, 0, 'CHK20001', 2500.00, '2025-10-17 11:00:00', 0.00, 500.00, 'Chequing'),
(3, 3, 1, 'SAV10002', 8000.00, '2025-10-17 12:00:00', 1.30, 0.00, 'Savings'),
(4, 4, 0, 'CHK20002', 3000.00, '2025-10-17 13:00:00', 0.00, 400.00, 'Chequing'),
(5, 5, 1, 'SAV10003', 12000.00, '2025-10-17 14:00:00', 1.20, 0.00, 'Savings'),
(6, 6, 0, 'CHK20003', 1500.00, '2025-10-17 15:00:00', 0.00, 600.00, 'Chequing'),
(7, 7, 1, 'SAV10004', 9500.00, '2025-10-17 16:00:00', 1.15, 0.00, 'Savings'),
(8, 8, 0, 'CHK20004', 4000.00, '2025-10-17 17:00:00', 0.00, 700.00, 'Chequing'),
(9, 9, 1, 'SAV10005', 11000.00, '2025-10-17 18:00:00', 1.10, 0.00, 'Savings'),
(10, 10, 0, 'CHK20005', 3500.00, '2025-10-17 19:00:00', 0.00, 800.00, 'Chequing');

-- AccountOwner
INSERT INTO AccountOwner (AccountId, CustomerId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- Loan
INSERT INTO Loan (Id, BranchId, Amount) VALUES
(1, 1, 50000.00),
(2, 2, 30000.00),
(3, 3, 40000.00),
(4, 4, 25000.00),
(5, 5, 60000.00),
(6, 6, 20000.00),
(7, 7, 35000.00),
(8, 8, 32000.00),
(9, 9, 18000.00),
(10, 10, 12000.00);

-- LoanCustomer
INSERT INTO LoanCustomer (LoanId, CustomerId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- LoanPayment
INSERT INTO LoanPayment (LoanId, PaymentNumber, PaymentDate, Amount) VALUES
(1, 1, '2025-09-01', 5000.00),
(1, 2, '2025-10-01', 5000.00),
(2, 1, '2025-09-01', 3000.00),
(2, 2, '2025-10-01', 3000.00),
(3, 1, '2025-09-01', 4000.00),
(3, 2, '2025-10-01', 4000.00),
(4, 1, '2025-09-01', 2500.00),
(4, 2, '2025-10-01', 2500.00),
(5, 1, '2025-09-01', 6000.00),
(5, 2, '2025-10-01', 6000.00);

-- Overdraft (ChequingAccountId must reference accounts where IsSavings = 0)
INSERT INTO Overdraft (ChequingAccountId, Date, Amount, CheckNumber) VALUES
(2, '2025-10-10', 200.00, 'CHK20001-001'),
(4, '2025-10-11', 150.00, 'CHK20002-001'),
(6, '2025-10-12', 300.00, 'CHK20003-001'),
(8, '2025-10-13', 250.00, 'CHK20004-001'),
(10, '2025-10-14', 400.00, 'CHK20005-001');
