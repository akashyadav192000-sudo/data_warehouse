/* Loading clean data from brone to Silver layer */


CREATE OR ALTER PROCEDURE silver.load_silver AS
	BEGIN
	---------------------------------------------------------------------------------------------------
		DECLARE @start_time DATETIME, @end_time DATETIME, @full_start DATETIME, @full_end DATETIME;
		BEGIN TRY
		-----------------------------------------------------------------------------------------------
		SET @full_start = GETDATE();
			PRINT '----------------------------------------------------------';
			PRINT '>>>Truncating Data:silver.crm_cust_info';
			TRUNCATE TABLE silver.crm_cust_info;
			PRINT '>>>Inserting Data: silver.crm_cust_info';
			
			--Injection of clean data from bronze.crm_cust_info to Silver layer silver.crm_cust_info
			SET @start_time = GETDATE();
			INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
			select
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) as cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
				ELSE 'n/a'
			END as cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END as cst_gndr,
			cst_create_date
			FROM (
			select *,
			ROW_NUMBER() OVER (PARTITION BY cst_id order by cst_create_date DESC) AS flagged
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
			)t WHERE flagged = 1;
			SET @end_time = GETDATE();
		
			PRINT '>>>Duration of load:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 'seconds';
			PRINT '----------------------------------------------------------';
----------------------------------------------------------------------------------------------------------------------		


			PRINT '----------------------------------------------------------';
			PRINT '>>>Truncating Data:silver.crm_prd_info';
			TRUNCATE TABLE silver.crm_prd_info;
			PRINT '>>>Inserting Data: silver.crm_prd_info'
			
			--Injection of clean data from bronze.crm_prd_info to Silver layer silver.crm_prd_info
			SET @start_time = GETDATE();
			INSERT INTO silver.crm_prd_info( 
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start,
			prd_end_dt
			)
			select
			prd_id,
			REPLACE(LEFT(prd_key,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7, len(prd_key)) as prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) as prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountains'
				WHEN 's' THEN 'other sales'
				WHEN 'R' THEN 'Roads'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
			CAST(prd_start AS DATE) as prd_start_dt,
			DATEADD(DAY, -1, LEAD(prd_start) OVER (PARTITION BY prd_key ORDER BY prd_start)) AS prd_end_dt
			FROM bronze.crm_prd_info;
			SET @end_time = GETDATE();
			PRINT '>>>Duration of load:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 'seconds';
			PRINT '-------------------------------------------------------------';


			PRINT '-------------------------------------------------------------';
			PRINT '>>>Truncating Data:silver.crm_sales_detials';
			TRUNCATE TABLE silver.crm_sales_details;
			PRINT '>>>Inserting Data: silver.crm_sales_details';

			--Injection of clean data from bronze.crm_sales_details to Silver layer silver.crm_sales_details
			SET @start_time = GETDATE();
			INSERT INTO silver.crm_sales_details
			(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)
			SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN LEN(sls_order_dt) != 8 or sls_order_dt = 0 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR(8)) AS DATE)
			END AS sls_order_dt,
			CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) AS sls_ship_dt,
			CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) AS sls_due_dt,
			CASE	
				WHEN sls_sales IS NULL OR sls_sales <= 0 or sls_sales != sls_quantity * sls_price
				THEN sls_quantity*ABS(sls_price)
				ELSE sls_sales
			END AS  sls_sales,
			sls_quantity,
			CASE
				WHEN sls_price IS NULL or sls_price <= 0
				THEN ABS(sls_sales)/NULLIF(sls_quantity,0)
				ELSE sls_price
			END AS sls_price
			FROM bronze.crm_sales_details;
			SET @end_time = GETDATE();
			PRINT '>>>Duration of load:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 'seconds';
			PRINT '-------------------------------------------------------------';


			PRINT '-------------------------------------------------------------';
			PRINT '>>>Truncating Data:silver.erp_cust_az12';
			TRUNCATE TABLE silver.erp_cust_az12;
			PRINT '>>>Inserting Data: silver.erp_cust_az12';

			----Injection of clean data from bronze.erp_cust_az12 to Silver layer silver.erp_cust_az12
			SET @start_time = GETDATE();
			INSERT INTO silver.erp_cust_az12
			(
			cid,
			bdate,
			gen
			)
			SELECT
			SUBSTRING(CID, LEN(CID)-4, LEN(CID)) AS CID,
			CASE 
				WHEN BDATE > GETDATE() THEN NULL
				ELSE BDATE
			END AS BDATE,
			CASE WHEN GEN IS NULL OR GEN = '' THEN 'N/A'
				 WHEN GEN ='F' THEN 'Female'
				 WHEN GEN = 'M' THEN 'Male' 
				 ELSE GEN
				 END AS GEN
			FROM bronze.erp_cust_az12;
			SET @end_time = GETDATE();
			PRINT '>>>Duration of load:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 'seconds';
			PRINT '-------------------------------------------------------------';

			
			PRINT '-------------------------------------------------------------';
			PRINT '>>>Truncating Data:silver.erp_loc_a101';
			TRUNCATE TABLE silver.erp_loc_a101;
			PRINT '>>>Inserting Data: silver.erp_loc_a101';

			--Loading silver.erp_loc_a101
			SET @start_time = GETDATE();
			INSERT INTO silver.erp_loc_a101(
			cid,
			country
			)
			SELECT 
			SUBSTRING(CID, LEN(CID)-4, LEN(CID)) AS cid,
			CASE WHEN CNTRY IS NULL OR CNTRY = '' THEN 'N/A'
				 WHEN CNTRY = 'US' OR CNTRY = 'USA' THEN 'United States'
				 WHEN CNTRY = 'DE' THEN 'Germany'
				 ELSE CNTRY
			END AS cntry
			FROM bronze.erp_loc_a101;
			SET @end_time = GETDATE();
			PRINT '>>>Duration of load:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 'seconds';
			PRINT '-------------------------------------------------------------';


			PRINT '-------------------------------------------------------------';
			PRINT '>>>Truncating Data:silver.erp_px_cat_g1v2';
			TRUNCATE TABLE silver.erp_px_cat_g1v2;
			PRINT '>>>Inserting Data: silver.erp_px_cat_g1v2';

			--loading silver.erp_px_cat_g1v2
			SET @start_time = GETDATE();
			INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
			)
			SELECT 
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
			FROM bronze.erp_px_cat_g1v2;
			SET @end_time = GETDATE();
			PRINT '>>>Duration of load:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + 'seconds';
			PRINT '-------------------------------------------------------------';
		SET @full_end = GETDATE();
		PRINT '>>>Duration of load of Silver layer:' + CAST(DATEDIFF(SECOND, @full_start, @full_end) AS VARCHAR) + 'seconds';
		PRINT '-------------------------------------------------------------';

		END TRY
		BEGIN CATCH
			PRINT 'ERROR OCCUR DURING LOADING OF DATA';
			PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
			PRINT 'ERROR MESSAGE: ' + CAST(ERROR_NUMBER() AS VARCHAR);
			PRINT 'ERROR MESSAGE: ' + CAST(ERROR_STATE() AS VARCHAR);
			PRINT '==================================================';
		END CATCH
	END
