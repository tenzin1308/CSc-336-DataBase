--Sql Server 2014 Express Edition
--Batches are separated by 'go'

select @@version as 'sql server version'
Go

/* Function CheckPersonSex */
CREATE FUNCTION CheckPersonSex(@personId AS INT, @G as CHAR)
    RETURNS BIT
AS
BEGIN
    DECLARE @Flag BIT = 1
    IF (@G NOT IN (SELECT Sex FROM Persons WHERE Id = @personId))
        SET @Flag = 0
   RETURN @Flag
END;
GO

/* Table Persons */
CREATE TABLE Persons(
    Id INT PRIMARY KEY,
    Name VARCHAR(64),
    Sex CHAR CHECK(Sex = 'M' OR Sex = 'F'));

INSERT INTO Persons VALUES (1, 'Tenzin Tashi', 'M');
INSERT INTO Persons VALUES (2, 'Tsering Dolma', 'F');
INSERT INTO Persons VALUES (3, 'Jetsun Pema', 'F');
INSERT INTO Persons VALUES (4, 'Pasang Lama', 'F');
INSERT INTO Persons VALUES (5, 'James Lama', 'M');
INSERT INTO Persons VALUES (6, 'Jane Lama', 'F');
INSERT INTO Persons VALUES (7, 'Zoe Dunlap', 'F');
INSERT INTO Persons VALUES (8, 'Maximo Mingo', 'M');
INSERT INTO Persons VALUES (9, 'James Remo', 'M');
INSERT INTO Persons VALUES (10, 'Fletcher Copeland', 'M');
INSERT INTO Persons VALUES (11, 'Anula', 'M');
INSERT INTO Persons VALUES (12, 'Khanten Gurung', 'M');
INSERT INTO Persons VALUES (13, 'ROSE', 'F');
INSERT INTO Persons VALUES (14, 'WOOD', 'M');
INSERT INTO Persons VALUES (15, 'Ashley', 'F');
INSERT INTO Persons VALUES (16, 'Oscar', 'M');
INSERT INTO Persons VALUES (17, 'Sofi', 'F');
INSERT INTO Persons VALUES (18, 'Taylor', 'F');
INSERT INTO Persons VALUES (19, 'Natalie', 'F');
INSERT INTO Persons VALUES (20, 'Jackson', 'M');
INSERT INTO Persons VALUES (21, 'Paris', 'F');
INSERT INTO Persons VALUES (22, 'Tom', 'M');
INSERT INTO Persons VALUES (23, 'Mike', 'M');
INSERT INTO Persons VALUES (24, 'Emma', 'F');
INSERT INTO Persons VALUES (25, 'Liam', 'M');

/* Display Persons Tables */
SELECT *
FROM PERSONS;
GO

CREATE TABLE Family(
    personId INT Primary Key REFERENCES Persons(Id),
    fatherId INT REFERENCES Persons(Id),
    motherId INT REFERENCES Persons(Id));

ALTER TABLE Family
   ADD CONSTRAINT CheckFatherSex CHECK(dbo.CheckPersonSex(fatherId, 'M') = 1),
        CONSTRAINT CheckMotherSex CHECK(dbo.CheckPersonSex(motherId, 'F') = 1);

INSERT INTO Family VALUES (1, 11, 2);
INSERT INTO Family VALUES (3, 11, 2);
INSERT INTO Family VALUES (15, 11, 2);
INSERT INTO Family VALUES (4, 5, 6);
INSERT INTO Family VALUES (12, 11, 2);
INSERT INTO Family VALUES (11, 10, 7);
INSERT INTO Family VALUES (5, 10, 7);
INSERT INTO Family VALUES (2, 14, 13);
INSERT INTO Family VALUES (18, 22, 21);
INSERT INTO Family VALUES (23, 22, 21);
INSERT INTO Family VALUES (24, 22, 21);

