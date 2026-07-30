/*
=====================================================
Storage procedure: Load Bronze layer (Source > Bronze)
=====================================================
Purpose:
	This stored data from the source .csv files into bronze schema
	Script performs following function:
	-It truncate the table before new loading data
	-Use bulk insert

Usage Example:
	EXEC bronze.load_bronze;
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
/* Injection of the DATA into respective tables */
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_starttime DATETIME, @batch_endtime DATETIME;
	BEGIN TRY
		SET @batch_starttime = GETDATE();
		SET @start_time = GETDATE();
		PRINT 'LOADING DATA';
		PRINT '=======================================================';
		PRINT 'STARTING INJECTING DATA';
		PRINT '=======================================================';
		PRINT 'LOADING CRM DATA';

		TRUNCATE TABLE bronze.crm_cust_info;
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Ram\Desktop\Data analysis\Dashboard\data_warehouse\data\src_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '-----------------------------';
		SET @end_time = GETDATE();
		PRINT '--> Duration od Load: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' Seconds';
		PRINT '-----------------------------';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Ram\Desktop\Data analysis\Dashboard\data_warehouse\data\src_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '------------------------------';
		SET @end_time = GETDATE();
		PRINT '--> Duration of Load: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) as NVARCHAR) + ' Seconds';
		PRINT '------------------------------';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_sales_details;
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Ram\Desktop\Data analysis\Dashboard\data_warehouse\data\src_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '-------------------------------';
		SET @end_time = GETDATE();
		PRINT'--> Duration of load: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' Seconds';
		PRINT '-------------------------------';

		PRINT '=============================================================';
		PRINT 'LOADING ERP';
		PRINT '==============================================================';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Ram\Desktop\Data analysis\Dashboard\data_warehouse\data\src_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '-------------------------------';
		SET @end_time = GETDATE();
		PRINT '--> Duration of load: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' Seconds'; 
		PRINT '-------------------------------';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Ram\Desktop\Data analysis\Dashboard\data_warehouse\data\src_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '---------------------------------';
		SET @end_time = GETDATE();
		PRINT '--> Duration of load: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' Seconds'; 
		PRINT '---------------------------------';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Ram\Desktop\Data analysis\Dashboard\data_warehouse\data\src_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		PRINT '-----------------------------------';
		SET @end_time = GETDATE();
		PRINT '--> Duration of load: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' Seconds'; 
		PRINT '-----------------------------------';

		PRINT 'DONE LOADING';
		SET @batch_endtime = GETDATE();
		PRINT 'DURATION OF LOAD: ' + CAST(DATEDIFF(SECOND, @batch_starttime, @batch_endtime) as NVARCHAR) + ' Seconds';
	END TRY
	BEGIN CATCH
		PRINT '======================================';
		PRINT 'ERROR OCCUR DURING INJECTION OF DATA';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT '=======================================';
	END CATCH
END
