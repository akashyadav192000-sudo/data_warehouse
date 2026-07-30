/*
This script create table in thr bronze shcema, dropping any existing table
*/

IF OBJECT_ID('bronze.crm_cust_info','u') IS NOT NULL
   drop table br.crm_cust_info;
GO
create table bronze.crm_cust_info(
cst_id  int,
cst_key varchar(50),
cst_firstname varchar(50),
cst_lastname varchar(50),
cst_marital_status varchar(50),
cst_gndr varchar(50),
cst_create_date date
);

GO

IF OBJECT_ID('bronze.crm_prd_info','u') IS NOT NULL
   drop table bronze.crm_prd_info;

GO

create table bronze.crm_prd_info(
prd_id int,
prd_key varchar(50),
prd_nm varchar(50),
prd_cost varchar(50),
prd_line varchar(50),
prd_start date,
prd_end_dt date
);

GO

IF OBJECT_ID('bronze.crm_sales_details','u') IS NOT NULL
   drop table bronze.crm_sales_details;

GO

create table bronze.crm_sales_details(
sls_ord_num varchar(50),
sls_prd_key varchar(50),
sls_cust_id int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
);

GO

IF OBJECT_ID('bronze.erp_cust_az12','u') IS NOT NULL
   drop table bronze.erp_cust_az12;
 
GO

create table bronze.erp_cust_az12(
CID varchar(50),
BDATE date,
GEN varchar(50)
);

GO

IF OBJECT_ID('bronze.erp_loc_a101','u') IS NOT NULL
   drop table bronze.erp_loc_a101;

GO

create table bronze.erp_loc_a101(
CID varchar(50),
CNTRY varchar(50)
);

GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2','u') IS NOT NULL
   drop table bronze.erp_px_cat_g1v2;

GO

create table bronze.erp_px_cat_g1v2(
ID varchar(50),
CAT varchar(50),
SUBCAT varchar(50),
MAINTENANCE varchar(50)
);