/* Display Family Table with Names */
SELECT (SELECT Name FROM Persons WHERE Id = personId) AS 'Child',
       (SELECT Name FROM Persons WHERE Id = fatherId) AS 'Father',
       (SELECT Name FROM Persons WHERE Id = motherId) AS 'Mother'
FROM Family;
GO

CREATE TABLE Spouses(
    husbandId INT REFERENCES Persons(Id),
    wifeId INT REFERENCES Persons(Id),
    PRIMARY KEY (husbandId, wifeId));

ALTER TABLE Spouses
    ADD CONSTRAINT CheckHusbandSex CHECK(dbo.CheckPersonSex(husbandId, 'M') = 1),
        CONSTRAINT CheckWifeSex CHECK(dbo.CheckPersonSex(wifeId, 'F') = 1);

INSERT INTO Spouses VALUES (11, 2);
INSERT INTO Spouses VALUES (5, 6);
INSERT INTO Spouses VALUES (10, 7);
INSERT INTO Spouses VALUES (14, 13);
INSERT INTO Spouses VALUES (16, 15);
INSERT INTO Spouses VALUES (12, 17);
INSERT INTO Spouses VALUES (1, 18);
INSERT INTO Spouses VALUES (20, 19);
INSERT INTO Spouses VALUES (22, 21);
INSERT INTO Spouses VALUES (25, 24);

/* Display Spouses Table with names */
SELECT (SELECT Name FROM Persons WHERE Id = husbandId) AS 'Husband', 
       (SELECT Name FROM Persons WHERE Id = wifeId) AS 'Wife'
FROM Spouses;
GO




/* Table Brothers */
CREATE TABLE Brothers(
    childId INT REFERENCES Persons(Id),
    brotherId INT REFERENCES Persons(Id),
    PRIMARY KEY (childId, brotherId));

INSERT INTO Brothers
SELECT F1.personId AS 'childId', F2.personId AS 'brotherId'
FROM (SELECT * FROM Family WHERE personID IN (SELECT Id FROM Persons WHERE Sex = 'M')) F1,
     (SELECT * FROM Family WHERE personID IN (SELECT Id FROM Persons WHERE Sex = 'M')) F2
WHERE F1.fatherId = F2.fatherId AND F1.MotherId = F2.MotherId AND F1.personId <> F2.personId;

/* Display Brothers Table with Names */
SELECT (SELECT Name FROM Persons WHERE Id = childId) AS 'Brother',
       (SELECT Name FROM Persons WHERE Id = brotherId) AS 'Brother'
FROM Brothers;
GO


/* Table Sisters */
CREATE TABLE Sisters(
    childId INT REFERENCES Persons(Id),
    sisterId INT REFERENCES Persons(Id),
    PRIMARY KEY (childId, sisterId));

INSERT INTO Sisters
SELECT F1.personId AS 'childId', F2.personId AS 'sisterId'
FROM (SELECT * FROM Family WHERE personID IN (SELECT Id FROM Persons WHERE Sex = 'F')) F1,
     (SELECT * FROM Family WHERE personID IN (SELECT Id FROM Persons WHERE Sex = 'F')) F2
WHERE F1.fatherId = F2.fatherId AND F1.MotherId = F2.MotherId AND F1.personId <> F2.personId;

/* Display Sisters Table with Names */
SELECT (SELECT Name FROM Persons WHERE Id = childId) AS 'Sister',
       (SELECT Name FROM Persons WHERE Id = sisterId) AS 'Sister'
FROM Sisters;
GO

/* Table Brother-Sisters */
CREATE TABLE BrotherSisters(
    brotherId INT REFERENCES Persons(Id),
    sisterId INT REFERENCES Persons(Id),
    PRIMARY KEY (brotherId, sisterId));

INSERT INTO BrotherSisters
SELECT F1.personId AS 'brotherId', F2.personId AS 'sisterId'
FROM (SELECT * FROM Family WHERE personID IN (SELECT Id FROM Persons WHERE Sex = 'M')) F1,
     (SELECT * FROM Family WHERE personID IN (SELECT Id FROM Persons WHERE Sex = 'F')) F2
