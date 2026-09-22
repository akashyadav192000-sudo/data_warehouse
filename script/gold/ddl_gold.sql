/*
=====================================================================================
DDL script- Gold Views
=====================================================================================
Purpose:
  Script is used to create views of gold layer in DataWarehouse
  It provide the transformed data which are ready for analysis and visualization
=====================================================================================
*/
/*
-------------------------------------------------------------------------------------
Create Dimension: gold.dim_customer
-------------------------------------------------------------------------------------
*/

CREATE VIEW gold.dim_customer AS
	SELECT 
		ROW_NUMBER() OVER (ORDER BY cs.cst_id) AS customer_key,
		cs.cst_id AS customer_id,
		cs.cst_key AS customer_number,
		CONCAT(cs.cst_firstname, ' ', cs.cst_lastname) AS customer_name,
		cs.cst_marital_status AS marital_status,
		CASE WHEN cs.cst_gndr != 'n/a' THEN cs.cst_gndr
			 ELSE COALESCE(ca.gen,'n/a')
		END AS gender,
		cr.country AS country,
		ca.bdate AS birthdate,
		cs.cst_create_date AS create_date
	FROM silver.crm_cust_info cs
	LEFT JOIN silver.erp_cust_az12 ca
		ON cs.cst_id = ca.cid
	LEFT JOIN silver.erp_loc_a101 cr
		ON cs.cst_id = cr.cid;

/*
-------------------------------------------------------------------------------------
Create Dimension: gold.dim_product
-------------------------------------------------------------------------------------
*/
CREATE VIEW gold.dim_products AS
	SELECT 
		ROW_NUMBER() OVER (ORDER BY sc.prd_start, sc.prd_id) AS product_key,
		sc.prd_id AS product_id,
		sc.prd_key AS product_number,
		sc.prd_nm AS product_name,
		sc.cat_id AS category_id,
		se.cat AS category,
		se.subcat AS subcategory,
		sc.prd_cost AS product_cost,
		sc.prd_line AS product_line,
		se.maintenance AS maintenance,
		sc.prd_start AS product_start_date	
	FROM silver.crm_prd_info AS sc
	LEFT JOIN silver.erp_px_cat_g1v2 se
		ON sc.cat_id = se.id
	WHERE sc.prd_end_dt IS NULL;

/*
-------------------------------------------------------------------------------------
Create Dimension: gold.facts_dim
-------------------------------------------------------------------------------------
*/
CREATE VIEW gold.facts_dim AS
	SELECT 
		sc.sls_ord_num AS order_number,
		gdc.customer_key AS customer_key,
		gdm.product_key AS product_key,
		CASE WHEN sc.sls_order_dt IS NULL THEN CAST(DATEADD(DAY,-6,sc.sls_ship_dt) AS DATE)
			 ELSE sc.sls_order_dt
		END AS order_date,
		sc.sls_ship_dt,
		sc.sls_due_dt,
		sc.sls_sales,
		sc.sls_quantity,
		sc.sls_price
	FROM silver.crm_sales_details sc
	LEFT JOIN gold.dim_products gdm
		ON sc.sls_prd_key = gdm.product_number
	LEFT JOIN gold.dim_customer gdc
		ON sc.sls_cust_id = gdc.customer_id;
