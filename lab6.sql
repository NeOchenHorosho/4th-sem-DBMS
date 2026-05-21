use tempdb DROP DATABASE IF EXISTS ViolenceDB;

CREATE DATABASE ViolenceDB;

go
    USE ViolenceDB;

CREATE TABLE PunishmentTypes (
    PunishmentTypeID INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL
);

CREATE TABLE ViolationTypes (
    ViolationTypeID INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    MinPunishmentID INT NOT NULL,
    MaxPunishmentID INT NOT NULL,
    CONSTRAINT FK_ViolationTypes_MinPunishment FOREIGN KEY (MinPunishmentID) REFERENCES PunishmentTypes(PunishmentTypeID),
    CONSTRAINT FK_ViolationTypes_MaxPunishment FOREIGN KEY (MaxPunishmentID) REFERENCES PunishmentTypes(PunishmentTypeID)
);

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1, 1) PRIMARY KEY,
    LastName NVARCHAR(100) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    Patronymic NVARCHAR(100) NULL,
    Position NVARCHAR(100) NULL,
    Department NVARCHAR(100) NULL
);

CREATE TABLE ViolationFacts (
    FactID INT IDENTITY(1, 1) PRIMARY KEY,
    DateTime DATETIME NOT NULL,
    Description NVARCHAR(MAX) NULL,
    IsCancelled BIT NOT NULL DEFAULT 0,
    CancellationDate DATETIME NULL,
    CancellationReason NVARCHAR(MAX) NULL,
    ViolationTypeID INT NOT NULL,
    CONSTRAINT FK_ViolationFacts_ViolationTypeID FOREIGN KEY (ViolationTypeID) REFERENCES ViolationTypes(ViolationTypeID)
);

CREATE TABLE ViolatorsAndPunishments (
    RecordID INT IDENTITY(1, 1) PRIMARY KEY,
    FactID INT NOT NULL,
    EmployeeID INT NOT NULL,
    PunishmentID INT NOT NULL,
    RemovalDate DATE NULL,
    CONSTRAINT FK_ViolatorsPunishments_Fact FOREIGN KEY (FactID) REFERENCES ViolationFacts(FactID),
    CONSTRAINT FK_ViolatorsPunishments_Employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_ViolatorsPunishments_Punishment FOREIGN KEY (PunishmentID) REFERENCES PunishmentTypes(PunishmentTypeID),
);

/* Были планы на 
 CONSTRAINT RightPunishmentID CHECK (PunishmentID IN (SELECT MinPunishmentID, MaxPunishmentID FROM ViolationTypes WHERE ViolationTypeId = (SELECT ViolationTypeID FROM ViolationFacts WHERE FactID = FactID))), 
 но проверки позваляют только скалярные выражения
 */
GO
    DECLARE @MinPunishmentID INT,
    @MaxPunishmentID INT,
    @ViolationTypeID INT,
    @ViolationFact INT,
    @EmployeeID INT;

INSERT INTO
    PunishmentTypes (Name)
VALUES
    ('Nothing');

SET
    @MinPunishmentID = SCOPE_IDENTITY();

INSERT INTO
    PunishmentTypes (Name)
VALUES
    ('Expulsion from the university');

SET
    @MaxPunishmentID = SCOPE_IDENTITY();

INSERT INTO
    ViolationTypes (Name, MinPunishmentID, MaxPunishmentID)
VALUES
    (
        'Expired dedline',
        @MinPunishmentID,
        @MaxPunishmentID
    )
Set
    @ViolationTypeID = SCOPE_IDENTITY();

INSERT INTO
    Employees(LastName, FirstName)
VALUES
    ('Sokolovskiy', 'Yan');

SET
    @EmployeeID = SCOPE_IDENTITY();

INSERT INTO
    ViolationFacts ([DateTime], ViolationTypeId)
VALUES
    (GETDATE(), @ViolationTypeID);

SET
    @ViolationFact = SCOPE_IDENTITY();

