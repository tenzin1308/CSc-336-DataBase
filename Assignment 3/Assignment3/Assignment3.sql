-- /**********************************************************************************************************************/
-- /*                                               Create Database                                                      */
-- /**********************************************************************************************************************/

-- IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Assignment3') 
-- BEGIN
--     USE master;
--     ALTER DATABASE Assignment3 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--     DROP DATABASE Assignment3;
--     CREATE DATABASE Assignment3;
--     END
-- GO

use Assignment3;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE NAME = 'Printers') DROP TABLE Printers
IF EXISTS (SELECT 1 FROM sys.tables WHERE NAME = 'Laptops') DROP TABLE Laptops
IF EXISTS (SELECT 1 FROM sys.tables WHERE NAME = 'PCs') DROP TABLE PCs
IF EXISTS (SELECT 1 FROM sys.tables WHERE NAME = 'Products') DROP TABLE Products
IF OBJECT_ID('dbo.Constraint1Ca') is NOT NULL DROP FUNCTION Constraint1Ca
IF OBJECT_ID('dbo.Constraint1Cb') is NOT NULL DROP FUNCTION Constraint1Cb
IF OBJECT_ID('dbo.Constraint1Cc') is NOT NULL DROP FUNCTION Constraint1Cc

GO

/**********************************************************************************************************************/
/*                                                    Constraint                                                      */
/**********************************************************************************************************************/

/* Constraint 1. C. a */
CREATE FUNCTION Constraint1Ca(@maker AS char, @type AS char(7))  RETURNS BIT 
AS 
BEGIN 
    DECLARE @Flag BIT=1
	DECLARE @check INT = (select COUNT(*) from Products)
	IF @check = 0 
	BEGIN
		SET @Flag = 1
		RETURN  @Flag
	END
	IF (@type = 'Laptop')
		BEGIN
		if(@maker IN (select maker from Products WHERE type = 'PC' ))
		BEGIN
			SET @Flag = 0
			RETURN  @Flag
		END
	END
		RETURN  @Flag
END
GO

/* Constraint 1. C. b */
CREATE FUNCTION Constraint1Cb(@maker AS char,@speed AS FLOAT, @type AS char(7))  RETURNS BIT 
AS 
BEGIN 
    DECLARE @Flag BIT= 1
	IF (@type = 'PCs')
		BEGIN
		if(@maker IN (select maker from PCs))
		BEGIN
			IF (@speed < (select speed from PCs AS speed))
			BEGIN
				SET @Flag = 0
				RETURN  @Flag
			END
		END
	END
	RETURN @Flag
END
GO

/* Constraint 1. C. c */
CREATE FUNCTION Constraint1Cc(@ram AS INT,@price AS FLOAT )
    RETURNS BIT 
AS 
BEGIN 
    DECLARE @Flag BIT=1
    If (@price > ALL (SELECT price FROM PCs WHERE ram < @ram  )) 
        SET @Flag =0
    RETURN  @Flag
END
GO
/**********************************************************************************************************************/
/*                                            Create Products Table                                                   */
/**********************************************************************************************************************/

-- ALTER TABLE Products 
--     ADD CONSTRAINT CheckConstraint1Ca CHECK(dbo.Constraint1Ca(maker,type)=1);

-- GO

/* Products Table */
CREATE TABLE Products(
    maker CHAR,
    model INT PRIMARY KEY,
    type CHAR (7) CHECK(type= 'PC' or type = 'Laptop' or type ='Printer')
    );
GO

