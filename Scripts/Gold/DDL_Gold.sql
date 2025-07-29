/*
Create Gold views
In this layer, we will create three views  for gold layer 
two dimension views and one fact view (star schema)
each view combines data from the silver layer to represent a business-ready dataset
*/


--===================================================================================
--create dimension:gold.dim_customers
--===================================================================================
create view gold.dim_customers as 
		select 
		row_number()over(order by cst_id) as generated_key,
		cst_id as customer_id,
		cst_key as customer_number,
		cst_firstname as first_name,
		cst_lastname as last_name,
		cst_marital_status as marital_status,
		case --crm is more accurate so it will be the default if not null or n/a
			when cst_gndr != 'N/A'  THEN cst_gndr
			else coalesce (GEN,'N/A')
		end as Gender,
		cntry as country,
		isnull(cast(bdate as nvarchar(100)),'N/A') as birth_date,
		cst_create_date as Create_date

		from silver.crm_cust_info s1
		left join silver.erp_cust_az12 s4
		on s1.cst_key=s4.cid
		left join silver.erp_loc_a101 s5
		on s1.cst_key=s5.cid;

--===================================================================================
--create dimension:gold.dim_product
--===================================================================================

create view gold.dim_product as
SELECT 
ROW_NUMBER()over(order by prd_start_dt,prd_key) as generated_key,
prd_id as product_id,
prd_key as product_number,
prd_nm as product_name,
prd_cat_id as category_id,
CAT as category,
SUBCAT as sub_category,
prd_line as producr_line,
MAINTENANCE,
prd_cost as product_cost,
prd_start_dt as [start_date]
FROM silver.crm_prd_info s2
left join silver.erp_PX_CAT_G1V2 s6
on s2.prd_cat_id=s6.id
where prd_end_dt is null --filtering out all historical data (active requests only)

--===================================================================================
--create Fact: gold.fact_sales
--===================================================================================
create view gold.fact_sales as
SELECT 
s3.sls_ord_num as order_number,
g2.generated_key as product_key,
g1.generated_key as customer_key,
s3.sls_order_dt as order_date,
s3.sls_ship_dt as shipping_date,
s3.sls_due_dt as due_date,
s3.sls_sales as sales_amount,
s3.sls_quantity as quantity,
s3.sls_price as price
FROM silver.crm_sales_details s3
left join gold.dim_customers g1
on s3.sls_cust_id=g1.customer_id
left join gold.dim_product g2
on s3.sls_prd_key=g2.product_number
