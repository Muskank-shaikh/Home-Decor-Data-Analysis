
-- creating new database
create  database furnishingsdb;
use furnishingsdb;
show tables;
desc furniture dataset;
desc furniture dataset;
drop table furnituredataset;
-- created new table called furnitures
desc furnitures;
select * 
from furnitures;

-- modifying datatype of date and sales
alter table furnitures
modify column sales decimal(10,3);


update furnitures
set Order_Date =
str_to_date(Order_Date, '%m/%d/%Y')
where Order_Date like '%-%';

 set sql_safe_updates = 0;
 
 -- the date are in two formats want to change but only with one
 UPDATE Furnitures
SET Order_Date = STR_TO_DATE(Order_Date, '%m/%d/%Y')
WHERE Order_Date LIKE '%/%';

UPDATE Furnitures
SET Order_Date = STR_TO_DATE(Order_Date, '%d-%m-%Y')
WHERE Order_Date LIKE '%-%';

UPDATE Furnitures
SET Order_Date = STR_TO_DATE(Order_Date, '%d-%m-%Y')
WHERE Order_Date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';

select order_date 
from furnitures
where order_date is null;

alter table furnitures
modify column order_date date;

desc furnitures;

-- create a scope table for analysis
create table home_decor as
select * 
from furnitures
where category in ('Furniture','Furnishings');

select * from home_decor;
select distinct Product_Name
from home_decor;

-- adding columns clean_product_name and product_type
alter table home_decor
add column clean_product_name varchar(150),
add column product_type varchar(100);

-- updating product_type from product_name

 update home_decor
 set product_type = 'Chair'
 where Product_name like '%chair%';

 update home_decor
 set product_type = 'Table'
 where Product_name like '%table%';
 


-- modifying Product_name to Varchar
alter table home_decor
modify Product_name text,
modify product_type varchar(100);

show create table home_decor;

UPDATE home_decor
SET product_type = 'Bookcase / Storage'
WHERE CAST(product_name AS CHAR) LIKE '%bookcase%'
   OR CAST(product_name AS CHAR) LIKE '%library%';
   
   UPDATE home_decor
SET product_type = 'Lighting'
WHERE product_name  LIKE '%lamp%'
   OR product_name  LIKE '%bulb%';
   
    UPDATE home_decor
SET product_type = 'Clock'
WHERE product_name  LIKE '%clock%';

 UPDATE home_decor
SET product_type = 'Desk Accessories'
WHERE product_name  LIKE '%desk%'
   OR product_name  LIKE '%frame%'
   or product_name like '%holder%';
   
-- updating clean product names from product_name
update home_decor
set clean_product_name = 'Office Chair'
where product_type = 'Chair';

update home_decor
set clean_product_name = 'Office Table'
where product_type = 'Table';

update home_decor
set clean_product_name = 'Bookcase'
where product_type = 'Bookcase / Storage';

update home_decor
set clean_product_name = 'Lamp'
where product_type = 'Lighting';

select distinct product_name
from home_decor
where product_type is null;

-- updating other products which are null into desk accessories in product type to avoid confusion
update home_decor
set product_type = 'Non-Core / Accessories'
where product_type is null;

desc home_decor;

select 
product_type,
count(*) as product_count 
from home_decor
group by product_type;

-- Analyzing unique categories, products and countries
select distinct sub_category, product_type 
from home_decor
where state = 'Texas';

select distinct state 
from home_decor;

select count(distinct product_type) As basic_analysis 
from home_decor;

select distinct product_type as total_product
from home_decor;

select distinct clean_product_name as total_product
from home_decor
where clean_product_name  is not null;

select sum(sales) as revenue, sub_category
from home_decor
where Category = 'Furniture'
group by  sub_category ;

select distinct sub_category,  clean_product_name
from home_decor
where clean_product_name is not null;
 
 -- total sales and total profit
 select 
 sum(sales) as total_sales,
 sum(profit) as total_profit
 from home_decor
 where Category ='Furniture';
 
  -- identifying the number of loss products
 SELECT COUNT(DISTINCT clean_product_name) AS loss_products
FROM home_decor
WHERE category = 'Furniture'
  AND profit < 0;
  
-- total loss by profit
SELECT SUM(profit) AS total_loss
FROM home_decor
WHERE category = 'Furniture'
  AND profit < 0;

-- loss products name
select clean_product_name,
round(sum(profit),2) as total_loss
from home_decor
where category = 'Furniture'
and profit < 0 
grouP by clean_product_name
order by total_loss asc;

-- profit according to furnishings
SELECT
    sub_category,
    SUM(sales)  AS revenue,
    SUM(profit) AS profit
FROM home_decor
WHERE category = 'Furniture'
GROUP BY sub_category
ORDER BY revenue DESC;

-- costly products not making profit
SELECT
    clean_product_name,
    SUM(sales)  AS total_sales,
    SUM(profit) AS total_profit
FROM home_decor
GROUP BY clean_product_name
HAVING total_sales > 0
   AND total_profit < 0
ORDER BY total_sales DESC;

select count(distinct customer_name) as lamp_buyers 
from home_decor
where clean_product_name = 'lamp';

-- Lamp analysis
-- profit by lamp
select 
sum(sales) as total_sales,
sum(profit) as total_profit
from home_decor
where clean_product_name ='Lamp';

-- min, max, avg of profit from lamp
select 
max(profit) as max_profit,
min(profit) as min_profit,
avg(profit) as avg_profit
from home_decor
where clean_product_name ='Lamp';

-- lamp summary
create view lamp_summary as
select customer_name,
count(*) as lamp_orders,
sum(sales) as total_lamp_spend,
sum(profit) as total_lamp_profit,
min(profit) as min_lamp_profit,
max(profit) as max_lamp_profit,
avg(profit) as avg_lamp_profit
from home_decor
where clean_product_name = 'Lamp'
group by customer_name
order by lamp_orders asc;

select *
from lamp_summary;

-- lamp sold in states summary
create view lamp_state_summary as
select state,
count(*) as total_lamp_orders,
count(distinct customer_name) as unique_lamp_buyers,
sum(sales) as total_lamp_sales,
sum(profit) as total_profit,
avg(profit) as avg_profit
from home_decor
where clean_product_name = 'Lamp'
group by state
order by total_lamp_sales desc;

select * from lamp_state_summary;

-- new vs returning buyers
create view customer_buyer_type as
select customer_name,
count(*) as lamp_orders,
case when count(*) = 1 then 'New Buyer'
else 'Returning Buyer'
end as customer_type,
sum(sales) as total_sales,
sum(profit) as total_profit
from home_decor
where clean_product_name = 'Lamp'
group by customer_name;

select * from customer_buyer_type;

-- returns/replacements
create view lamp_negative_profit as
select order_date,
customer_name,
state,
Sales,
profit
from home_decor
where clean_product_name = 'Lamp'
and profit < 0 
order by profit asc;

select * from lamp_negative_profit;

select sum(sales) as revenue
from home_decor 
where clean_product_name = 'Lamp';

select distinct state
from home_decor 
where clean_product_name in ('Bookcase' , 'Office Table');