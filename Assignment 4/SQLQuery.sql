

USE Assignment4;
GO


IF OBJECT_ID('dob.Trips072013') IS NOT NULL DROP View Trips072013
IF OBJECT_ID('dob.StartStation072013') IS NOT NULL DROP View StartStation072013
IF OBJECT_ID('dob.DayStatistics072013') IS NOT NULL DROP View DayStatistics072013
IF OBJECT_ID('dob.GenderStatistics072013') IS NOT NULL DROP View GenderStatistics072013
IF OBJECT_ID('dob.AgeStatistics072013') IS NOT NULL DROP View AgeStatistics072013
IF OBJECT_ID('dob.MostFrequentTrip072013') IS NOT NULL DROP View MostFrequentTrip072013
IF OBJECT_ID('dob.DormantStations072013') IS NOT NULL DROP View DormantStations072013
IF OBJECT_ID('dob.VacantStations072013') IS NOT NULL DROP View VacantStations072013
-- IF EXISTS(SELECT 1 FROM sys.tables WHERE NAME = 'CitiBike072013') DROP TABLE CitiBike072013
IF EXISTS(SELECT 1 FROM sys.tables WHERE NAME = 'Stations') DROP TABLE Stations
IF EXISTS(SELECT 1 FROM sys.tables WHERE NAME = 'Trips') DROP TABLE Trips
IF EXISTS(SELECT 1 FROM sys.tables WHERE NAME = 'UsageByDay') DROP TABLE UsageByDay
IF EXISTS(SELECT 1 FROM sys.tables WHERE NAME = 'UsageByGender') DROP TABLE UsageByGender
IF EXISTS(SELECT 1 FROM sys.tables WHERE NAME = 'UsageByAge') DROP TABLE UsageByAge
GO


/*------------------------------------------CitiBike Table------------------------------------------*/

/* Citi Bike statistics for July 2003: Table CitiBike072013 */
-- CREATE TABLE CitiBike072013(
--     TripDuration FLOAT,
--     StartTime VARCHAR(30),
--     StartDay VARCHAR(9) DEFAULT NULL,
--     EndTime VARCHAR(30),
--     EndDay VARCHAR(9) DEFAULT NULL,
--     StartStationId INT,
--     StartStationName VARCHAR(64),
--     StartStationLatitude FLOAT,
--     StartStationLongitute FLOAT,
--     EndStationId INT,
--     EndStationName VARCHAR(64),
--     EndStationLatitude FLOAT,
--     EndStationLongitute FLOAT,
--     BikeId INT,
--     UserType VARCHAR(10),
--     BirthYear VARCHAR(4),
--     Gender INT
-- );

-- BULK INSERT CitiBike072013
-- FROM '/2013-07\ -\ Citi\ Bike\ trip\ data.txt'
-- WITH (FIELDTERMINATOR = '\t',
--       ROWTERMINATOR = '\n',
--       FIRSTROW = 2);

-- /* Pupulate StartDay and EndDay fields */
-- UPDATE CitiBike072013
--     SET StartDay = DATENAME(WEEKDAY, StartTime),
--         EndDay = DATENAME(WEEKDAY, EndTime);
-- GO

/* Display CitiBike072013 data */
SELECT *
FROM CitiBike072013;
GO


/*------------------------------------------Stations Table------------------------------------------*/

/* Create Stations Table */
CREATE TABLE Stations (
        Id INT,
        Name VARCHAR(64),
        Latitude FLOAT,
        Longitute FLOAT
);

/* Bike Station data: Partition StartStation072013 */
WITH StartStation072013 AS (
SELECT  StartStationId AS 'Station Id', StartStationName AS 'Name', StartStationLatitude AS 'Latitude', StartStationLongitude AS 'Longitude',
        ROW_NUMBER() OVER(PARTITION BY StartStationId
                            ORDER BY StartStationId) AS RowNumber
FROM    CitiBike072013)