WHERE F1.fatherId = F2.fatherId AND F1.MotherId = F2.MotherId AND F1.personId <> F2.personId;

/* Display BrotherSisters Table with Names */
SELECT (SELECT Name FROM Persons WHERE Id = brotherId) AS 'Brother',
       (SELECT Name FROM Persons WHERE Id = sisterId) AS 'Sister'
FROM BrotherSisters;
GO

/* Query: Children of a Couple */
DECLARE @spouse1Id INT = 11
DECLARE @spouse2Id INT = 2
SELECT Name AS 'Child', Sex
FROM Persons
WHERE Id IN (SELECT personId
             FROM Family
             WHERE fatherId = @spouse1Id AND motherId = @spouse2Id
                   OR
                   fatherId = @spouse2Id AND motherId = @spouse1Id);
                   
                   
/* Query: Nephews of a given person */
DECLARE @personId INT = 5
SELECT Name AS 'Nephew', Sex
FROM Persons
WHERE Id IN (SELECT personId 
             FROM Family F1 
             WHERE F1.fatherId IN (SELECT brotherId 
                                   FROM Brothers F2 
                                   WHERE F2.childId = @personId and Sex = 'M'));
GO
             
/* Query: Grandparents of a given person */
DECLARE @personId INT = 1
SELECT Name AS 'Child',
       (SELECT Name FROM Persons WHERE Id IN
               (SELECT fatherId FROM Family F2 WHERE F2.personId IN
                       (SELECT fatherId FROM Family F1 WHERE F1.personId = @personId))) AS 'Paternal Grandfather',
       (SELECT Name FROM Persons WHERE Id IN
               (SELECT motherId FROM Family F2 WHERE F2.personId IN
                       (SELECT fatherId FROM Family F1 WHERE F1.personId = @personId))) AS 'Paternal Grandmother',
       (SELECT Name FROM Persons WHERE Id IN
               (SELECT fatherId FROM Family F2 WHERE F2.personId IN
                       (SELECT motherId FROM Family F1 WHERE F1.personId = @personId))) AS 'Maternal Grandfather',
       (SELECT Name FROM Persons WHERE Id IN
               (SELECT motherId FROM Family F2 WHERE F2.personId IN
                       (SELECT motherId FROM Family F1 WHERE F1.personId = @personId))) AS 'Maternal Grandmother'

FROM Persons
WHERE Id = @personId;
GO

/* Query: brother-in-law of a given person */
DECLARE @personId INT = 1
SELECT Name AS 'Brother In Law'
FROM Persons
WHERE Id IN ((SELECT husbandId FROM Spouses F2 WHERE F2.wifeId IN
                       (SELECT sisterId FROM BrotherSisters F1 WHERE F1.brotherId = @personId)),
            (SELECT husbandId FROM Spouses F2 WHERE F2.wifeId IN
                       (SELECT sisterId FROM Sisters F1 WHERE F1.childId = @personId)),
            (SELECT husbandId FROM Spouses F3 WHERE F3.wifeId IN
                       (SELECT sisterId FROM Sisters F2 WHERE F2.childId IN
                               (SELECT wifeId FROM Spouses F1 WHERE F1.husbandId = @personId))),
            (SELECT husbandId FROM Spouses F3 WHERE F3.wifeId IN
                       (SELECT sisterId FROM BrotherSisters F2 WHERE F2.brotherId IN
                               (SELECT husbandId FROM Spouses F1 WHERE F1.wifeId = @personId))),
            (SELECT brotherId FROM BrotherSisters F2 WHERE F2.sisterId IN
                       (SELECT wifeId FROM Spouses F1 WHERE F1.husbandId = @personId)),
            (SELECT brotherId FROM Brothers F2 WHERE F2.childId IN
                       (SELECT husbandId FROM Spouses F1 WHERE F1.wifeId = @personId)));
                               
                               
GO














