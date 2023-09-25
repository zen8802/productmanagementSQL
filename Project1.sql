
/*** PRODUCT DATABASE CREATION ***/

create database sql_course;

use sql_course;

CREATE TABLE bi_calendar(
  DayDate date,
  year int,
  month int,
  quarter_term varchar(50),
  half_year_term varchar(50),
  first_day_of_month date,
  last_day_of_month date,
  day_of_week_short varchar(50),
  day_of_week_long varchar(50),
  month_name_short varchar(50),
  month_name_long varchar(50),
  seq_num int
)
;


CREATE TABLE product_category_master(
  product_category_id varchar(50),
  category_layer1 varchar(50),
  category_layer2 varchar(50)
)
;

CREATE TABLE product_master(
  product_id varchar(50),
  product_category_id varchar(50),
  product_name varchar(100),
  product_price int
)
;

CREATE TABLE sales_orders(
  order_id varchar(50),
  order_date date,
  shopper_id varchar(50),
  product_id varchar(50),
  order_qty int,
  order_amt int
)
;

CREATE TABLE shopper_master(
  shopper_id varchar(50),
  gender varchar(50),
  email_optin_flag varchar(50)
)
;


show tables;

desc sales_orders;
desc shopper_master;
desc product_master;
desc product_category_master;
desc bi_calendar;

select * from sales_orders;
select * from shopper_master;
select * from product_master;
select * from product_category_master;
select * from bi_calendar;


/*** RUN A PRACTICE TEST(S) ***/

-- joining sales_orders and bi_caledar and filtering by October, 2019
select 
    cal.day_of_week_short 
    , ord.* 
from 
    sales_orders ord 
    left outer join bi_calendar cal on cal.DayDate = ord.order_date  
where 
    cal.year = 2019 
    and month = 10
;

-- grabbing several columns, joining tables, and filtering by October, 2019
SELECT
    sm.gender,
    ord.order_date,
    cal.day_of_week_short,
    cal.quarter_term,
    pcm.category_layer1,
    pcm.category_layer2,
    pm.product_name,
    ord.order_qty,
    ord.order_amt
FROM
    sales_orders ord 
    JOIN bi_calendar cal ON cal.DayDate = ord.order_date
    JOIN shopper_master sm ON sm.shopper_id = ord.shopper_id
    JOIN product_master pm ON pm.product_id = ord.product_id
    JOIN product_category_master pcm ON pcm.product_category_id = pm.product_category_id
WHERE
    cal.year = 2019 
    and month = 10
;


/*** create the select statement to select the record count and total of
 order_qty and order_amt ***/

SELECT
    cal.year
    , cal.month 
    , sum(ord.order_qty) total_order_qty
    , sum(ord.order_amt) total_order_amt
    , count(*) cnt
FROM
    sales_orders ord 
    JOIN bi_calendar cal ON cal.DayDate = ord.order_date
    JOIN shopper_master sm ON sm.shopper_id = ord.shopper_id
    JOIN product_master pm ON pm.product_id = ord.product_id
    JOIN product_category_master pcm ON pcm.product_category_id = pm.product_category_id

group by
    cal.year
    , cal.month 
having
    sum(ord.order_qty) >= 1000
    and sum(ord.order_amt) >= 23231100
order by
    cal.year
    , cal.month 
;

/***  average order amt and order qty of male shoppers and female shoppers
 in the entire dataset. ***/

SELECT
    gender,
    AVG(order_amt) AS avg_order_amount,
    AVG(order_qty) AS avg_order_quantity
FROM
    sales_orders ord 
    inner join shopper_master sm on ord.shopper_id = sm.shopper_id
GROUP BY
    gender;


/*** average(order_amt),
  minimum(order_amt), and maximum(order_amt) by year and month, over 20k ***/

SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    AVG(order_amt) AS avg_order_amount,
    MIN(order_amt) AS min_order_amount,
    MAX(order_amt) AS max_order_amount
FROM
    sales_orders ord 
  
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
HAVING
    AVG(order_amt) >= 20000;


/*** top 5 product categories (category_layer1) that were sold in
 the whole dataset in terms of qty ***/

SELECT
    pcm.category_layer1,
    SUM(ord.order_qty) AS total_quantity_sold
FROM
    sales_orders ord 
    JOIN product_master pm ON pm.product_id = ord.product_id
    JOIN product_category_master pcm ON pcm.product_category_id = pm.product_category_id 
GROUP BY
    pcm.category_layer1
