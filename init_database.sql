/*
================================================================================
Create Database and Schemas
================================================================================
Script Purpose:
      This Script creates a new database names 'DataWarehouse' after shceking if it already exists.
      If the database already exists, it is droppped and recreated. Additionally, the script set up
      three schemas within the database: 'Bronze','Silver' and 'Gold'

Warning:
      Running this script will drop the entire 'DataWarehouse' database if it exists.
      All the data in the databse will be permanently deleted. Proceed with the caution and ensure 
      you have proper backups before running this script
*/



USE master;

GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
     ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
     DROP DATABASE DataWarehouse;
END;

--Creating database 'DataWarehouse'
GO
CREATE DATABASE DataWarehouse;

--Use DataWarehouse
GO 
USE DataWarehouse;

--Create Schema
GO
CREATE SCHEMA bronze;

GO
CREATE SCHEMA silver;

GO
CREATE SCHEMA gold;
