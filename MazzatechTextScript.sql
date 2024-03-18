/************************************************** TABLES *************************************************/
/*
    Script for creating the database
    Here it will be checked if the database already exists
*/
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'MazzaTechTest')
BEGIN
    CREATE DATABASE MazzaTechTest;
    PRINT 'Banco de dados criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'O banco de dados já existe.';
END

-- Use the database "MazzatechTest" to create the following tables and execute other scripts
USE MazzatechTest;

/*
    Script for creating the table 'Category'
    The 'Id' field is auto-increment and primary key.
*/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Category')
BEGIN
    CREATE TABLE Category (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(MAX) NOT NULL,
        StartValue FLOAT,
        EndValue FLOAT
    );
    PRINT 'Tabela criada com sucesso.';
END
ELSE
BEGIN
    PRINT 'A tabela já existe.';
END

GO

IF EXISTS (SELECT * FROM Category)
BEGIN
	DELETE FROM Category;
END

-- Inserting current categories' rows for testing
INSERT INTO Category (Name, StartValue, EndValue) VALUES ('Low Value',	  0,		1000000);
INSERT INTO Category (Name, StartValue, EndValue) VALUES ('Medium Value', 1000000,  5000000);
INSERT INTO Category (Name, StartValue, EndValue) VALUES ('High Value',   5000000,  0);

GO

/*
	Script for creating the table 'FinancialInstrument'
	The 'Id' field is auto-increment and primary key.
	The 'CategoryId' field is a foreign key referencing the 'Id' field in the 'Category' table.
*/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'FinancialInstrument')
BEGIN
    CREATE TABLE FinancialInstrument (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Type VARCHAR(255) NOT NULL,
        MarketValue DECIMAL(18,2) NOT NULL,
        CategoryId INT NULL,
        FOREIGN KEY (CategoryId) REFERENCES Category(Id)
    );
    PRINT 'Tabela criada com sucesso.';
END
ELSE
BEGIN
    PRINT 'A tabela já existe.';
END

GO