INSERT INTO Products Values ('A',1001,'PC');
INSERT INTO Products Values ('A',1002,'PC');
INSERT INTO Products Values ('A',1003,'PC');
INSERT INTO Products Values ('A',2004,'Laptop');
INSERT INTO Products Values ('A',2005,'Laptop');
INSERT INTO Products Values ('A',2006,'Laptop');
INSERT INTO Products Values ('B',1004,'PC');
INSERT INTO Products Values ('B',1005,'PC');
INSERT INTO Products Values ('B',1006,'PC');
INSERT INTO Products Values ('B',2007,'Laptop');
INSERT INTO Products Values ('C',1007,'PC');
INSERT INTO Products Values ('D',1008,'PC'); 
INSERT INTO Products Values ('D',1009,'PC'); 
INSERT INTO Products Values ('D',1010,'PC');
INSERT INTO Products Values ('D',3004,'Printer');
INSERT INTO Products Values ('D',3005,'Printer');
INSERT INTO Products Values ('E',1011,'PC'); 
INSERT INTO Products Values ('E',1012,'PC'); 
INSERT INTO Products Values ('E',1013,'PC');
INSERT INTO Products Values ('E',2001,'Laptop'); 
INSERT INTO Products Values ('E',2002,'Laptop'); 
INSERT INTO Products Values ('E',2003,'Laptop');
INSERT INTO Products Values ('E',3001,'Printer'); 
INSERT INTO Products Values ('E',3002,'Printer'); 
INSERT INTO Products Values ('E',3003,'Printer');
INSERT INTO Products Values ('F',2008,'Laptop'); 
INSERT INTO Products Values ('F',2009,'Laptop'); 
INSERT INTO Products Values ('G',2010,'Laptop');
INSERT INTO Products Values ('H',3006,'Printer'); 
INSERT INTO Products Values ('H',3007,'Printer');

-- INSERT INTO Products Values ('G',4001,'Printer');

/* Display Products Table */
SELECT *
FROM Products
GO

-- /**********************************************************************************************************************/
-- /*                                                 Create PCs Table                                                   */
-- /**********************************************************************************************************************/

/*Table PCs */
CREATE TABLE PCs(
    model INT PRIMARY KEY REFERENCES Products(model),
    speed FLOAT,
    ram INT,
    hd INT,
    price FLOAT
    );
GO

/*
Insert into PCs table
*/
INSERT INTO PCs VALUES (1001,2.66,1024,250,2114);
INSERT INTO PCs VALUES (1002,2.10,512,250,995);
INSERT INTO PCs VALUES (1003,1.42,512,80,478);
INSERT INTO PCs VALUES (1004,2.80,1024,250,649);
INSERT INTO PCs VALUES (1005,3.20,512,250,630);
INSERT INTO PCs VALUES (1006,3.20,1024,320,1049);
INSERT INTO PCs VALUES (1007,2.20,1024,200,510);
INSERT INTO PCs VALUES (1008,2.20,2048,250,770);
INSERT INTO PCs VALUES (1009,2.00,1024,250,650);
INSERT INTO PCs VALUES (1010,2.80,2048,300,770);
INSERT INTO PCs VALUES (1011,1.86,2048,160,959);
INSERT INTO PCs VALUES (1012,2.80,1024,160,649);
INSERT INTO PCs VALUES (1013,3.06,512,80,529);

/* Display PCs Table */
SELECT Products.maker, PCs.model, PCs.speed, PCs.ram, PCs.hd, PCs.price
FROM Products JOIN PCs on Products.model = PCs.model
GO

-- /**********************************************************************************************************************/
-- /*                                              Create Laptops Table                                                  */
-- /**********************************************************************************************************************/

/*Table Laptop */
CREATE TABLE Laptops(
    model INT PRIMARY KEY REFERENCES Products(model),
    speed FLOAT,
    ram INT,
    hd INT,
    screen FLOAT,
    Price FLOAT);
