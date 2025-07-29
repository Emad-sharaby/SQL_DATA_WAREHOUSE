/*
====================================
loading silver layer Bronze>>Silver
====================================
This stored procedure executes the ETL process so we can import cleaned data from the bronze layer 
and load it to the silver layer
====================================
How to execute: EXEC silver.load_silver;
*/



create or alter procedure silver.load_silver as 
begin 
declare @start_time datetime,@end_time datetime,@batch_start_time datetime,@batch_end_time datetime
    begin try
            set @batch_start_time=GETDATE();
            set @start_time=getdate()
            print 'loading silver layer';
            print '==========================================';
            print 'loading CRM tables';
            print '-------------------------------------------------------------------------------';
            print '>>truncating silver.crm_cust_info table  ';
            print '>>inserting data into silver.crm_cust_info table  ';
            -- first table( crm_cust_info)
            truncate table silver.crm_cust_info;
            with no_duplicate as (
            select *,ROW_NUMBER()over(partition by cst_id order by cst_create_date desc)as flagnumber
            from bronze.crm_cust_info
            where cst_id is not null
            )
            insert into silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date)
            select cst_id,
            cst_key,
            trim(cst_firstname)as cst_firstname,
            trim(cst_lastname)as cst_lastname,
            case 
                when upper(trim(cst_marital_status))='S' then 'Single'
                when upper(trim(cst_marital_status))='M' then 'Married'
                else'N/A'
            end cst_marital_status,
            case 
                when upper(trim(cst_gndr))='F' then 'Female'
                when upper(trim(cst_gndr))='M' then 'Male'
                else'N/A'
            end cst_gndr,
            cst_create_date
            from no_duplicate
            where flagnumber=1;
            set @end_time=getdate()
             print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
             print ' '
             print ' '
            --==============================
             
            print '>>truncating silver.crm_prd_info table  ';
            print '>>inserting data into silver.crm_prd_info table  ';
            set @start_time=getdate()
            --second table (crm_prd_info)
            truncate table silver.crm_prd_info;
            insert into silver.crm_prd_info(
            prd_id,
            prd_cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line ,
            prd_start_dt ,
            prd_end_dt)
            select prd_id,
            --extracting category id from prd_key so we can join it to erp_px_cat_g1v2
            --REPLACE (-) WITH (_) so standarize two columns
            --derived column
            REPLACE(SUBSTRING(prd_key,1,5),'-','_') as prd_cat_id,
            --extracting prd_key from prd_key so we can join it to  sls_prd_key from crm_sales_details
            SUBSTRING(prd_key,7,len(prd_key))as prd_key,
            --handling null values
            prd_nm,
            isnull(prd_cost,0) as prd_cost,
            --standarize prd_line,handling null values
            case upper(trim(prd_line))
                when 'M' THEN 'Mountain'
                when 'R' THEN 'Road'
                when 'S' THEN 'Other Sales'
                when 'T' THEN 'Touring' 
                else 'N/A'
            end as prd_line,
            --changing date type
            cast(prd_start_dt as date) as prd_start_dt ,
            --fix date when end date smaller than start (use lead),minus one to avoid overllaping,changing date type
            --data enrichment
            cast(lead(prd_start_dt)over(partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
            from bronze.crm_prd_info;
            set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print ' ' 
            print ' ' 
         
            --=====================================================
            print '>>truncating silver.crm_sales_details table  ';
            print '>>inserting data into silver.crm_sales_details table  ';
            set @start_time=getdate()
            --third table (bronze.crm_sales_details)
            truncate table silver.crm_sales_details;
            insert into silver.crm_sales_details(
            sls_ord_num ,
            sls_prd_key ,
            sls_cust_id ,
            sls_order_dt ,
            sls_ship_dt ,
            sls_due_dt ,
            sls_sales ,
            sls_quantity ,
            sls_price)
            select 
            sls_ord_num,
            sls_prd_key ,
            sls_cust_id ,
            --converting number to date 
            --we can't cast number to date so we cast it to varchar then cast to date
            case 
                when sls_order_dt =0 or len(sls_order_dt)!=8 then null
                else cast(cast(sls_order_dt as varchar(50)) as date)
            end as sls_order_dt,
            case 
                when sls_ship_dt =0 or len(sls_ship_dt)!=8 then null --handling wrong data
                else cast(cast(sls_ship_dt as varchar(50)) as date)
            end as sls_ship_dt,
            case 
                when sls_due_dt =0 or len(sls_due_dt)!=8 then null
                else cast(cast(sls_due_dt as varchar(50)) as date)
            end as sls_due_dt,
            case  --Recalculate sales if there is a mistake in the calculation
                when sls_sales is null or sls_sales <=0 or sls_sales !=abs(sls_price)*sls_quantity 
                    then abs(sls_price)*sls_quantity
                else sls_sales
            end as sls_sales,
            sls_quantity ,
            case  --derive price if there is invalid value
                when sls_price is null or sls_price <=0 
                    then abs(sls_sales)/nullif(abs(sls_quantity),0)
                else sls_price
            end as sls_price
            from bronze.crm_sales_details;
            set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print '==========================================';
            

            --======================================================
            print 'loading ERP tables';
            print '-------------------------------------------------------------------------------';

            print '>>truncating silver.erp_CUST_AZ12 table  ';
            print '>>inserting data into silver.erp_CUST_AZ12 table  ';
            set @start_time=getdate()
            truncate table silver.erp_CUST_AZ12 ;
            --fourth table (erp_cust_az12)
            insert into silver.erp_cust_az12(
            CID,
            BDATE ,
            GEN 
            )
            select 
            case --remove nas prefix if exists
                when cid like 'NAS%' THEN SUBSTRING(cid,4,len(cid))
                else cid 
            end as cid,
            case --set invalid date(future date ) to null
                when bdate >getdate() then null
                else bdate 
            end as bdate,
            case --normalize gen and handling null values
                when upper(trim(gen)) in ('F','FEMALE') THEN 'Female'
                when upper(trim(gen)) in ('M','MALE') THEN 'Male'
                else 'N/A'
            end as gen
            from bronze.erp_cust_az12;
            set @end_time=GETDATE();
              print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print ' ' 
            print ' ' 
            --==============================================
            print '>>truncating silver.erp_LOC_A101 table  ';
            print '>>inserting data into silver.erp_LOC_A101 table  ';
            set @start_time=GETDATE();
            --fifth table(erp_LOC_A101)
            truncate table silver.erp_LOC_A101;
            insert into silver.erp_LOC_A101(
            cid,
            cntry
            )
            select 
            replace(cid,'-','') as cid,
            case --normalize cntry and handling null or blank values
                when trim(cntry)='DE' THEN 'Germany'
                when trim(cntry) in ('USA','US') THEN 'United States'
                when trim(cntry) ='' or cntry is null THEN 'N/A'
                ELSE cntry
            end as cntry   
            from bronze.erp_LOC_A101;
            set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print ' ' 
            print ' ' 
            --=================================================
            print '>>truncating silver.erp_PX_CAT_G1V2 table  ';
            print '>>inserting data into silver.erp_PX_CAT_G1V2 table  ';
            set @start_time=GETDATE();
            --sixth table (erp_PX_CAT_G1V2)
            --table is clean and doesn't need any further cleaning
            truncate table silver.erp_PX_CAT_G1V2;
            insert into silver.erp_PX_CAT_G1V2(
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
            )
            SELECT 
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
            FROM bronze.erp_PX_CAT_G1V2;
            set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print '==========================================';
            set @batch_end_time=GETDATE();
            print'silver layer loaded successfully in '+cast(datediff(second,@batch_start_time,@batch_end_time)as nvarchar)+' seconds'
            print '==========================================';
    end try
    begin catch 
            print '============================================';
            print 'failed to load silver layer'; 
            print 'error message'+error_message();
            print 'error number'+cast (error_number()as nvarchar); 
            print '============================================';
    end catch
end;