ORDER BY
    total_quantity_sold DESC
LIMIT 5

/*** bottom 5 product categories (category_layer2) that were sold in year=2019
 month=10 in terms of amt ***/

SELECT
    pcm.category_layer2,
    SUM(ord.order_qty) AS total_quantity_sold
FROM
    sales_orders ord 
    -- JOIN bi_calendar cal ON cal.DayDate = ord.order_date
    -- JOIN shopper_master sm ON sm.shopper_id = ord.shopper_id
    JOIN product_master pm ON pm.product_id = ord.product_id
    JOIN product_category_master pcm ON pcm.product_category_id = pm.product_category_id 
WHERE
    YEAR(order_date) = 2019
    AND MONTH(order_date) = 10
GROUP BY
    pcm.category_layer2
ORDER BY
    total_quantity_sold
LIMIT 5;

/*** List up all order dates when male shoppers make a purchase 
and list up all order dates when female shoppers make a purchase. ***/

SELECT
    ord.order_date,
    sm.gender

FROM 
    sales_orders ord
    JOIN shopper_master sm ON ord.shopper_id = sm.shopper_id
WHERE 
    sm.gender = 'M'
UNION
SELECT
    ord.order_date,
    sm.gender
FROM 
    sales_orders ord
    JOIN shopper_master sm ON ord.shopper_id = sm.shopper_id
WHERE 
    sm.gender = 'F'

ASSIGNMENT 10:

SELECT
    ord.order_date,
    sm.gender
FROM 
    sales_orders ord
    JOIN shopper_master sm ON ord.shopper_id = sm.shopper_id
WHERE EXISTS (
    SELECT *
    FROM 
        product_category_master pcm
    WHERE 
        pcm.category_layer1 = 'shoes'
);

/*** month-over-month (MoM) percentage change in total order amount over time,
 grouping the results by year and month of order date. ***/

select
  year(a.order_date) yr
  , month(a.order_date) mth
  , count(distinct shopper_id) as shopper_cnt
  , count(*) as order_cnt
  , count(distinct product_id) as distinct_prod_cnt
  , sum(order_qty) as order_qty
  , sum(order_amt) as order_amt
  , lag(sum(order_amt)) over (order by year(a.order_date), month(a.order_date)) as prv_order_amt
  , lead(sum(order_amt)) over (order by year(a.order_date), month(a.order_date)) as next_order_amt
  , sum(order_amt) * 100.0 /  lag(sum(order_amt)) over (order by year(a.order_date), month(a.order_date)) as MoM
from
  sales_orders a
group by
  year(a.order_date)
  , month(a.order_date)
order by
  year(a.order_date)
  , month(a.order_date)
;

/***  products 'Comfort Slide Sandal' and 'Outdoor Boot Cut Casual Pants' ordered
 between September 1, 2020, and September 4, 2020.
 Calculates the total order amount for each product on each order date
 and adds a column ('window_sum01') that contains the sum of order amounts
 for all records within the specified date range. ***/

select
  cat.category_layer2
  , prd.product_name
  , ord.order_date
  , sum(ord.order_amt)
  , sum(ord.order_amt) over() as window_sum01

from
  sales_orders ord
  inner join product_master prd on prd.product_id = ord.product_id
  inner join product_category_master cat on cat.product_category_id = prd.product_category_id
where
  ord.order_date between '2020-09-01' and '2020-09-04'
  and prd.product_name in (
  'Comfort Slide Sandal'
  , 'Outdoor Boot Cut Casual Pants'
  )
group by
  cat.category_layer2
  , prd.product_name
  , ord.order_date
  , ord.order_amt
order by
  cat.category_layer2
  , prd.product_name
  , ord.order_date
;


/*** ABC Analysis SQL statement that list up products sold in the entire period
 in the order of the order amount (descending) along with the ratio in the total
 amount. ***/


WITH TotalOrderAmount AS (
    SELECT SUM(ord.order_amt) AS total_amount
    FROM sales_orders ord
)
SELECT
    pcm.category_layer1,
    pcm.category_layer2,
    pm.product_name,
    SUM(ord.order_amt) AS total_order_amt,
    ROUND((SUM(ord.order_amt) / TOA.total_amount) * 100, 5) AS ratio_in_total_amount
FROM
    sales_orders ord
    INNER JOIN product_master pm ON pm.product_id = ord.product_id
    INNER JOIN product_category_master pcm ON pcm.product_category_id = pm.product_category_id
    CROSS JOIN TotalOrderAmount TOA
