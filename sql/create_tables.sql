
USE CDI_Training;
GO

-- Create schemas
CREATE SCHEMA landing_layer;
GO

CREATE SCHEMA staging_layer;
GO

CREATE SCHEMA dwh_layer;
GO

-- Landing: latest source snapshot
CREATE TABLE landing_layer.Customer (
    Customer_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Customer_Name NVARCHAR(100) NULL,
    City NVARCHAR(100) NULL,
    Country NVARCHAR(100) NULL,
    Customer_Status VARCHAR(20) NULL,
    Hash_Key CHAR(32) NOT NULL
);
GO

-- Staging: SCD Type 2 history
CREATE TABLE staging_layer.Customers (
    Stage_SK BIGINT IDENTITY(1,1) PRIMARY KEY,
    Customer_ID VARCHAR(10) NOT NULL,
    Customer_Name NVARCHAR(100) NULL,
    City NVARCHAR(100) NULL,
    Country NVARCHAR(100) NULL,
    Customer_Status VARCHAR(20) NULL,
    Hash_Key CHAR(32) NOT NULL,
    Start_Date DATETIME2(3) NOT NULL,
    End_Date DATETIME2(3) NULL,
    Is_Current BIT NOT NULL,
    Is_Deleted BIT NOT NULL DEFAULT 0
);
GO

-- Customer dimension: synchronized historical versions
CREATE TABLE dwh_layer.Dim_Customers (
    Customer_SK BIGINT IDENTITY(1,1) PRIMARY KEY,
    Stage_SK BIGINT NOT NULL UNIQUE,
    Customer_ID VARCHAR(10) NOT NULL,
    Customer_Name NVARCHAR(100) NULL,
    City NVARCHAR(100) NULL,
    Country NVARCHAR(100) NULL,
    Customer_Status VARCHAR(20) NULL,
    Hash_Key CHAR(32) NOT NULL,
    Start_Date DATETIME2(3) NOT NULL,
    End_Date DATETIME2(3) NULL,
    Is_Current BIT NOT NULL,
    Is_Deleted BIT NOT NULL
);
GO
  
