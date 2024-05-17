SELECT * FROM amazon.`amazon (1)`;
use amazon;
 SHOW COLUMNS FROM `amazon (1)`;
 
 -- Feature Engineerig    (using ddl and dml coomands)
-- 1. Adding new column named timeofday to give insight of sales in the Morning, Afternoon, and EVening

Alter table `amazon (1)` #alter is a part of ddl
add column time_of_day varchar(50);                                          # New column created time_of_day


-- Assuming you want to update an existing column named 'time_Of_day'
UPDATE  `amazon (1)`
SET time_Of_day = 
    CASE 
        WHEN HOUR( `amazon (1)`.time) >= 0 AND HOUR( `amazon (1)`.time) < 12 THEN 'morning'
        WHEN HOUR( `amazon (1)`.time) >= 12 AND HOUR( `amazon (1)`.time) < 18 THEN 'afternoon'
        ELSE 'evening'
    END;

-- 2. Adding new column named dayname that contains the extracted days of teh week on which the given transaction took place.
    
    Alter table  `amazon (1)`                                            #New column created 
    add column day_names varchar(50);
    
    Update  `amazon (1)`                                                   # column 'day_name' updated with date_format to get weekday name
    set day_names = Date_format( `amazon (1)`.Date, '%a');                  # %a	Abbreviated weekday name (Sun..Sat)
    
    
-- 3. Add a new column monthname that contains the extracted month of the year on which the given transaction took place.
	
    Alter table  `amazon (1)`                                                 # New column created 'month_name'
    add column month_name varchar(50);                                 
    
    Update  `amazon (1)`                                                      # column 'month_name' updated to get first theree letters of months
    set month_name = date_format( `amazon (1)`.date, '%b');                   # Abbreviated month name (Jan..Dec)
    
    
    -- 1.What is the count of distinct cities in the dataset?
select count(distinct city) as cities from `amazon (1)`;

-- only 3 distinct cities are present in dataset
--------------------------------------------------------------------------

-- 2. For each branch, what is the corresponding city?
select distinct branch, city from `amazon (1)`;                #distinct to get, unique branch and city

-- there are 3 unique branches corresponding to 3 unique branch and city
------------------------------------------------------------------------------------------------------------

-- 3. What is the count of distinct product lines in the dataset?
Select count( distinct `Product line`) as Prouduct_line
FROM `amazon (1)`;

-- in dataset, there are 6 product lines
----------------------------------------------------------------------------------------------------

-- 4.Which payment method occurs most frequently?
select  max(payment) as payment_method from `amazon (1)`;   #max is used to get the maximum number of payment type used

-- among payment method , 'ewallet' is most frequently used
----------------------------------------------------------------------------------


-- 5.Which product line has the highest sales?
select `Product line`, -- selecting the product line
count(`Invoice ID`) as sales_count -- counting the number of 'invoice id' by aliasing
from `amazon (1)`
group by `product line` -- grouping the results by product line
order by sales_count desc -- ordering the results by sales_count(no. of invoice id) in des
 limit 1;-- limiting the result to only the top (highest) sales count

-- 'Fashion accessories' has the highest sales
-----------------------------------------------------------------------------------------

-- 6. How much revenue is generated each month?

select distinct(month) from `amazon (1)`;  -- only 3 month in the dataset

select month_name, count(`invoice id`) as monthly_revenue            
from `amazon (1)`
group by `month_name`;

 -- Januaru received the highest revenue of all the three months.
-------------------------------------------------------------------------------------

-- 7. In which month did the cost of goods sold reach its peak?            cogs = cost of goods solds
select month_name, sum(cogs) as total_cogs 
from `amazon (1)`
group by month_name  -- grouping the result by month
order by total_cogs desc -- ordering the results by total_cogs(total cogs) in desc order
limit 1; -- limiting the result to only the top(highest) total_cogs
--------------------------------------------------------------------------------------------------

-- 8. Which product line generated the highest revenue?         total = cost of goods solds + taxes involved

select `product line`, 
sum(total) as total_revenue -- calculating total revenue for each product line
from`amazon (1)`
group by `product line` 
order by total_revenue desc
limit 1; -- limiting the result to only top (highest) total_revenue

-- among 6 unique product line, food and bevarages received the highest revenue in total
---------------------------------------------------------------------------------------------------------

-- 9. In which city was the highest revenue recorded?
select city, sum(total) as high_revenue
from `amazon (1)`
group by city
order by high_revenue desc;

-- out of 3 unique cities , Naypyitaw has received teh collection of the highest revenue

---------------------------------------------------------------------------------------------

-- 10. Which product line incurred the highest Value Added Tax?

select `product line`, 
sum(`tax 5%`) as total_vat_amount -- calculating the total vat amount for each product line and
from `amazon (1)`
group by `product line` 
order by total_vat_amount desc
limit 1; 
---------------------------------------------------------------------------------------------

-- 11. For each product line,
-- add a column indicating "Good" if its sales are above average, otherwise "Bad."
select `product line`,
Case
when `gross income` > (select avg(`gross income`) from `amazon (1)`) then "good"
else "bad"
end as sales_performance
from `amazon (1)`;

---------------------------------------------------------------------------------------------------------------