GROUP BY
    pcm.category_layer1
    , pcm.category_layer2
    , pm.product_name
    , TOA.total_amount
ORDER BY
    total_order_amt DESC;



with cte_total_amt as (
  select 
    sum(ord.order_amt) as order_amt
  from
    sales_orders ord
)
, cte_product_amt as (
select
  cat.category_layer1
  , cat.category_layer2
  , prd.product_name
  , coalesce(sum(ord.order_amt), 0) as order_amt
from
  product_master prd
  inner join product_category_master cat on cat.product_category_id = prd.product_category_id
  left outer join sales_orders ord on ord.product_id = prd.product_id
group by
  cat.category_layer1
  , cat.category_layer2
  , prd.product_name
)
select
  a.*
  , a.order_amt * 100.0 / b.order_amt as order_amt_ratio
from
  cte_product_amt a
  cross join cte_total_amt b
order by
  a.order_amt * 100.0 / b.order_amt desc
;


select 
  a.*
  , sum(a.order_amt_ratio) over (order by order_amt_ratio desc) as accumulate_amt_ratio
  , row_number() over (order by a.order_amt desc) as rownum
  , case when row_number() over (order by a.order_amt desc) <= 25 then 'A' 
    else case when row_number() over (order by a.order_amt desc) <= 50 then 'B' 
    else 'C' end end
from 
  (
  select
    distinct
    cat.category_layer1
    , cat.category_layer2
    , prd.product_name
    , coalesce(sum(ord.order_amt) over (partition by prd.product_name), 0) as order_amt
    , coalesce(sum(ord.order_amt) over (partition by prd.product_name), 0) * 100.0 / sum(ord.order_amt) over() as order_amt_ratio
  from
    product_master prd
    inner join product_category_master cat on cat.product_category_id = prd.product_category_id
    left outer join sales_orders ord on ord.product_id = prd.product_id
  ) a
order by
    a.order_amt_ratio desc
;


/*** SQL statement to group the shoppers by RFM with 1 to 5
 scores along with the shopper count in each group. ***/

WITH RFM AS (
  SELECT
    sm.shopper_id,
    CASE
      WHEN YEAR(MAX(so.order_date)) = 2020 THEN 2
      WHEN YEAR(MAX(so.order_date)) = 2019 THEN 1
    END AS Recency,
    COUNT(so.order_id) AS Frequency,
    SUM(so.order_amt) AS MonetaryValue
  FROM
    shopper_master sm
  LEFT JOIN
    sales_orders so ON sm.shopper_id = so.shopper_id
  GROUP BY
    sm.shopper_id
)
select 
    a.*
    , a.recency + a.Frequency_Score + MonetaryValue_Score as total_score
from
(
SELECT
  r.Recency,
  CASE
    WHEN r.Frequency <= 1 THEN 1
    WHEN r.Frequency <= 5 THEN 2
    WHEN r.Frequency <= 10 THEN 3
    WHEN r.Frequency <= 15 THEN 4
    ELSE 5
  END AS Frequency_Score,
  CASE
    WHEN r.MonetaryValue < 100000 THEN 1
    WHEN r.MonetaryValue < 200000 THEN 2
    WHEN r.MonetaryValue < 300000 THEN 3
    WHEN r.MonetaryValue < 400000 THEN 4
    ELSE 5
  END AS MonetaryValue_Score,
  COUNT(s.shopper_id) AS Shopper_Count
FROM
  shopper_master s
LEFT JOIN
  RFM r ON s.shopper_id = r.shopper_id
GROUP BY
  r.Recency,
  CASE
    WHEN r.Frequency <= 1 THEN 1
    WHEN r.Frequency <= 5 THEN 2
    WHEN r.Frequency <= 10 THEN 3
    WHEN r.Frequency <= 15 THEN 4
    ELSE 5
  END,
  CASE
    WHEN r.MonetaryValue < 100000 THEN 1
    WHEN r.MonetaryValue < 200000 THEN 2
    WHEN r.MonetaryValue < 300000 THEN 3
    WHEN r.MonetaryValue < 400000 THEN 4
    ELSE 5
  END
) a
ORDER BY
  a.Recency DESC, 
  a.Frequency_Score DESC, 
  a.MonetaryValue_Score DESC;

/*** finding  product-related statistics, including order amount ratios
 and cumulative rankings based on popularity within categories ***/

select 
  a.*
  , sum(a.order_amt_ratio) over (order by order_amt_ratio desc) as accumulate_amt_ratio
