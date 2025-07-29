--==================================
/*
loading data from two sources (CRM,ERP)>> six table into bronze layer with calculating the time of loading.
*/
--==================================


create or alter  procedure bronze.load_bronze as 
begin 
declare @start_time datetime,@end_time datetime,@batch_start_time datetime,@batch_end_time datetime;
    begin try 
            set @batch_start_time=GETDATE();
            print 'loading bronze layer';
            print '==========================================';
            print 'loading CRM tables';
            print '-------------------------------------------------------------------------------';
            print '>>truncating bronze.crm_cust_info table  ';
            print '>>inserting data into bronze.crm_cust_info table  ';
                    set @start_time=GETDATE();
                    truncate table bronze.crm_cust_info ;
                    BULK INSERT  bronze.crm_cust_info  
                    FROM 'D:\SQL\Baraa\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
                    with ( 
                    firstrow=2,fieldterminator=',',tablock
                    );
                    set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print ' '
            print ' '
            print '>>truncating bronze.crm_prd_info table  ';
            print '>>inserting data into bronze.crm_prd_info table  ';

                    set @start_time=GETDATE();
                    truncate table bronze.crm_prd_info ;
                    BULK INSERT  bronze.crm_prd_info
                    from 'D:\SQL\Baraa\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
                    with ( 
                    firstrow=2,fieldterminator=',',tablock
                    );
                    set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print ' ' 
            print ' ' 
            print '>>truncating bronze.crm_sales_details table  ';
            print '>>inserting data into bronze.crm_sales_details table  ';
                    set @start_time=GETDATE();
                    truncate table bronze.crm_sales_details ;
                    BULK INSERT  bronze.crm_sales_details
                    from 'D:\SQL\Baraa\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
                    with ( 
                    firstrow=2,fieldterminator=',',tablock
                    );
                    set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print '==========================================';
            print 'loading ERP tables';
            print '-------------------------------------------------------------------------------';

            print '>>truncating bronze.erp_CUST_AZ12 table  ';
            print '>>inserting data into bronze.erp_CUST_AZ12 table  ';

                    set @start_time=GETDATE();
                    truncate table bronze.erp_CUST_AZ12 ;
                    BULK INSERT bronze.erp_CUST_AZ12
                    from 'D:\SQL\Baraa\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
                    with ( 
                    firstrow=2,fieldterminator=',',tablock
                    );
                    set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print ' ' 
            print ' ' 
            print '>>truncating bronze.erp_LOC_A101 table  ';
            print '>>inserting data into bronze.erp_LOC_A101 table  ';
                    set @start_time=GETDATE();
                    truncate table bronze.erp_LOC_A101 ;
                    BULK INSERT bronze.erp_LOC_A101
                    from 'D:\SQL\Baraa\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
                    with ( 
                    firstrow=2,fieldterminator=',',tablock
                    );
                    set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print ' ' 
            print ' ' 
            print '>>truncating bronze.erp_PX_CAT_G1V2 table  ';
            print '>>inserting data into bronze.erp_PX_CAT_G1V2 table  ';
                    set @start_time=GETDATE();
                    truncate table bronze.erp_PX_CAT_G1V2 ;
                    BULK INSERT bronze.erp_PX_CAT_G1V2
                    from 'D:\SQL\Baraa\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
                    with ( 
                    firstrow=2,fieldterminator=',',tablock
                    );
                    set @end_time=GETDATE();
            print'loading time: '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds';
            print '==========================================';
            set @batch_end_time=GETDATE();
            print'bronze layer loaded successfully in '+cast(datediff(second,@batch_start_time,@batch_end_time)as nvarchar)+' seconds'
            print '==========================================';
    end try 
    begin catch 
            print '============================================';
            print 'failed to load bronze layer'; 
            print 'error message'+error_message();
            print 'error number'+cast (error_number()as nvarchar); 
            print '============================================';
    end catch 
end;
