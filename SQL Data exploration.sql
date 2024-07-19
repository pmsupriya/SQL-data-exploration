Create database sql_basics; --  Ser as default Scheme

/* Create a new table "sales_data" using data table import functionality. Import the "data_sales" sheet into this table.
Inspect this table "sales_data" especially its columns data types and the SQL that generated this table */
describe sales_data;

/* SELECT all columns of this table*/
select* from sales_data;

/*SELECT all columns of this table only for the State of California */

select * from sales_data where `Region` = 'California';

# "Minimum", "Maximum", Average and Total values for Price and Quantity 

select min(`price`) as min_price,max(`price`) as max_price,avg(`price`) as avg_price, sum(`price`) as total_price,
min(`Quantity`) as min_qty,max(`Quantity`) as max_qty,avg(`Quantity`) as avg_qty, sum(`Quantity`) as total_qty from sales_data;

# number of orders occurring for each Product 
select* from sales_data;
select count(`Order ID`),Product_Type from sales_data group by Product_Type order by 2;

# Calculate "Revenue" column
alter table sales_data
add column `Revenue` double default (Price * Quantity);

select* from sales_data;
/* Calculate the total revenue for each sales person */

select `Sales Person`,sum(Revenue) from sales_data group by 1;

# list of orders for which revenue is between 1000 and 3000, for the state of TEXAS 
select* from sales_data;
select* from sales_data where (Revenue between 1000 and 3000) and (Region = 'Texas');

# list of Sales Person where total revenue is greater than 250000
select `Sales Person`, sum(revenue)from sales_data group by 1 having sum( Revenue) > 250000;

select* from sales_data limit 3 offset 2; # gives output from 3rd row upto 3 rows

# order id's Classification the price in  hi-medium-low buckets using CASE
select `Order ID`,
case
when Price <100 then "Low"
when Price between 101 and 300 then "Medium"
else "Hi"
end as Price_bucket
from sales_data order by 1;
-- creting bins for above
select 
case
when Price <100 then "Low"
when Price between 101 and 300 then "Medium"
else "Hi"
end as Price_bucket,
count(`Order ID`) as cnt from sales_data group by 1;

# load order table
describe orders;
select* from orders;
select distinct(`Ship Mode`) from orders;

# Categorize ship mode first class or not depending on weather teh ship mode is First class or not
select `Order ID`,`Ship Mode`,
case
	when `Ship Mode` = 'First Class' then 'is_Firstclass'
    else 'others'
end as shipping_type
from orders ;

/* geting order ID's,sales,discount columns by filtering for the conditions 
(a) if discount is applied, then sale value should be >1000 and
(b) if discount is 0 then sales value should be <500
*/

select `Order ID`, sales,Discount,
case
	when Discount > 0.0 and sales >1000 then 'High Sales'
	when Discount <= 0 and sales <500 then'Low Sales'
    else 'not applicable'
end 'sale_grp' 
from orders;

# Find the total Sales in the month of March 2019

/* format date column*/

select 	`Order Date`,replace(`Order Date`, '--','-'),
`Ship Date`,replace(`Ship Date`, '--','-') from orders;
select* from orders limit 3;
-- permantly update
UPDATE orders
SET 
    `Order Date` = REPLACE(`Order Date`, '--', '-'),
    `Ship Date` = REPLACE(`Ship Date`, '--', '-')
WHERE 
    `Order Date` LIKE '%--%' OR `Ship Date` LIKE '%--%';

-- Change the datatype of the Order Date and Ship date column to DATETIME
ALTER TABLE orders MODIFY COLUMN `Order Date` DATETIME;
ALTER TABLE orders MODIFY COLUMN `Ship Date` DATETIME;

describe orders;

select `Order ID`,sum(Sales) from orders where last_day(`Order Date`) = '2019-01-31' group by 1;

# avg days taken to ship an order for each region

select `Country/Region`,avg(datediff(`Ship Date`,`Order Date`))as diff from orders group by 1;
select distinct(`Country/Region`) from orders;

# Find the total sales for each year

select year(`Order Date`)as year,round(sum(sales),2)as sales from orders group by 1;