-- 12. Identify the branch that exceeded the average number of products sold.
select distinct branch from `amazon (1)`
where quantity > (
select avg(quantity) 
from `amazon (1)`);
-- All three branches have exceeded the avg number of product 
------------------------------------------------------------------------------
-- 13. Which product line is most frequently associated with each gender?
With ranked_product_lines as                                          -- using cte (common table expression) named ranked_product_lines
( select gender, `product line`, count(*) as product_line_count,
rank() over(partition by gender order by count(*) desc) as rank_num                                              
from `amazon (1)`
group by gender, `product line`)
select gender, `product line`, product_line_count
from ranked_product_lines
where rank_num = 1;

-- CTE used with windows rank function to get the most frequent product line associated with each gender.
------------------------------------------------------------------------------------------------------------------
-- 14. Calculate the average rating for each product line.
select `product line`, avg(rating) as avg_rating
from `amazon (1)`
group by `product line`;

-- average method to get avg rating for each product lines in the dataset. From this we can say that
-- food and beverates get the highest avg rating followed by Fashion accessories and Health and beauty

------------------------------------------------------------------------------------------------------------------------------------

-- 15.Count the sales occurrences for each time of day on every weekday.
select day_names, time_of_day, count(*) as sale_occur
from `amazon (1)`
group by day_names, time_of_day
order by  day_names, sale_occur desc ;

-- Count method to get the count of sales occur on a particular weekday and on particular tim eof that weekday.
-- we can say that every weekday most sales occur during the Afternoon time (between 12 to 6 PM)

------------------------------------------------------------------------------------------------------------------------
-- 16. Identify the customer type contributing the highest revenue.
select `customer type`, sum(total) as revenue -- calcaulating the total revenue for each customer type
from `amazon (1)`
group by  `customer type` 
order by revenue desc;

-- Out to two customer type, member customers contribute highest in the revenue.
-----------------------------------------------------------------------------------------------------------------------------
-- 17. Determine the city with the highest VAT percentage.     -- vat= amount of tax on the purchase
select city,
sum(`Tax 5%`) as high_vat, sum(total) as total_rev, 
(sum(`tax 5%`)/sum(total))*100 AS vat_percent -- calculating the vat percenage using sum(`tax 5%) divided by sum(total)and multiplying by 100
from `amazon (1)`
group by city
order by vat_percent desc;
------------------------------------------------------------------------------------------------------------
-- 18. Identify the customer type with the highest VAT payments.
select `customer type`,
sum(`tax 5%`) as high_vat
from `amazon (1)` 
group by `customer type`
order by high_vat desc;

-- from above we can say that Member customers contribute maximum to the revenue and so its obvious that 
-- they pay more than normal customers
-----------------------------------------------------------------------------------------------------------

-- 19. What is the count of distinct customer types in the dataset?
select count(distinct `customer type`) as customer_type_count
from `amazon (1)`;

-- There are tow types of customer in the dataset 1. member 2. customers
----------------------------------------------------------------------------------------------------------
 
 -- 20. What is the count of distinct payment methods in the dataset?
select count(distinct payment) as payment_method_count
from `amazon (1)`;

-- There are 3 distinct types of payment methods - Ewallet, cash and credit card.
----------------------------------------------------------------------------------------------------------------

-- 21. Which customer type occurs most frequently?
select `customer type`, count(*) as most_freq
from `amazon (1)`
group by `Customer type`;

-- Memners types customer occurs to purchase more frequently.
--------------------------------------------------------------------------------------------------------------------

-- 22. Identify the customer type with the highest purchase frequency.
select `customer type`, sum(quantity) as high_pur_freq
from `amazon (1)`
group by `Customer type`
order by high_pur_freq
limit 1;

-- Memger type of customer purchase goods more frequently.
-----------------------------------------------------------------------------------------------------------------

-- 23. Determine the predominant gender among customers.
select gender, count(*) customer_count
from `amazon (1)`
group by gender
order by customer_count desc
limit 1;

-- Although there is not much difference in gender in contribution but yes 'Female' contributes more tha 'males'
-------------------------------------------------------------------------------------------------------
-- 24.  Examine the distribution of genders within each branch.
select branch, gender, count(gender) as gender_dist
from `amazon (1)`
group by branch, gender
order by branch, gender_dist desc;

-- Branch wise contribution of gender says that in Branch A and B 'males' are prominent but in branch C 'female' contributes more
--------------------------------------------------------------------------------------------------------------
-- 25. Identify the time of day when customers provide the most ratings.
select time_of_day, count(rating) as rating_count
from `amazon (1)`
group by time_of_day
order by rating_count desc;

-- Most number of rating are providing during Afternoon.
----------------------------------------------------------------------------------------------

-- 26. Determine the time of day with the highest customer ratings for each branch.
select branch, time_of_day, count(rating) as rating_count
from `amazon (1)`
group by branch, time_of_day
order by branch desc;

-- for all the three branches afternoon is the time when they get their most number of rating
---------------------------------------------------------------------------------------------------

-- 27. Identify the day of the week with the highest average ratings.
select day_names, avg(rating) as avg_rating
from `amazon (1)`
group by day_names
order by avg_rating desc
limit 1;

-- In all the alter Weekdays, Monday is the day when highest avg ratings received.
-------------------------------------------------------------------------------------------------------------

-- 28.Determine the day of the week with the highest average ratings for each branch.

WITh branch_high_rating as
(select branch, day_names, avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc)  as rank_num
from `amazon (1)`
group by branch, day_names)
select branch, day_names, avg_rating
from branch_high_rating
where rank_num = 1;

-- To get the Average rating for each branch with the weekday names, CET is used with windows rank function.
-- from above code we can say that, for branch B, Monday is the day which gets highest avg rating and 
-- for branch A and C its Friday.
-----------------------------------------------------------------------------------------------------------------
















