/*
Author: HERRERA D., LEUNG V., ARAVAI S.
Course: DATA2201 Relational Databases
Date: December 12, 2025
Project Name: SKS National Bank
Instructor: Michael Dorsey
*/

--------------------------------------------------------------
-- 1. Add one column with the JSON data type to any table of your choice. Populate it with sample data.
--------------------------------------------------------------

-- Check if column exists before adding
IF COL_LENGTH('Employee', 'EmployeeInfoJson') IS NULL
BEGIN
    ALTER TABLE Employee ADD EmployeeInfoJson NVARCHAR(MAX);
END
GO

-- Update each row with JSON
UPDATE e
SET EmployeeInfoJson = (
    SELECT 
        e2.Id,
        e2.FirstName,
        e2.LastName,
        e2.EmployeeId,
        b.Name AS BranchName
    FROM Employee e2
    LEFT JOIN EmployeeLocation el ON el.EmployeeId = e2.Id
    LEFT JOIN Branch b ON el.LocationId = b.Id
    WHERE e2.Id = e.Id
    FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
)
FROM Employee e;
GO

SELECT * FROM Employee

--------------------------------------------------------------
-- 2. Add one column to a table to store the spatial information of the bank’s branches. Populate it with sample data.
--------------------------------------------------------------

IF COL_LENGTH('Branch', 'SpatialLocation') IS NULL
BEGIN
    ALTER TABLE Branch ADD SpatialLocation GEOGRAPHY;
END
GO

-- 2. Update each branch with sample spatial data (latitude, longitude)
UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(43.654, -79.380, 4326) -- Toronto Downtown
WHERE Name = 'Toronto Downtown';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(45.421, -75.691, 4326) -- Ottawa Central
WHERE Name = 'Ottawa Central';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(45.501, -73.567, 4326) -- Montreal Main
WHERE Name = 'Montreal Main';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(46.813, -71.207, 4326) -- Quebec City East
WHERE Name = 'Quebec City East';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(49.282, -123.117, 4326) -- Vancouver West
WHERE Name = 'Vancouver West';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(48.428, -123.365, 4326) -- Victoria Harbour
WHERE Name = 'Victoria Harbour';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(51.045, -114.058, 4326) -- Calgary North
WHERE Name = 'Calgary North';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(53.546, -113.493, 4326) -- Edmonton South
WHERE Name = 'Edmonton South';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(49.895, -97.138, 4326) -- Winnipeg Central
WHERE Name = 'Winnipeg Central';

UPDATE Branch
SET SpatialLocation = GEOGRAPHY::Point(49.848, -99.953, 4326) -- Brandon West
WHERE Name = 'Brandon West';
GO

SELECT * FROM Branch;