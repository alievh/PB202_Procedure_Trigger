CREATE DATABASE ReservationManagement
USE ReservationManagement

CREATE TABLE Restaurants
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(255) NOT NULL UNIQUE,
	[Location] NVARCHAR(255) NOT NULL,
	Rating DECIMAL(18,1) NOT NULL
)

CREATE TABLE Tables
(
	Id INT PRIMARY KEY IDENTITY,
	TableNumber INT UNIQUE NOT NULL,
	Capacity INT NOT NULL,
	RestaurantId INT FOREIGN KEY REFERENCES Restaurants(Id)
)

CREATE TABLE Reservations
(
	Id INT PRIMARY KEY IDENTITY,
	CustomerName NVARCHAR(255) NOT NULL,
	ReservationDate DATETIME CHECK(ReservationDate > GETDATE()),
	IsActive BIT,
	TableId INT FOREIGN KEY REFERENCES Tables(Id)
)

INSERT INTO Restaurants (Name, Location, Rating) VALUES 
('Baku Grill', 'Baku', 4.5),
('MeatHouse', 'Baku', 2.4),
('Quzu', 'Baku', 3),
('Salam Baku', 'Baku', 3.5),
('Coffeemania', 'Baku', 5)


INSERT INTO Tables (RestaurantID, TableNumber, Capacity) VALUES 
(2, 1, 4), 
(3, 2, 6),
(1, 3, 8),
(4, 4, 4),
(5, 5, 2)


INSERT INTO Reservations (TableID, CustomerName, ReservationDate, IsActive) VALUES 
(2, 'Ali', '2024-11-25 23:00:00', 0),
(3, 'Vali', '2024-11-25 21:00:00', 1),
(1, 'Pirvali', '2024-11-25 20:00:00', 1),
(4, 'Samid', '2024-11-25 19:00:00', 1),
(5, 'Ziya', '2024-11-25 18:00:00', 0)

SELECT * FROM Restaurants r
JOIN Tables t ON t.RestaurantId = r.Id

CREATE PROCEDURE sp_AddReservation @TableId INT, @CustomerName NVARCHAR(255), @ReservationDate DATETIME
AS
IF EXISTS(
	SELECT * FROM Reservations r
	JOIN Tables t ON @TableId = r.TableId AND IsActive = 1
)
BEGIN
	PRINT('BU MASA ARTIQ REZERV OLUNUB')
END
ELSE
BEGIN
	INSERT INTO Reservations VALUES
	(@CustomerName, @ReservationDate, 1,@TableId)
	PRINT('MASANIZ REZERV OLUNDU')
END

DROP PROCEDURE sp_AddReservation

EXEC sp_AddReservation 5, 'Nihad', '2024-11-25 18:00:00'

SELECT * FROM Reservations

CREATE FUNCTION GetActiveCount (@TableId INT)
RETURNS INT
AS
BEGIN
DECLARE @count INT
SELECT @count=COUNT(r.IsActive) FROM Reservations r
JOIN Tables t ON t.Id = r.TableId WHERE IsActive = 1 AND r.TableId = @TableId
RETURN @count
END


DROP FUNCTION dbo.GetActiveCount

SELECT dbo.GetActiveCount(5)

CREATE VIEW GetRestaurantReserv
AS
SELECT rest.Name, t.TableNumber,r.IsActive FROM Reservations r
JOIN Tables t ON r.TableId = t.Id
JOIN Restaurants rest ON rest.Id = t.RestaurantId
WHERE IsActive = 1

SELECT * FROM GetRestaurantReserv


CREATE TABLE CancelledReservations
(
	Id INT PRIMARY KEY IDENTITY,
	TableNumber INT NOT NULL,
	CustomerName NVARCHAR(255) NOT NULL
)

CREATE TRIGGER trg_CancelReservation
ON Reservations
AFTER DELETE
AS
BEGIN
	INSERT INTO CancelledReservations (TableNumber, CustomerName)
	SELECT t.TableNumber, d.CustomerName
        FROM Deleted d
		JOIN Tables t ON t.Id = d.TableId

END

SELECT * FROM Reservations

DELETE Reservations WHERE Reservations.Id = 6

SELECT * FROM CancelledReservations