# Extract teh 1st 3 characters of the product field
select* from orders limit 3;
select `Product Name`,left(`Product Name`,3) from orders;

# list of all products  that have word 'Hi' in them
select `Product Name`from orders where `Product Name` Like '%Hi%';

# 1st part of the ship mode in an independent column
select `Ship Mode`, substring_index(`Ship Mode`, ' ',1)as '1st_word' from orders; 


--  -- DATE AND STRING FUNCTIONS -----

# convert date to yr mth and date concider orders dataset
select* from orders;
select `Order Date`, 
month(`Order date`)mth1,
year(`Order date`)yr1,
week(`Order date`)wk1,
day(`Order date`)day1,
dayname(`order date`)day_name
from orders;

# to display date in required format
select`order date`,
date_format(`order date`,'%d-%m-%y')style1,
date_format(`order date`, '%D/%M/%Y')style2,
date_format(`order date`,'%d-%m-%Y')style3 
from orders;

# add and subtract certain day week year to available date

select `Order Date`,
adddate(`order date`,interval 1 month)add_mth,
date_add(`order date`,interval 1 day)add_day,
subdate(`order date`,interval 1 month)sub_mth,
date_sub(`order date`,interval 1 day)sub_day
from orders where year(`Order Date`) = 2020; -- trying to give condition

# calculate difference of 2 dates
select* from orders;
select `order date`, datediff(`ship date`, `order date`)diff_date from orders;

# how to get last day of certain date 

select `order date`, last_day(`order date`) from orders where year(last_day(`order date`)) = 2019 ; -- gives by year
select `order date`, last_day(`order date`) from orders where (last_day(`order date`)) = '2019-02-28' ; -- gives sepcific month in year
select `order date`, sum(sales) from orders where (last_day(`order date`)) = '2019-02-28' group by 1 ; -- gives sepcific month in year sum of sales

-- STRING MANIPULATIONS --

# Length of the string

select* from orders;
select `customer name`, length (`Customer Name`) from orders;

#Concat 2 2strings along with lower and upper function
select`Customer Name`,`Country/Region`, 
lower(concat(`Customer Name`,'_',`Country/Region`))l_concat,
upper(concat(`Customer Name`,'_',`Country/Region`))u_concat from orders;

# extract left mid and right characters from string