/* Insert into Stations Table from the Partition */
INSERT INTO Stations (Id, Name, Latitude, Longitute)
SELECT [Station Id], Name, Latitude, Longitude
FROM StartStation072013
WHERE RowNumber = 1;
GO

/* Display Stations data */
SELECT DISTINCT * FROM Stations
ORDER BY Id;
GO

/*------------------------------------------Trips Table------------------------------------------*/

/* Create Trips Table */
CREATE TABLE Trips (
        StationId INT,
        MinTripDuration INT,
        MaxTripDuration INT,
        AvgTripDuration FLOAT,
        NumberOfStartUsers INT,
        NumberOfReturnUsers INT
);

/* Trip statistics partition Trips072013 */
WITH Trips072013 AS(
SELECT S.[Station ID], S.[Minimum Trip Duration], S.[Maximum Trip Duration], S.[Average Trip Duration],
       S.[Number of Start Users], T.[Number of Return Users]
FROM    (SELECT DISTINCT StartStationId AS 'Station ID',
                MIN(TripDuration) OVER(PARTITION BY StartStationId) AS 'Minimum Trip Duration',
                MAX(TripDuration) OVER(PARTITION BY StartStationId) AS 'Maximum Trip Duration',
                AVG(TripDuration) OVER(PARTITION BY StartStationId) AS 'Average Trip DUration',
                COUNT(*) OVER(PARTITION BY StartStationId) AS 'Number of Start Users'
        From CitiBike072013) S
        INNER JOIN
        (SELECT DISTINCT EndStationId AS 'Station Id',
                COUNT(*) OVER(PARTITION BY EndStationId) AS 'Number of Return Users'
        FROM CitiBike072013) T
        ON S.[Station ID] = T.[Station Id]
)

/* Insert into Trips Table from the Partition */
INSERT INTO Trips (StationId, MinTripDuration, MaxTripDuration, AvgTripDuration, NumberOfStartUsers, NumberOfReturnUsers)
SELECT *
FROM Trips072013
ORDER BY [Station ID];

/* Display Trips data */
SELECT StationId AS 'Station Id', MinTripDuration AS 'Minimum Trip Duration', MaxTripDuration AS 'Maximum Trip Duration', AvgTripDuration AS 'Average Trip Duration', NumberOfStartUsers AS 'Number of Start Users', NumberOfReturnUsers AS 'Number of Return Users'
FROM Trips;
GO


/*------------------------------------------UsageByDay Table------------------------------------------*/

/* Create UsageByDay Table */
CREATE TABLE UsageByDay(
        StationId INT,
        NumberUsersWeekday INT,
        NumberUsersWeekend INT
);

/* User Statistics by weekday/weekend: Partition DayStatistics072013 */
WITH DayStatistics072013 AS(
SELECT R.Id AS 'Station Id', MAX(R.MondayUsers) + MAX(R.TuesdayUsers) + MAX(R.WednesdayUsers) + MAX(R.ThursdayUsers) + MAX(R.FridayUsers) AS 'Weekday Users',
                             MAX(R.SaturdayUsers) + MAX(R.SundayUsers) AS 'Weekend Users'
FROM    (SELECT StartStationId AS 'Id',
                [MondayUsers] = CASE WHEN StartDay = 'Monday' THEN COUNT(*) OVER(PARTITION BY StartStationId, StartDay) END,
                [TuesdayUsers] = CASE WHEN StartDay = 'Tuesday' THEN COUNT(*) OVER(PARTITION BY StartStationId, StartDay) END,
                [WednesdayUsers] = CASE WHEN StartDay = 'Wednesday' THEN COUNT(*) OVER(PARTITION BY StartStationId, StartDay) END,
                [ThursdayUsers] = CASE WHEN StartDay = 'Thursday' THEN COUNT(*) OVER(PARTITION BY StartStationId, StartDay) END,
                [FridayUsers] = CASE WHEN StartDay = 'Friday' THEN COUNT(*) OVER(PARTITION BY StartStationId, StartDay) END,
                [SaturdayUsers] = CASE WHEN StartDay = 'Saturday' THEN COUNT(*) OVER(PARTITION BY StartStationId, StartDay) END,
                [SundayUsers] = CASE WHEN StartDay = 'Sunday' THEN COUNT(*) OVER(PARTITION BY StartStationId, StartDay) END
        FROM CitiBike072013) R
GROUP BY R.Id)


