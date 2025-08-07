use sales;
select * from df_orders

--Find top 10 highest revenue generating products
use sales;
select top 10 product_id, sum(sales_price) as Sales
from df_orders
group by product_id
order by Sales desc;

--Find top 5 highest selling products in each regions
with cte as (
select region, product_id, sum(sales_price) as Sales
from df_orders
group by region, product_id)
select * from (
select *,
ROW_NUMBER () over (partition by region order by Sales desc) as rn
from cte) A
where rn<=5

--Find month over growth comparision for 2022 and 2023 sales eg: jan 2022 vs 2023
with cte as (
select year(order_date) as order_year, MONTH(order_date) as order_month,
SUM(sales_price) AS Sales
from df_orders
group by YEAR(order_date), MONTH(order_date)
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

--For each category which month had highest sales
with cte as(
select category, format(order_date,'yyyyMM') as order_year_month
, sum(sales_price) as sales
from df_orders
group by category, format(order_date, 'yyyyMM')
)
select * from (
select * , 
row_number() over (partition by category order by sales desc) as rn
from cte
) a
where rn=1

--Which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category, year(order_date) as order_year,
SUM(sales_price) AS Sales
from df_orders
group by sub_category, YEAR(order_date)
)
, cte2 as (
select sub_category,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 * , 
(sales_2023 - sales_2022) as growth
from cte2
order by growth desc




