DROP TABLE IF EXISTS unnormalized_data;
DROP TABLE IF EXISTS CRN_BOOKS_NF1;
DROP TABLE IF EXISTS Courses CASCADE;
DROP TABLE IF EXISTS Authors CASCADE;
DROP TABLE IF EXISTS Books_NF2 CASCADE;
DROP TABLE IF EXISTS CourseBooks;
DROP TABLE IF EXISTS BookAuthors;
DROP TABLE IF EXISTS Publishers;
DROP TABLE IF EXISTS Books_NF3;


CREATE TABLE unnormalized_data (
    CRN Integer not null,
    ISBN VARCHAR(13) not null,
    Title VARCHAR(100),
    Authors VARCHAR(100),
    Edition Integer,
    Publisher VARCHAR(100),
    Publisher_address VARCHAR(100),
    Pages Integer,
    Year INTEGER,
    Course_name VARCHAR(100),
    PRIMARY KEY (CRN, ISBN),
    CONSTRAINT negative_year CHECK( Year>0 )
);
COPY unnormalized_data (CRN, ISBN, Title, Authors, Edition, Publisher, Publisher_address, Pages, Year, Course_name) 
FROM 'C:\Users\Admin\Desktop\New_folder\Unnormalized_data.csv'
DELIMITER ','
CSV HEADER;

/*Create a table with loaded data in 1 Normalization form*/
CREATE TABLE CRN_BOOKS_NF1 AS
SELECT
    CRN,
    ISBN,
    Title,
    Author,
    Edition,
    Publisher,
    Publisher_address,
    Pages,
    Year,
    Course_name
FROM (
    SELECT *,
    UNNEST(string_to_array(Authors, ',')) AS author
    FROM unnormalized_data
);
ALTER TABLE CRN_BOOKS_NF1
ADD PRIMARY KEY (CRN, ISBN, Author);

/*Create tables for NF2*/
CREATE TABLE Courses AS
SELECT DISTINCT
    CRN,
    Course_name
FROM CRN_BOOKS_NF1;
ALTER TABLE Courses
ADD PRIMARY KEY(CRN);

/* added distinctive name for nf2 and nf3 books as this is the only table that both of them has and there is a difference between them*/
CREATE TABLE Books_NF2 AS
SELECT DISTINCT
    ISBN,
    Title,
    Edition,
    Publisher,
    Publisher_address,
    Pages,
    Year
FROM CRN_BOOKS_NF1;
ALTER TABLE Books_NF2
ADD PRIMARY KEY (ISBN);

CREATE TABLE Authors AS
SELECT DISTINCT
    Author as Author_Name
FROM CRN_BOOKS_NF1;
ALTER TABLE Authors
ADD AuthorID SERIAL PRIMARY KEY;

CREATE TABLE BookAuthors AS
SELECT DISTINCT
    ISBN,
	AuthorID
FROM CRN_BOOKS_NF1 as cb
JOIN Authors as a on cb.author = a.author_name;
ALTER TABLE BookAuthors
    ADD CONSTRAINT fk_isbn FOREIGN KEY (ISBN) REFERENCES Books_NF2 (ISBN),
    ADD CONSTRAINT fk_authorID FOREIGN KEY (AuthorID) REFERENCES Authors (AuthorID);

CREATE TABLE CourseBooks AS
SELECT DISTINCT
    ISBN,
    CRN
FROM CRN_BOOKS_NF1;
ALTER TABLE CourseBooks
    ADD CONSTRAINT fk_isbn FOREIGN KEY (ISBN) REFERENCES Books_NF2 (ISBN),
    ADD CONSTRAINT fk_CRN FOREIGN KEY (CRN) REFERENCES Courses (CRN);

CREATE TABLE Publishers AS
SELECT 
    DISTINCT (Publisher),
    Publisher_address
FROM CRN_BOOKS_NF1;

ALTER TABLE Publishers
ADD PRIMARY KEY (Publisher);

CREATE TABLE Books_NF3 as
SELECT 
    *
FROM Books_NF2;
ALTER TABLE Books_NF3
DROP COLUMN Publisher_address;
    