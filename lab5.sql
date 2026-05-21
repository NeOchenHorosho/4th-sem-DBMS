USE ReportsDatabase -- 1. Многотабличный запрос выборки с сортировкой и отбором данных
SELECT
    r.report_id,
    r.report_title,
    r.creation_date,
    a.author_full_name
FROM
    Reports r
    INNER JOIN ReportAuthors a ON r.author_id = a.author_id
WHERE
    r.creation_date >= '2024-01-01'
ORDER BY
    r.creation_date DESC,
    r.report_title ASC;

-- 2. Запрос с применением вычисляемых полей
SELECT
    author_id,
    author_full_name,
    birth_date,
    DATEDIFF(YEAR, birth_date, GETDATE()) - CASE
        WHEN DATEADD(
            YEAR,
            DATEDIFF(YEAR, birth_date, GETDATE()),
            birth_date
        ) > CAST(GETDATE() AS DATE) THEN 1
        ELSE 0
    END AS author_age
FROM
    ReportAuthors;

-- 3. Запрос выборки с внешним объединением двух отношений
SELECT
    a.author_id,
    a.author_full_name,
    r.report_id,
    r.report_title
FROM
    Reports r
    LEFT JOIN ReportAuthors a ON a.author_id = r.author_id
ORDER BY
    a.author_full_name;

-- 4. Запрос с группировкой, вычислением итогов и отбором данных
SELECT
    a.author_id,
    a.author_full_name,
    COUNT(r.report_id) AS reports_count
FROM
    ReportAuthors a
    INNER JOIN Reports r ON a.author_id = r.author_id
GROUP BY
    a.author_id,
    a.author_full_name
ORDER BY
    reports_count DESC;

-- 5. Запрос на добавление
DECLARE @AuthorID INT;

INSERT INTO
    ReportAuthors (author_full_name, birth_date)
VALUES
    ('Philippov Maxim Alexandrovich', '1970-01-01');

SET
    @AuthorID = SCOPE_IDENTITY();

INSERT INTO
    Reports (report_title, author_id)
VALUES
    ('Report on Yan Sokolovskiy', @AuthorID),
    (
        'Report on Theoretical Study and Experimental Verification of Recognition Algorithms Based on the Measure of Precedence',
        @AuthorID
    ),
    (
        N'Report on Разработка игры в шведские шахматы с использованием искусственного интеллекта',
        @AuthorID
    );

-- 6. Запрос на удаление
DELETE FROM
    Reports
WHERE
    report_title = 'Report on Yan Sokolovskiy';

-- 7. Запрос на обновление
UPDATE
    Reports
SET
    report_title = 'Report on the update of the name of this report'
WHERE
    report_id = 1;

-- 8. Запрос на создание новой таблицы на основе существующей
SELECT
    r.report_id,
    r.report_title,
    r.creation_date,
    a.author_full_name INTO ReportsArchive
FROM
    Reports r
    INNER JOIN ReportAuthors a ON r.author_id = a.author_id
WHERE
    r.creation_date < '2027-01-01';

-- 9. Запрос на объединение UNION
SELECT
    report_id AS object_id,
    report_title AS object_title,
    creation_date,
    'report' AS object_type
FROM
    Reports
UNION
SELECT
    report_about_report_id AS object_id,
    report_about_report_title AS object_title,
    creation_date,
    'report about reports' AS object_type
FROM
    ReportsAboutReports;

-- 10. Вложенный запрос во фразе WHERE
SELECT
    report_id,
    report_title,
    creation_date,
    author_id
FROM
    Reports
WHERE
    author_id IN (
        SELECT
            author_id
        FROM
            ReportAuthors
        WHERE
            birth_date < '1990-01-01'
    );

-- 11. Запрос на создание новой таблицы
CREATE TABLE ReportCategories (
    category_id INT IDENTITY(1, 1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL UNIQUE,
    category_description NVARCHAR(300) NULL
);

-- 12. Запрос на создание представления, объединяющего данные двух таблиц
GO
    CREATE VIEW ViewReportsWithAuthors AS
SELECT
    r.report_id,
    r.report_title,
    r.creation_date,
    a.author_id,
    a.author_full_name,
    a.birth_date
FROM
    Reports r
    INNER JOIN ReportAuthors a ON r.author_id = a.author_id;

GO