/* Insert into UsageByDay Table */
INSERT INTO UsageByDay (StationId, NumberUsersWeekday, NumberUsersWeekend)
SELECT *
FROM DayStatistics072013
ORDER BY [Station Id];

/* Display UsageByDay data */
SELECT StationId AS 'Station Id', NumberUsersWeekday AS 'Weekday Users', NumberUsersWeekend AS 'Weekend Users'
FROM UsageByDay
GO


/*------------------------------------------UsageByGender Table------------------------------------------*/

/* Create UsageByGender Table */
CREATE TABLE UsageByGender(
        StationId INT,
        NumberMaleUsers INT,
        NumberFemaleUsers INT,
        UnidentifiedUsers INT
);

/* User Statistics by gender: Partition UsageByGender */
WITH GenderStatistics072013 AS(
SELECT R.Id AS 'Station Id', MAX(R.MaleUsers) AS 'Male Users', MAX(R.FemaleUsers) AS 'Female Users', MAX(R.UnidentifiedUsers) AS 'Unidentified Users'
FROM    (SELECT StartStationId AS 'Id',
                [MaleUsers] = CASE WHEN Gender = 1 THEN COUNT(*) OVER(PARTITION BY StartStationId, Gender) END,
                [FemaleUsers] = CASE WHEN Gender = 2 THEN COUNT(*) OVER(PARTITION BY StartStationId, Gender) END,
                [UnidentifiedUsers] = CASE WHEN Gender = 0 THEN COUNT(*) OVER(PARTITION BY StartStationId, Gender) END
        FROM CitiBike072013) R
GROUP BY R.Id)

INSERT INTO UsageByGender (StationId, NumberMaleUsers, NumberFemaleUsers, UnidentifiedUsers)
SELECT *
FROM GenderStatistics072013
ORDER BY [Station Id];

/* Display UsageByGender data */
SELECT StationId AS 'Station Id', NumberMaleUsers AS 'Male Users', NumberFemaleUsers AS 'Female Users', UnidentifiedUsers AS 'Unidentified Users'
FROM UsageByGender
ORDER BY [Station Id];
GO

/*------------------------------------------UsageByAge Table------------------------------------------*/

/* Create UsageByAge Table */
CREATE TABLE UsageByAge(
        StationId INT, 
        NumberUsersUnder18 INT, 
        NumberUsers18To40 INT, 
        NumberUsersOver40 INT
);

/* User Statistics by age group: Partition AgeStatistics072013 */
DECLARE @YearStartTime INT = 2013;
WITH AgeStatistics072013 AS (
SELECT S.Id AS 'Station Id', SUM(S.A) AS 'User Under 18 Years Old', SUM(S.B) AS 'User 18-40 Years Old', SUM(S.C) AS 'Users Over 40 Years Old'
FROM    (SELECT R.Id AS 'Id', MAX(R.UsersUnder18) AS A, MAX(R.Users18To40) AS B, MAX(R.UsersOver40) AS C
        FROM    (SELECT     StartStationId AS 'Id', BirthYear, 
                            [UsersUnder18] = CASE WHEN (BirthYear <> '\N' AND (@YearStartTime - CAST(BirthYear AS INT)) < 18) THEN COUNT(BirthYear) OVER(PARTITION BY StartStationId, BirthYear) END,
                            [Users18To40] = CASE WHEN (BirthYear <> '\N' AND (@YearStartTime - CAST(BirthYear AS INT)) >= 18 AND (@YearStartTime - CAST(BirthYear AS INT)) <= 40) THEN COUNT(BirthYear) OVER(PARTITION BY StartStationId, BirthYear) END,
                            [UsersOver40] = CASE WHEN (BirthYear <> '\N' AND (@YearStartTime - CAST(BirthYear AS INT)) > 40) THEN COUNT(BirthYear) OVER(PARTITION BY StartStationId, BirthYear) END
                FROM CitiBike072013) R
        GROUP BY R.Id, R.BirthYear) S  
GROUP BY S.Id)