from 
  (
  select
    distinct
    cat.category_layer1
    , cat.category_layer2
    , prd.product_name
    , coalesce(sum(ord.order_amt) over (partition by prd.product_name), 0) as order_amt
    , coalesce(sum(ord.order_amt) over (partition by prd.product_name), 0) * 100.0 / sum(ord.order_amt) over() as order_amt_ratio 
  from
    product_master prd
    inner join product_category_master cat on cat.product_category_id = prd.product_category_id
    left join sales_orders ord on ord.product_id = prd.product_id
  ) a
order by
    a.order_amt_ratio desc
;

/*** Compute how many shoppers in the cohort purchased
again within 30days and 60 days respectively along with the ratio in the cohort.
Total shopper count is the number of shoppers in the month regardless
of the cohort. ***/

WITH FirstTimeShoppers AS (
  SELECT
    shopper_id,
    MIN(order_date) AS first_purchase_date,
    YEAR(MIN(order_date)) AS cohort_year,
    EXTRACT(MONTH FROM MIN(order_date)) AS cohort_month
  FROM
    sales_orders
  GROUP BY
    shopper_id
),

CohortShopperCounts AS (
  SELECT
    cohort_year,
    cohort_month,
    COUNT(DISTINCT shopper_id) AS cohort_shopper_count
  FROM
    FirstTimeShoppers
  GROUP BY
    cohort_year,
    cohort_month
),

TotalShopperCounts AS (
  SELECT
    YEAR(order_date) AS total_year,
    EXTRACT(MONTH FROM order_date) AS total_month,
    COUNT(DISTINCT shopper_id) AS total_shopper_count
  FROM
    sales_orders
  GROUP BY
    total_year,
    total_month
),

Repeat30Days AS (
  SELECT
    fs.cohort_year,
    fs.cohort_month,
    COUNT(DISTINCT so.shopper_id) AS repeat_30_days
  FROM
    FirstTimeShoppers fs
  JOIN
    sales_orders so ON fs.shopper_id = so.shopper_id
    AND so.order_date BETWEEN fs.first_purchase_date AND DATE_ADD(fs.first_purchase_date, INTERVAL 30 DAY)
    AND DATEDIFF(so.order_date, fs.first_purchase_date) <= 30 
  WHERE
    so.order_date > fs.first_purchase_date 
  GROUP BY
    fs.cohort_year,
    fs.cohort_month
),

Repeat60Days AS (
  SELECT
    fs.cohort_year,
    fs.cohort_month,
    COUNT(DISTINCT so.shopper_id) AS repeat_60_days
  FROM
    FirstTimeShoppers fs
  JOIN
    sales_orders so ON fs.shopper_id = so.shopper_id
    AND so.order_date BETWEEN fs.first_purchase_date AND DATE_ADD(fs.first_purchase_date, INTERVAL 60 DAY)
    AND DATEDIFF(so.order_date, fs.first_purchase_date) BETWEEN 31 AND 60 
  WHERE
    so.order_date > fs.first_purchase_date 
  GROUP BY
    fs.cohort_year,
    fs.cohort_month
)

SELECT
  CONCAT(cs.cohort_year, '-', LPAD(cs.cohort_month, 2, '0')) AS cohort_year_month,
  cs.cohort_shopper_count,
  tsc.total_shopper_count,
  COALESCE(r30.repeat_30_days, 0) AS bucket_30d_count,
  COALESCE(r60.repeat_60_days, 0) AS bucket_60d_count,
  CASE
    WHEN tsc.total_shopper_count > 0 THEN
      (COALESCE(r30.repeat_30_days, 0) / tsc.total_shopper_count)
    ELSE 0
  END AS bucket_30d_ratio,
  CASE
    WHEN tsc.total_shopper_count > 0 THEN
      (COALESCE(r60.repeat_60_days, 0) / tsc.total_shopper_count)
    ELSE 0
  END AS bucket_60d_ratio
FROM
  CohortShopperCounts cs
LEFT JOIN
  Repeat30Days r30 ON cs.cohort_year = r30.cohort_year AND cs.cohort_month = r30.cohort_month
LEFT JOIN
  Repeat60Days r60 ON cs.cohort_year = r60.cohort_year AND cs.cohort_month = r60.cohort_month
LEFT JOIN
  TotalShopperCounts tsc ON cs.cohort_year = tsc.total_year AND cs.cohort_month = tsc.total_month
ORDER BY
  cs.cohort_year,
  cs.cohort_month;