/************************************************** PROCEDURES *************************************************/
/*
	Script for creating the procedure 'InsertFinancialInstrument'
	Procedure responsible for inserting into the 'FinancialInstrument' table 
	EXEC InsertFinancialInstrument 'TypeValue', 100.00, 1;
*/
-- Verify if the procedure 'InsertFinancialInstrument' exists
IF OBJECT_ID('InsertFinancialInstrument', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE InsertFinancialInstrument;
    PRINT 'Procedure InsertFinancialInstrument dropped successfully.';
END;

GO

CREATE PROCEDURE InsertFinancialInstrument
	@Type VARCHAR(255),
	@MarketValue DECIMAL(18,2)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CategoryId INT;
	DECLARE @CategoryName VARCHAR(255)

	-- Retrieve the category Id based on the Market value
	SELECT @CategoryId = Id,
			@CategoryName = Name
		FROM Category
		WHERE ( StartValue <= @MarketValue AND EndValue > @MarketValue) 
		OR ( StartValue <= @MarketValue AND EndValue = 0 );
			  
	-- Insert the new record into the FinancialInstrument table
	INSERT INTO FinancialInstrument (Type, MarketValue, CategoryId)
	VALUES (@Type, @MarketValue, @CategoryId);

END;

GO

PRINT 'Procedure InsertFinancialInstrument created successfully.';

GO

/*
	Script for creating the procedure 'ExtractInstrumentInfo'
	Procedure responsible for extracting the rows from the input
	INPUT: @InstrumentString
	OUTPUT: @MarketValue, @Type
	EXEC ExtractInstrumentInfo @InstrumentString, @MarketValue OUTPUT, @Type OUTPUT;
*/
IF OBJECT_ID('ExtractInstrumentInfo', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE ExtractInstrumentInfo;
    PRINT 'Procedure ExtractInstrumentInfo dropped successfully.';
END;

GO

CREATE PROCEDURE ExtractInstrumentInfo
    @InstrumentString NVARCHAR(MAX),
    @MarketValue DECIMAL(18, 2) OUTPUT,
    @Type NVARCHAR(255) OUTPUT
AS
BEGIN
    DECLARE @MarketValueStart INT, @MarketValueEnd INT, @TypeStart INT, @TypeEnd INT;

    -- Find the initial and final position of the marketValue value
    SET @MarketValueStart = CHARINDEX('marketValue = ', @InstrumentString) + LEN('marketValue = ');
    SET @MarketValueEnd = CHARINDEX(';', @InstrumentString, @MarketValueStart);

    -- Extract and convert the value of marketValue to decimal
    SET @MarketValue = CONVERT(DECIMAL(18, 2), REPLACE(SUBSTRING(@InstrumentString, @MarketValueStart, @MarketValueEnd - @MarketValueStart), ',', ''));

    -- Find the initial and final position of the Type value.
    SET @TypeStart = CHARINDEX('Type = "', @InstrumentString) + LEN('Type = "');
    SET @TypeEnd = CHARINDEX('"', @InstrumentString, @TypeStart);

    -- Extract the value of Type
    SET @Type = SUBSTRING(@InstrumentString, @TypeStart, @TypeEnd - @TypeStart);
END;

GO

PRINT 'Procedure ExtractInstrumentInfo created successfully.';
	
GO

/*
	Script for creating the procedure 'PrintCategories'
	Procedure responsible for printing the desired Output on the screen
	
	EXEC PrintCategories;
*/
IF OBJECT_ID('PrintCategories', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE PrintCategories;
    PRINT 'Procedure PrintCategories dropped successfully.';
END;

GO

CREATE PROCEDURE PrintCategories
AS
BEGIN	
	DECLARE @CategoryString NVARCHAR(MAX);
	DECLARE @Message NVARCHAR(MAX);

    DECLARE cursor_categories CURSOR FOR
    SELECT CA.Name
	  FROM FinancialInstrument AS FI
	 INNER JOIN Category AS CA ON CA.Id = FI.CategoryId
	 
	SET @Message = 'instrumentCategories = {';

    OPEN cursor_categories;
		
	FETCH NEXT FROM cursor_categories INTO @CategoryString;
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Message += '"' + @CategoryString + '"'

		FETCH NEXT FROM cursor_categories INTO @CategoryString;
		
		-- Check if it is the last FETCH
		IF @@FETCH_STATUS <> -1
		BEGIN
			SET @Message += ', '
		END;
	END;
	
	SET @Message += '}'

	PRINT @Message;

	CLOSE cursor_categories;
	DEALLOCATE cursor_categories;
END

GO

PRINT 'Procedure PrintCategories created successfully.';

GO

/*
	Script for creating the procedure 'CategorizingFinancialInstruments'
	Procedure responsible for inserting the financial instruments from the provided input
	
	EXEC CategorizingFinancialInstruments 'Instrument1 {marketValue =   800,000; Type = "Stock"}
		Instrument2 {marketValue = 1,500,000; Type = "Bond"}
		Instrument3 {marketValue = 6,000,000; Type = "Derivative"}
		Instrument4 {marketValue =   300,000; Type = "Stock"}';
*/
IF OBJECT_ID('CategorizingFinancialInstruments', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE CategorizingFinancialInstruments;
    PRINT 'Procedure CategorizingFinancialInstruments dropped successfully.';
END;

GO

CREATE PROCEDURE CategorizingFinancialInstruments
    @JsonString NVARCHAR(MAX)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Lines TABLE (Line NVARCHAR(MAX));
	
	-- Split the JSON string into lines and insert into the temporary table
    INSERT INTO @Lines (Line)
	SELECT NULLIF(REPLACE(REPLACE(value, CHAR(13), ''), CHAR(10), ''), '')
	FROM STRING_SPLIT(@JsonString, CHAR(10))
	WHERE value <> '';

    -- Parse each line and create a JSON object for each instrument
    DECLARE @Line NVARCHAR(MAX);
    DECLARE @MarketValue  DECIMAL(18, 2);
    DECLARE @Type NVARCHAR(MAX);
	DECLARE @InstrumentString NVARCHAR(MAX);
	
    DECLARE cursor_linhas CURSOR FOR
    SELECT Line
    FROM @Lines;

    OPEN cursor_linhas;

	FETCH NEXT FROM cursor_linhas INTO @InstrumentString;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Call the stored procedure for each line
		EXEC ExtractInstrumentInfo @InstrumentString, @MarketValue OUTPUT, @Type OUTPUT;
		
		IF @Type IS NOT NULL
		BEGIN
			-- Insert the new financial instrument into the table
			EXEC InsertFinancialInstrument @Type, @MarketValue;
		END;

		FETCH NEXT FROM cursor_linhas INTO @InstrumentString;
	END;

	CLOSE cursor_linhas;
	DEALLOCATE cursor_linhas;

	EXEC PrintCategories;
END;

go
    
PRINT 'Procedure CategorizingFinancialInstruments created successfully.';