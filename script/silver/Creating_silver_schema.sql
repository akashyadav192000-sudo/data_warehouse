/*
This script create table in thr silver shcema, dropping any existing table
*/

IF OBJECT_ID('silver.crm_cust_info','u') IS NOT NULL
   drop table silver.crm_cust_info;
GO
create table silver.crm_cust_info(
cst_id  int,
cst_key varchar(50),
cst_firstname varchar(50),
cst_lastname varchar(50),
cst_marital_status varchar(50),
cst_gndr varchar(50),
cst_create_date date,
dwh_create_date datetime2 default getdate()
);

GO

IF OBJECT_ID('silver.crm_prd_info','u') IS NOT NULL
   drop table silver.crm_prd_info;

GO

create table silver.crm_prd_info(
prd_id int,
cat_id varchar(50),
prd_key varchar(50),
prd_nm varchar(50),
prd_cost varchar(50),
prd_line varchar(50),
prd_start date,
prd_end_dt date,
dwh_create_date datetime2 default getdate()
);

GO

IF OBJECT_ID('silver.crm_sales_details','u') IS NOT NULL
   drop table silver.crm_sales_details;

GO

create table silver.crm_sales_details(
sls_ord_num varchar(50),
sls_prd_key varchar(50),
sls_cust_id int,
sls_order_dt date,
sls_ship_dt date,
sls_due_dt date,
sls_sales int,
sls_quantity int,
sls_price int,
dwh_create_date datetime2 default getdate()
);

GO

IF OBJECT_ID('silver.erp_cust_az12','u') IS NOT NULL
   drop table silver.erp_cust_az12;
 
GO

create table silver.erp_cust_az12(
cid varchar(50),
bdate date,
gen varchar(50),
dwh_create_date datetime2 default getdate()
);

GO

IF OBJECT_ID('silver.erp_loc_a101','u') IS NOT NULL
   drop table silver.erp_loc_a101;

GO

create table silver.erp_loc_a101(
cid varchar(50),
country varchar(50),
dwh_create_date datetime2 default getdate()
);

GO

IF OBJECT_ID('silver.erp_px_cat_g1v2','u') IS NOT NULL
   drop table silver.erp_px_cat_g1v2;

GO

create table silver.erp_px_cat_g1v2(
id varchar(50),
cat varchar(50),
subcat varchar(50),
maintenance varchar(50),
dwh_create_date datetime2 default getdate()
);