/* Insert into UsageByAge Table */
INSERT INTO UsageByAge (StationId, NumberUsersUnder18, NumberUsers18To40, NumberUsersOver40)
SELECT *
FROM AgeStatistics072013
ORDER BY [Station Id];

/* Display UsageByAge data */
SELECT StationId AS 'Station Id', NumberUsersUnder18 AS 'Users Under 18 Years Old', NumberUsers18To40 AS 'Users 18-40 Years Old', NumberUsersOver40 AS 'Users Over 40 Years Old'
FROM UsageByAge
GO


/*------------------------------------------Most frequent trips------------------------------------------*/

/* Most frequent trips between any two stations: Partition MostFrequentTrip072013 */
WITH MostFrequentTrip072013 AS(
SELECT StartStationId AS 'Start Station', EndStationId AS 'End Station', COUNT(*) AS 'Number of Trips',
       AVG(TripDuration) AS 'Average Trip Duration'
FROM CitiBike072013
GROUP BY StartStationId, EndStationId)

/* Display TOP(50) MostFrequentTrip072017 data */
SELECT TOP(50) *
FROM MostFrequentTrip072013
ORDER BY [Number of Trips] DESC, [Start Station];

/*------------------------------------------Dormant Station------------------------------------------*/

/* RED FLAG -- Dormant Station: All End Stations that are NOT Start Stations */
WITH DormantStations072013 AS(
SELECT  EndStationId AS 'Dormant Station', EndStationName AS 'Name', EndStationLatitude AS 'Latitude', 
        EndStationLongitude AS 'Longitude'
FROM    CitiBike072013
WHERE   EndStationId NOT IN (SELECT StartStationId
                             FROM   CitiBike072013))

/* Display Dormant Station */
SELECT *
FROM DormantStations072013
ORDER BY [Dormant Station];
GO

/*------------------------------------------Vacant Station------------------------------------------*/

/* RED FLAG -- Vacant Station: All Start Stations that are NOT End Stations will eventually become vacant */
WITH VacantStations072013 AS(
SELECT  StartStationId AS 'Vacant Station', StartStationName AS 'Name', StartStationLatitude AS 'Latitude', 
        StartStationLongitude AS 'Longitude'
FROM    CitiBike072013
WHERE   StartStationId NOT IN (SELECT EndStationId
                             FROM   CitiBike072013))

/* Display Vacant Station */
SELECT *
FROM VacantStations072013
ORDER BY [Vacant Station];
GO


/*------------------------------------------Alter Station Table to Add Zip Code------------------------------------------*/

/* Citi Bike statistics for July 2003: Table StationsZipcode */
-- CREATE TABLE StationsZipCode(
--     StationId INT,
--     StationName VARCHAR(64),
--     StationLatitude FLOAT,
--     StationLongitute FLOAT,
--     ZipCodes INT
-- );

-- BULK INSERT CitiBike072013
-- FROM '/StationsZipCode.csv'
-- WITH (FIELDTERMINATOR = ',',
--       ROWTERMINATOR = '\n',
--       FIRSTROW = 2);
-- GO

SELECT * FROM StationsZipCode

SELECT DISTINCT StationsZipCode.ZipCodes AS 'Zip Code', COUNT(*) AS 'Total Number of Trip'
FROM StationsZipCode, CitiBike072013
GROUP BY StationsZipCode.ZipCodes
ORDER BY [Total Number of Trip];
GO