INSERT INTO
    ViolatorsAndPunishments (FactID, EmployeeID, PunishmentID)
VALUES
    (@ViolationFact, @EmployeeID, @MinPunishmentID);

INSERT INTO
    PunishmentTypes (Name)
VALUES
    (
        'Half-year torture and capital punishment (decapitation)'
    );

SET
    @MaxPunishmentID = SCOPE_IDENTITY();

INSERT INTO
    ViolationTypes (Name, MinPunishmentID, MaxPunishmentID)
VALUES
    (
        'Thoughtcrime',
        @MaxPunishmentID,
        @MaxPunishmentID
    )
Set
    @ViolationTypeID = SCOPE_IDENTITY();

INSERT INTO
    ViolationFacts ([DateTime], ViolationTypeId)
VALUES
    (GETDATE(), @ViolationTypeID);

SET
    @ViolationFact = SCOPE_IDENTITY();

INSERT INTO
    ViolatorsAndPunishments (FactID, EmployeeID, PunishmentID)
VALUES
    (@ViolationFact, @EmployeeID, @MaxPunishmentID);

INSERT INTO
    PunishmentTypes (Name)
VALUES
    ('eternal boulder rolling');

SET
    @MaxPunishmentID = SCOPE_IDENTITY();

INSERT INTO
    ViolationTypes (Name, MinPunishmentID, MaxPunishmentID)
VALUES
    (
        'cheating of death',
        @MinPunishmentID,
        @MaxPunishmentID
    )
Set
    @ViolationTypeID = SCOPE_IDENTITY();

INSERT INTO
    Employees(LastName, FirstName)
VALUES
    ('Sisyphus', 'Thessalian');

SET
    @EmployeeID = SCOPE_IDENTITY();

INSERT INTO
    ViolationFacts ([DateTime], ViolationTypeId)
VALUES
    ('1970-01-01T00:00:00', @ViolationTypeID);

SET
    @ViolationFact = SCOPE_IDENTITY();

INSERT INTO
    ViolatorsAndPunishments (FactID, EmployeeID, PunishmentID)
VALUES
    (@ViolationFact, @EmployeeID, @MaxPunishmentID);

-- 1. Многотабличный запрос выборки с сортировкой и отбором данных
SELECT
    vf.FactID,
    vf.DateTime,
    vf.Description,
    vt.Name AS violation_type,
    e.LastName,
    e.FirstName,
    e.Department,
    pt.Name AS punishment_name
FROM
    ViolationFacts vf
    INNER JOIN ViolationTypes vt ON vf.ViolationTypeID = vt.ViolationTypeID
    INNER JOIN ViolatorsAndPunishments vap ON vf.FactID = vap.FactID
    INNER JOIN Employees e ON vap.EmployeeID = e.EmployeeID
    INNER JOIN PunishmentTypes pt ON vap.PunishmentID = pt.PunishmentTypeID
WHERE
    vf.IsCancelled = 0
    AND vf.DateTime >= '2020-01-01'
ORDER BY
    vf.DateTime DESC,
    e.LastName ASC;

-- 2. Запрос с применением вычисляемых полей
SELECT
    FactID,
    DateTime,
    Description,
    DATEDIFF(DAY, DateTime, GETDATE()) AS days_since_violation,
    CASE
        WHEN IsCancelled = 1 THEN 'Violation canseled'
        ELSE 'Violation is not canceled'
    END AS violation_status
FROM
    ViolationFacts;

-- 3. Запрос выборки с внешним объединением двух отношений
SELECT
    e.EmployeeID,
    e.LastName,
    e.FirstName,
    e.Department,
    vap.RecordID,
    vap.FactID,
    vap.PunishmentID
FROM
    Employees e
    LEFT JOIN ViolatorsAndPunishments vap ON e.EmployeeID = vap.EmployeeID
ORDER BY
    e.LastName,
    e.FirstName;

