use tempdb DROP DATABASE IF EXISTS ReportsDatabase;

CREATE DATABASE ReportsDatabase;

go
    USE ReportsDatabase;

CREATE TABLE ReportAuthors (
    author_id INT IDENTITY(1, 1) PRIMARY KEY,
    author_full_name NVARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    CONSTRAINT CHK_AuthorFullName_LIKE CHECK (author_full_name LIKE '% %')
);

CREATE INDEX haha ON ReportAuthors(author_full_name, birth_date);

CREATE TABLE Reports (
    report_id INT IDENTITY(1, 1) PRIMARY KEY,
    report_title NVARCHAR(200) NOT NULL,
    creation_date DATE NOT NULL DEFAULT GETDATE(),
    author_id INT NOT NULL,
    CONSTRAINT FK_Reports_Authors FOREIGN KEY (author_id) REFERENCES ReportAuthors(author_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX hahaha ON Reports(report_title);

CREATE TABLE ReportsAboutReports (
    report_about_report_id INT IDENTITY(1, 1) PRIMARY KEY,
    report_about_report_title NVARCHAR(200) NOT NULL,
    creation_date DATE NOT NULL DEFAULT GETDATE(),
    author_id INT NOT NULL,
    CONSTRAINT FK_ReportsAboutReports_Authors FOREIGN KEY (author_id) REFERENCES ReportAuthors(author_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX ha ON ReportsAboutReports(report_about_report_title);

CREATE TABLE Report_ReportsAboutReports_Links (
    report_about_report_id INT NOT NULL,
    report_id INT NOT NULL,
    CONSTRAINT PK_Report_ReportsAboutReports_Links PRIMARY KEY (report_about_report_id, report_id),
    CONSTRAINT FK_Links_ReportsAboutReports FOREIGN KEY (report_about_report_id) REFERENCES ReportsAboutReports(report_about_report_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Links_Reports FOREIGN KEY (report_id) REFERENCES Reports(report_id) ON DELETE CASCADE ON UPDATE CASCADE
);

DECLARE @AuthorID INT,
@ReportID INT,
@ReportAboutReportID INT;

INSERT INTO
    ReportAuthors (author_full_name, birth_date)
VALUES
    ('Nemo Right', '2000-01-01'),
    ('Yan Sokolovsky', '2007-06-01');

SET
    @AuthorID = SCOPE_IDENTITY();

INSERT INTO
    Reports (report_title, author_id)
VALUES
    ('Report on the fourth lab assignment', @AuthorID);

SET
    @ReportID = SCOPE_IDENTITY();

INSERT INTO
    ReportsAboutReports (report_about_report_title, author_id)
VALUES
    (
        'Comparative report of reports on the fourt lab assignment ',
        @AuthorID
    );

SET
    @ReportAboutReportID = SCOPE_IDENTITY();

INSERT INTO
    Report_ReportsAboutReports_Links (report_about_report_id, report_id)
VALUES
    (@ReportAboutReportID, @ReportID);