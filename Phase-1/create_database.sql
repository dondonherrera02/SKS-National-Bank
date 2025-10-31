/*
Author: HERRERA D., LEUNG V., ARAVAI S.
Course: DATA2201 – Relational Databases
Date: October 31, 2025
Project Name: SKS National Bank
Instructor: Michael Dorsey
*/

USE master
GO

-- Drop database if exists --
IF DB_ID('SKS_BANK_DB') IS NOT NULL
    DROP DATABASE SKS_BANK_DB
GO

-- Create SKS_BANK_DB database --
CREATE DATABASE SKS_BANK_DB
GO

USE SKS_BANK_DB
GO

-- Country
CREATE TABLE Country (
    Id INT PRIMARY KEY,
    Name VARCHAR(100)
);

-- Province
CREATE TABLE Province (
    Id INT PRIMARY KEY,
    Name VARCHAR(100),
    CountryId INT,
    FOREIGN KEY (CountryId) REFERENCES Country(Id)
);

-- City
CREATE TABLE City (
    Id INT PRIMARY KEY,
    Name VARCHAR(100),
    ProvinceId INT,
    FOREIGN KEY (ProvinceId) REFERENCES Province(Id)
);

-- Branch (Office)
CREATE TABLE Branch (
    Id INT PRIMARY KEY,
    CityId INT,
    Name VARCHAR(100),
    PostalCode VARCHAR(10),
    IsBranch BIT,
    TotalLoans DECIMAL(15,2),
    TotalDeposit DECIMAL(15,2),
    FOREIGN KEY (CityId) REFERENCES City(Id)
);

-- Employee
CREATE TABLE Employee (
    Id INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    CityId INT,
    HomeAddress VARCHAR(255),
    PostalCode VARCHAR(10),
    EmployeeId VARCHAR(50),
    ManagerId INT,
    StartDate DATE,
    FOREIGN KEY (CityId) REFERENCES City(Id),
    FOREIGN KEY (ManagerId) REFERENCES Employee(Id) ON DELETE NO ACTION
);

-- EmployeeLocation
CREATE TABLE EmployeeLocation (
    EmployeeId INT,
    LocationId INT,
    PRIMARY KEY (EmployeeId, LocationId),
    FOREIGN KEY (EmployeeId) REFERENCES Employee(Id),
    FOREIGN KEY (LocationId) REFERENCES Branch(Id) ON DELETE CASCADE
);

-- Customer
CREATE TABLE Customer (
    Id INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    CityId INT,
    HomeAddress VARCHAR(255),
    PostalCode VARCHAR(10),
    FOREIGN KEY (CityId) REFERENCES City(Id)
);

-- EmployeeCustomer (Banker/Loan Officer - Customer)
CREATE TABLE EmployeeCustomer (
    EmployeeId INT,
    CustomerId INT,
    PRIMARY KEY (EmployeeId, CustomerId),
    FOREIGN KEY (EmployeeId) REFERENCES Employee(Id),
    FOREIGN KEY (CustomerId) REFERENCES Customer(Id)
);

-- Account
CREATE TABLE Account (
    Id INT PRIMARY KEY,
    BranchId INT,
    IsSavings BIT,
    AccountNumber VARCHAR(20) UNIQUE,
    Balance DECIMAL(15,2),
    LastAccessed DATETIME,
    InterestRate DECIMAL(5,2),
    OverdraftLimit DECIMAL(15,2),
    Type VARCHAR(20),
    FOREIGN KEY (BranchId) REFERENCES Branch(Id) ON DELETE SET NULL
);

-- AccountOwner
CREATE TABLE AccountOwner (
    AccountId INT,
    CustomerId INT,
    PRIMARY KEY (AccountId, CustomerId),
    FOREIGN KEY (AccountId) REFERENCES Account(Id),
    FOREIGN KEY (CustomerId) REFERENCES Customer(Id)
);

-- Loan
CREATE TABLE Loan (
    Id INT PRIMARY KEY,
    BranchId INT,
    Amount DECIMAL(15,2),
    FOREIGN KEY (BranchId) REFERENCES Branch(Id) ON DELETE SET NULL
);

-- LoanCustomer
CREATE TABLE LoanCustomer (
    LoanId INT,
    CustomerId INT,
    PRIMARY KEY (LoanId, CustomerId),
    FOREIGN KEY (LoanId) REFERENCES Loan(Id),
    FOREIGN KEY (CustomerId) REFERENCES Customer(Id)
);

-- LoanPayment
CREATE TABLE LoanPayment (
    LoanId INT,
    PaymentNumber INT,
    PaymentDate DATE,
    Amount DECIMAL(15,2),
    PRIMARY KEY (LoanId, PaymentNumber),
    FOREIGN KEY (LoanId) REFERENCES Loan(Id) ON DELETE CASCADE
);

-- Overdraft
CREATE TABLE Overdraft (
    ChequingAccountId INT,
    Date DATE,
    Amount DECIMAL(15,2),
    CheckNumber VARCHAR(20),
    PRIMARY KEY (ChequingAccountId, Date),
    FOREIGN KEY (ChequingAccountId) REFERENCES Account(Id) ON DELETE CASCADE
);