-- 4. Запрос с группировкой, вычислением итогов и отбором данных
SELECT
    e.EmployeeID,
    e.LastName,
    e.FirstName,
    COUNT(vap.RecordID) AS punishments_count
FROM
    Employees e
    INNER JOIN ViolatorsAndPunishments vap ON e.EmployeeID = vap.EmployeeID
GROUP BY
    e.EmployeeID,
    e.LastName,
    e.FirstName
HAVING
    COUNT(vap.RecordID) >= 1
ORDER BY
    punishments_count DESC;

-- 5. Запрос на добавление
DECLARE @PunishmentID INT;

INSERT INTO
    PunishmentTypes (Name)
VALUES
    ('Execution by shooting');

SET
    @PunishmentID = SCOPE_IDENTITY();

INSERT INTO
    Employees (
        LastName,
        FirstName,
        Patronymic,
        Position,
        Department
    )
VALUES
    (
        'Collective',
        'Subconcious',
        'Humanitous',
        'world-shaper',
        'Faculty of applied math and computer science'
    );

SET
    @EmployeeID = SCOPE_IDENTITY();

INSERT INTO
    ViolationFacts ([DateTime], ViolationTypeId)
VALUES
    (GETDATE(), @ViolationTypeID);

SET
    @ViolationFact = SCOPE_IDENTITY();

INSERT INTO
    ViolatorsAndPunishments (FactID, EmployeeID, PunishmentID)
VALUES
    (@ViolationFact, @EmployeeID, @PunishmentID);

-- 6. Запрос на удаление
DELETE FROM
    ViolatorsAndPunishments
WHERE
    RecordID = 3;

-- 7. Запрос на обновление
UPDATE
    ViolationFacts
SET
    IsCancelled = 1,
    CancellationDate = GETDATE(),
    CancellationReason = 'One must image Sisyphus being happy'
WHERE
    FactID = 3;

-- 8. Запрос на создание новой таблицы на основе существующей
SELECT
    vf.FactID,
    vf.DateTime,
    vf.Description,
    vt.Name AS violation_type,
    vf.IsCancelled INTO ViolationFactsArchive
FROM
    ViolationFacts vf
    INNER JOIN ViolationTypes vt ON vf.ViolationTypeID = vt.ViolationTypeID;

-- 9. Запрос на объединение UNION
SELECT
    PunishmentTypeID AS object_id,
    Name AS object_name,
    N'punishment type' AS object_type
FROM
    PunishmentTypes
UNION
SELECT
    ViolationTypeID AS object_id,
    Name AS object_name,
    N'violation type' AS object_type
FROM
    ViolationTypes;

-- 10. Вложенный запрос во фразе WHERE
SELECT
    EmployeeID,
    LastName,
    FirstName,
    Department
FROM
    Employees
WHERE
    EmployeeID IN (
        SELECT
            EmployeeID
        FROM
            ViolatorsAndPunishments
        WHERE
            PunishmentID IN (
                SELECT
                    PunishmentTypeID
                FROM
                    PunishmentTypes
                WHERE
                    Name = 'Execution by shooting'
            )
    );

-- 11. Запрос на создание новой таблицы
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1, 1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL UNIQUE,
    DepartmentDescription NVARCHAR(300) NULL
);

-- 12. Запрос на создание индекса
CREATE INDEX IX_ViolationFacts_DateTime ON ViolationFacts (DateTime);

CREATE INDEX IX_ViolatorsAndPunishments_EmployeeID ON ViolatorsAndPunishments (EmployeeID);

-- 13. Запрос на создание представления, объединяющего данные двух таблиц
GO
    CREATE VIEW ViewEmployeesWithPunishments AS
SELECT
    e.EmployeeID,
    e.LastName,
    e.FirstName,
    e.Patronymic,
    e.Position,
    e.Department,
    vap.RecordID,
    vap.FactID,
    vap.PunishmentID,
    vap.RemovalDate
FROM
    Employees e
    INNER JOIN ViolatorsAndPunishments vap ON e.EmployeeID = vap.EmployeeID;

GO