select `Customer Name`, 
left(`Customer Name`,4)lef,
Right(`Customer Name`,4)rig,
Mid(`Customer Name`,4,2)mid, -- for mid function(input to take,from where to start, how many ch to give
substring(`Customer Name`,4,2)sub_str -- it is similar to mid function
from orders; 

# split string with de-limiter
select `Customer ID`, `Customer Name`, substring_index(`Customer ID`,'-',1)'delim_-',substring_index(`Customer Name`,' ',1)1st_space_detect,
substring_index(`Customer Name`,' ',-1)'left space detect' from orders;

# Replace function
select* from orders;
select `Ship mode`, replace(`ship mode`,'Standard','std') from orders; -- REPLCE(FIELD TO REPLACE, WHAT TO REPLACE, WHICH WORD TO REPLCE)

# LOCATE FUNCTION to locate teh position of space
select `Product name`, LOCATE(' ', `Product name`) from orders; -- gives at only 1st space value




-- -----------------------------------------SUBQUERY -----------------------------------

# GET THE ROW FROM THE ORDERS TABLE WHICH HAS MAX SALES VALUE

select* from orders where Sales = (select max(Sales) from orders);  # '22638.48'

# find the LIST of orders that have not been returned
select`Order ID` from orders.o where not exists (SELECT `Order ID`from Returns as r where r.`Order ID` = o.`Order ID`);

 # Find the list of orders where sales> avg sales of the order region(Use CTE)
 
 with avg_sales as
 (
 select avg(sales)average_sales from orders
 )
 
 select* from orders 
 where sales >=(select average_sales from avg_sales);
 

 # using CTE find Average Order Value (AOV) for each segment
 
 with aov as 
 (select `Segment`, sum(Sales)as sum,count(*)as cnt from orders group by 1)
 
 select `Segment`,(sum / cnt)as AOV from aov;
 
 
 /* --            WINDOW FUNCTIONS */

 
 select `Order ID`,Segment,Sales
 ,round(sum(Sales) over(partition by Segment),2) as t_sales_seg
 ,round(max(Sales) over(partition by Segment),2) as max_sales_seg
 ,round(min(Sales) over(partition by Segment),2) as min_sales_seg
 ,round(count(Sales) over(partition by Segment),2) as cnt_sales_seg
 
 ,round(sum(Sales) over(rows between unbounded preceding and unbounded following),2) as 'total_sales_dataset' 
 ,max(Sales) over(rows between unbounded preceding and unbounded following) as 'max_sales_dataset' 
 ,min(Sales) over(rows between unbounded preceding and unbounded following) as 'min_sales_dataset' 
 ,count(Sales) over(rows between unbounded preceding and unbounded following) as 'count_sales_dataset' 
 from orders;


#use row_number function to get 2nd lowest  order by sales value with each category
# 'Office Supplies', '0.984', '2'
/* 
Furniture	3.48
Office Supplies	0.852
Technology	2.376
*/

with row_num as
(
select `Order ID`,Category,Sales,
row_number() over (partition by Category order by Sales)as row_numb
from orders
)

select `Order ID`,Category,Sales from row_num where row_numb = 2;

# use lead &  function to get year over year sales
select* from orders limit 3;

with year as
(
select distinct(year(`Order Date`)) as yr, sum(sales)as sales from orders group by 1
)

select *,
lead(sales) over(order by yr) lead_sales,
lag(sales) over(order by yr) lag_sales from year;

# SQL INTERMIDATE SOLUTION witrh orders  only

# 1	Get the sales by year. Which year post the highest sales?

select year(`Order Date`) yr,Max(Sales) sales
 from orders group by 1 order by 1;

# Find the Length of each Customer’s name
select* from orders limit 3;
select `Customer Name`, length(`Customer Name`) len from orders;

# In a new column, concatenate State/Province and Postal Code separated by a "-". It should be entirely in lower case

select `State/Province`,`Postal Code`, concat(`State/Province`,'-',`Postal Code`)concat from orders;

# Split the Customer Name into first name and last name
select`Customer Name`
,substring_index(`Customer Name`,' ',1)as first_name
,substring_index(`Customer Name`,' ',-1)as last_name
from orders;


# Ensure you have “Orders”, “People” and “Returns” tables loaded into a schema. These are the same files that were used in previous lectures.
# Get the list of orders where sales value is less than the corresponding region’s average sales value
select* from orders limit 3;
with avgsale as
(
select `Order ID`,Region, Sales
,round(avg(Sales) over(partition by Region),2) as reg_sale
from orders
)
select* from avgsale where Sales < reg_sale order by Region,Sales;

# Find the average sales value of Returned vs Non-Returned Sales Orders

select avg(o.Sales),r.returned as 'status' from orders as o 
left join returns as r on 
o.`Order id` = r.`order id` group by 2;

-- coalesce function - is used to give value we want when it encounters 1stt null value in teh column

select round(avg(o.sales),2)avg_sales, coalesce(r.returned,'No')ret_status from orders as o 
left join returns as r on 
o.`order id` = r.`order id` group by 2;


# 10	Using EXISTS operator, find the list of orders that have been returned.
select o.* from orders as o where exists( select r.`order id` from returns as r where r.`Order ID` = o.`Order ID`) ;

# 11	Using CTE & JOINS, find the total sales for each Regional Manager

with order_sales as 
(
select o.Sales, p.`Regional Manager` from orders as o 
left join peoples as p on 
p.`Region` = o.`Region`
)
select sum(order_sales.Sales)as t_sale, order_sales.`Regional Manager` from order_sales group by 2;


# Using CTE, find the total average revenue per customer (ARPU) for each Segment (hint: ARPU = Total Revenue/Total Customers)
select* from orders ;
with ARPU as
(
select count(distinct(`Customer ID`))as cnt,sum((Sales - Discount)* Quantity) as t_Revenue, Segment from orders group by 3
)

Select Segment, t_Revenue/cnt as 'ARPU' from ARPU group by 1;


