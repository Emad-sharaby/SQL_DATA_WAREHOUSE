/*
create data base and schemas
    the script creates database named "datawarehouse" and three schemas"bronze,silver,gold" after checking if 
    it is already exists.
    if the data base exists, it will be dropped the recreated with its schemas.

warning:
    running this script will drop the entire database if it is exists with all the data inside it.
*/



use master;
go 

--DROP DATA BASE IF EXISTS 
IF EXISTS( SELECT 1 FROM SYS.DATABASES WHERE  name ='DATAWAREHOUSE')
begin 
drop database Datawarehouse;
end;
go

--create database 
create database Datawarehouse;
go
use datawarehouse;
go

--create schemas
create schema bronze;
go
create schema silver;
go
create schema gold;
go