GO
/* 
Alter Table Laptops
    ADD CONSTRAINT CheckConstraint1Cc CHECK(dbo.Constraint1Cc(ram, price) = 1);
GO
*/
/*
Insert into Laptops table
*/
INSERT INTO Laptops VALUES (2001,2.00,2048,240,20.1,3673);  
INSERT INTO Laptops VALUES (2002,1.73,1024,80,17.0,949);
INSERT INTO Laptops VALUES (2003,1.80,512,60,15.4,549);
INSERT INTO Laptops VALUES (2004,2.00,512,60,13.3,1150); 
INSERT INTO Laptops VALUES (2005,2.16,1024,120,17.0,2500); 
INSERT INTO Laptops VALUES (2006,2.00,2048,80,15.4,1700);
INSERT INTO Laptops VALUES (2007,1.83,1024,120,13.3,1429); 
INSERT INTO Laptops VALUES (2008,1.60,1024,100,15.4,900); 
INSERT INTO Laptops VALUES (2009,1.60,512,80,14.1,680); 
INSERT INTO Laptops VALUES (2010,2.00,2048,160,15.4,2300);

/* Display Laptops Table */
SELECT Products.maker, Laptops.model, Laptops.speed, Laptops.ram, Laptops.hd, Laptops.screen, Laptops.price
FROM Products JOIN Laptops on Products.model = Laptops.model
GO
-- /**********************************************************************************************************************/
-- /*                                             Create Printers Table                                                  */
-- /**********************************************************************************************************************/


/* Printers Table */
CREATE TABLE Printers(
    model INT PRIMARY KEY REFERENCES Products(model),
    color BIT NOT NULL,
    type CHAR (7) CHECK(type ='ink-jet' OR type='laser'),
    Price FLOAT);
GO

/*
Insert into Printer table
*/
INSERT INTO Printers VALUES (3001,1,'ink-jet',99);
INSERT INTO Printers VALUES (3002,0,'laser',239);
INSERT INTO Printers VALUES (3003,1,'laser',899);
INSERT INTO Printers VALUES (3004,1,'ink-jet',120);
INSERT INTO Printers VALUES (3005,0,'laser',120);
INSERT INTO Printers VALUES (3006,1,'ink-jet',100);
INSERT INTO Printers VALUES (3007,1,'laser',200);

/* Display Printers Table */
SELECT Products.maker, Printers.model, [Printers.color] = CASE WHEN Printers.color = 1 THEN 'true' ELSE 'false' END, Printers.type, Printers.price
FROM Products JOIN Printers on Products.model = Printers.model
GO

/**********************************************************************************************************************/
/*                                                      Queries                                                       */
/**********************************************************************************************************************/


/* 
Query: A) No manufacturer of PCs may also make laptops 
*/
SELECT DISTINCT Products.maker FROM Products where type IN ('PC')
AND Products.maker IN (	
SELECT maker FROM Products where type IN ('Laptop'));



/* 
Query: B) A manufacturer of a PC must also make a laptop with at least as great a processor 
*/
SELECT DISTINCT Products.maker
FROM
 (SELECT  R1.model AS PCModel,R1.maker,R1.speed AS PCSpeed, R2.speed AS LaptopSpeed
		FROM
		(SELECT  Products.maker, PCs.model, PCs.speed FROM Products, PCs) AS R1  JOIN
		(SELECT  Products.maker, Laptops.speed FROM Products, Laptops) AS R2 ON R1.maker = R2.maker AND R1.speed <= R2.speed) AS R3
		 JOIN 
		(SELECT  model FROM PCs) AS R4 ON R3.PCModel = R4.model  JOIN Products ON R3.PCModel = Products.model;


/* 
Query: C) If a laptop has a larger main memory than a PC, then the laptop must have a higher price than the PC. 
*/
SELECT Laptops.model AS 'Models'
FROM PCs, Laptops
WHERE Laptops.ram>PCs.ram AND Laptops.price <= PCs.price;


/*
Query: D) If the relation Products mentions a model and its type, then the model must also appear in the relation appropriate to that type.
*/
SELECT DISTINCT maker, model, type
FROM Products P
WHERE P.model NOT IN (
    SELECT PCs.model FROM PCs UNION SELECT Laptops.model FROM Laptops
    UNION
    SELECT Printers.model from Printers) ;

