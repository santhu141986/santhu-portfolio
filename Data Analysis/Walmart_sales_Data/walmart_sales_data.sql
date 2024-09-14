-- ----------------- FEATURE ENGINEERING -------------
-- time_of_day
alter table walmartsalesdata
add column time_of_day varchar(20);
update  walmartsalesdata
set time_of_day = 	case
						when `time` between '00:00:00' and '12:00:00' then "Morning"
						when `time` between '12:10:00' and '16:00:00' then "Afternoon" 
						else "Evening"
					end ;
-- day_name    
alter table walmartsalesdata
add column day_name varchar(25);

update walmartsalesdata
set day_name = DAYNAME(date);  

-- month_name
alter table walmartsalesdata
add column month_name varchar(25);

update walmartsalesdata
set month_name = monthname(date);  
-- ----------------------------------------------------------------------------------------
-- --------------------------------BUISNESS QUESTIONS -------------------------------------
-- 1. How many unique cities does the data have?
select 
	count(distinct city)
from
	walmartsalesdata;
-- 2. In which city is each branch?
select
	city,
    branch
from
	walmartsalesdata
group by
	1,2;
-- 3 How many unique product lines does the data have?
select
	Product_line,
	count(distinct Product_line)
from
	walmartsalesdata
group by
	Product_line;
-- 4 What is the most selling product line?
select
	Product_line,
    count(invoice_id) as selling_count
from
	walmartsalesdata
group by
	1
order by
	2 desc;
-- 5 What is the most common payment method?
select
	 payment,
     count(payment) as count_of_payment_methods
from
	walmartsalesdata
group by
	payment
order by
	2 desc;
-- 6 What is the total revenue by month?
select
	month_name,
    sum(total) as total_sales
from
	walmartsalesdata
group by
	1
order by
	2 desc;
-- 7 What month had the largest COGS?
select
	month_name,
    sum(cogs) as total_cogs
from
	walmartsalesdata
group by
	1
order by
	2 desc;
-- 8 What product line had the largest revenue?
select
	Product_line,
    sum(total) as total_sales
from
	walmartsalesdata
group by
	1
order by
	2 desc;
-- 9 What is the city with the largest revenue?
select
	city,
	sum(total) as total_sales
from
	walmartsalesdata
group by
	1
order by
	2 desc;
-- 10 What product line had the largest VAT?
select
	product_line,
    avg(tax_pct) as avg_tax
from
	walmartsalesdata
group by
	1
order by
	2 desc;
-- 11 Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

with avg_product_line_sales as 
(
select
	product_line,
    avg(total) as avg_sales_productline
from
	walmartsalesdata
group by
	1
),
avg_sales_all as
(
select
	avg(total) as avg_sales
from
	walmartsalesdata
)

select
	avg_product_line_sales.avg_sales_productline,
	case
		when avg_product_line_sales.avg_sales_productline > avg_sales_all.avg_sales then "Good"
        else "Bad"
	end quality_product        
from	avg_product_line_sales,avg_sales_all;

-- 12 Which branch sold more products than average product sold?
select			branch
				,sum(quantity) as qty
from			walmartsalesdata
group by		1
having			sum(quantity) > (select	avg(quantity) from walmartsalesdata);

-- 13 What is the most common product line by gender?
select		gender
			,product_line
            ,count(product_line) as total_count
from		walmartsalesdata
group by	1,2
order by	3 desc;
-- 14 What is the average rating of each product line?
select		product_line
			,avg(rating) as avg_rating
from		walmartsalesdata
group by	1
order by	2 desc;

-- 15 Number of sales made in each time of the day per weekday
select		time_of_day
			,count(*) as Number_of_sales
from		walmartsalesdata
where		day_name = "Sunday"
group by	1;

-- 16 Which of the customer types brings the most revenue?
select		customer_type
			,sum(total) as total_sales
from		walmartsalesdata
group by	1
order by	2 desc;

-- 17 Which city has the largest tax percent/ VAT (Value Added Tax)?
select		city
			,avg(tax_pct) as tx_perc
from		walmartsalesdata
group by	1
order by	2 desc;

-- 18 Which customer type pays the most in VAT?
select		customer_type
			,avg(tax_pct) as tx_perc
from		walmartsalesdata
group by	1
order by	2 desc;

-- 19 How many unique customer types does the data have?
select	  	distinct customer_type as unique_cust_type
from		walmartsalesdata;

-- 20 How many unique payment methods does the data have?
select	  	distinct payment as unique_cust_type
from		walmartsalesdata;

-- 21 What is the most common customer type?
select		customer_type
			,count(customer_type) as count_of_cust_type
from		walmartsalesdata
group by	1
order by	2 desc;

-- 22 Which customer type buys the most?
select		customer_type
			,count(*) as count_of_inv
from		walmartsalesdata
group by	1
order by	2 desc;

-- 23 What is the total number of gender per branch?
select		branch
			,count(gender) as gender_count
from		walmartsalesdata
group by	1;

-- 24 Which time of the day do customers give most ratings?
select		time_of_day
			,round(avg(rating),2) as avg_rating
from		walmartsalesdata
group by	1;





		




	