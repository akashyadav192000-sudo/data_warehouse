/*
===============================================================
Quality Checks
===============================================================
Script Purpose:
	This script performs various quality check fo data consistency,
	accuracy and standardization across silver schema.
	It checks:
	- Null or duplicate perimary keys
	- Unwanted spaces in strings
	- Data standardization and consistency
	- Invalid data ranges
	- Data consistency across the fields
Usages Notes:
	- Run these checks after loading silver layer.
	- Investigate and resolve any discrepency found during checks
*/

--Checking for deplicates
select * from
(
select 
*,
ROW_NUMBER() over (partition by cst_id order by cst_create_date DESC) as Flagged
from bronze.crm_cust_info
)t
where Flagged = 1; 


/* Partioning the customer_ID to check the duplicate entries ordered by Date of creation*/
select 
cst_id,
TRIM(cst_firstname),
TRIM(cst_lastname),
ROW_NUMBER() over (PARTITION BY cst_id ORDER BY cst_create_date) as Falgged
from bronze.crm_cust_info;


/* Counting the name which has extra space */
select count(cst_firstname) 
from bronze.crm_cust_info
where cst_firstname != TRIM(cst_firstname);

select count(cst_lastname)
from bronze.crm_cust_info
where cst_lastname != TRIM(cst_lastname);

select * from bronze.crm_cust_info;

/* Checking how many genders data do we have */
select cst_gndr, count(cst_gndr)
from bronze.crm_cust_info
group by cst_gndr;

/* Checking the marrital status */
select cst_marital_status, count(cst_marital_status) as Number
from bronze.crm_cust_info
group by cst_marital_status;

select * from 
(
select *, 
CASE
	WHEN cst_marital_status = 'M' THEN 'Married'
	ELSE 'Single'
END Marrital_status
from bronze.crm_cust_info
)t ;

SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
CASE
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	ELSE 'n/a'
END AS cst_marital_status,
CASE
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	ELSE 'n/a'
END AS cst_gndr,
cst_create_date
FROM bronze.crm_cust_info;

--Cheking for Duplicates in crm_prd_info
select top(100) * from bronze.crm_prd_info;

select * from bronze.crm_prd_info
where prd_key IS NULL;

SELECT * FROM(
SELECT prd_id, prd_key,
LEFT(prd_key,5) AS previous_prd_key,
REPLACE(LEFT(prd_key,5),'-','_') as prd_source from bronze.crm_prd_info
)t
WHERE previous_prd_key != TRIM(prd_source);

select * from bronze.crm_prd_info;
select top(100) * from bronze.erp_px_cat_g1v2;
select top(100) * from bronze.erp_cust_az12;
select top(100) * from bronze.crm_sales_details;
select top(100) * from bronze.crm_prd_info;

-- Deriving the sls_prd_key from prd_key column and replacing the character of key

select * from (
select prd_id,
REPLACE(LEFT(prd_key,5),'-','_') AS n_prd_key,
SUBSTRING(prd_key,7, len(prd_key)) as sls_prd_key, 
prd_nm,
prd_cost,
prd_line,
prd_start,
prd_end_dt
from bronze.crm_prd_info)t
where sls_prd_key NOT IN (select sls_prd_key from bronze.crm_sales_details);

-- Checking the duplicates of sls_prd_key

select distinct sls_prd_key, count(*) from bronze.crm_sales_details
group by sls_prd_key
HAVING count(*) > 1;


select prd_key, replace(SUBSTRING(prd_key,7,len(prd_key)), '-','_') as new_prd_key
from bronze.crm_prd_info;

--Checking the spaces in prd_nm column
select * from bronze.crm_prd_info
where trim(prd_nm) != prd_nm;

--Cheking the NULL value counts in the prd_cost column
select count(*) from bronze.crm_prd_info
where prd_cost IS NULL;

-- cheking the distinct prd_line and abbreviation
select distinct prd_line as prd_line,count(*) from bronze.crm_prd_info
group by prd_line
order by count(*);

-- Replacing the abbreviation with full form and assigning default value to NULL
select 
CASE UPPER(TRIM(prd_line))
	WHEN  'R' THEN 'Roads'
	WHEN  'M' THEN 'Mountains'
	WHEN 'S' THEN 'Other sales'
	WHEN  'T' THEN 'Touring'
	ELSE 'n/a'
END
from bronze.crm_prd_info;

--Fixing the date quality
select * from silver.crm_prd_info
where prd_key = 'HL-U509-R';

select * from silver.crm_prd_info
where prd_start > prd_end_dt;

select * from bronze.crm_sales_details;
select top(100) * from bronze.crm_cust_info;

--Cheking order number duplicates
select sls_ord_num, count(*) from bronze.crm_sales_details
group by sls_ord_num
having count(*) =1;

select * from (
select *, ROW_NUMBER() OVER (partition by sls_ord_num order by sls_order_dt) as flagged from bronze.crm_sales_details)t
where flagged = 1;

select * from bronze.crm_sales_details;


--Checking prd_key in crm_sales_details
select * from bronze.crm_sales_details
where sls_prd_key IN (select SUBSTRING(prd_key,7,len(prd_key)) as prd_key from bronze.crm_prd_info)
and sls_cust_id IN(select cst_id from bronze.crm_cust_info);

--Checking quality of date
select * from (
select *,try_cast(cast(sls_order_dt as varchar(8)) as date) as sls_order_date,
try_cast(cast(sls_ship_dt as varchar(8)) as date) as sls_ship_date
from bronze.crm_sales_details)t
where sls_order_date > sls_ship_date;

select * from bronze.crm_sales_details
where len(sls_order_dt) != 8 or sls_order_dt=0;

--checking sales number
select * from bronze.crm_sales_details
where sls_sales < 0;

select 
sls_sales as old_sls_sales,
case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity*sls_price then sls_quantity * abs(sls_price)
	 else sls_sales
end as sls_sales,
sls_quantity,
sls_price as old_sls_price,
case when sls_price is null or sls_price <= 0
	then abs(sls_sales)/sls_quantity
	else sls_price
end as sls_price
from bronze.crm_sales_details
where sls_quantity >1;

--checking erp_cust_az12 CID in cust_id from crm_cust_info
select * from (
select 
substring(CID, len(CID)-4, len(CID)) as CID
FROM bronze.erp_cust_az12)t
where CID IN (select cst_id from bronze.crm_cust_info);

--checking duplicate customer ID
select CID, count(*)
from bronze.erp_cust_az12
group by CID 
order by count(*);

--checking bdates
select * from bronze.erp_cust_az12
where BDATE < '1924-01-01' or BDATE > GETDATE();

--Cheking space in GEN
select GEN from bronze.erp_cust_az12
where trim(GEN) != GEN;

select sls_quantity from bronze.crm_sales_details
where sls_quantity <= 0 or sls_quantity is null;


-- checking GEN
select distinct GEN,
CASE
	WHEN GEN IS NULL OR GEN = '' THEN 'N/A'
	WHEN TRIM(UPPER(GEN)) = 'F' THEN 'Female'
	WHEN TRIM(UPPER(GEN)) = 'M' THEN 'Male'
	ELSE GEN
END AS GEN
from bronze.erp_cust_az12;

--cleaning of bronze.erp_loc_a101---------------------------------------------------------------------

--customer id
select CID,
SUBSTRING(CID, len(CID)-4, len(CID)) AS CID 
from bronze.erp_loc_a101;

select * from bronze.erp_loc_a101;
--checking loacation
select distinct CNTRY,
CASE WHEN CNTRY IS NULL OR CNTRY = '' THEN 'N/A'
	 WHEN CNTRY = 'US' OR CNTRY = 'USA' THEN 'United States'
	 WHEN CNTRY = 'DE' THEN 'Germany'
	 ELSE CNTRY
END AS cntry
from bronze.erp_loc_a101;

select * from silver.erp_loc_a101
where cid in (select distinct sls_cust_id from silver.crm_sales_details)

--validating data
select distinct sls_cust_id, count(*) from silver.crm_sales_details
group by sls_cust_id
order by count(*) DESC;

--
select * from bronze.erp_px_cat_g1v2
where ID NOT IN (select cat_id from silver.crm_prd_info);

