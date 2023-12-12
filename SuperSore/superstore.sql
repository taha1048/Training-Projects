use portfolio_projects;
select * from train;

-- select wanted data
create view train1 as 
select `order ID` as order_id,
		`ship mode` as ship_mode,
        str_to_date(`order Date`,"%d/%m/%Y") as order_date,
        Segment,
		State,
        Region,
        Category, `Sub-Category` as sub_category,
        Sales,
        datediff(str_to_date(`ship Date`,"%d/%m/%Y"),str_to_date(`order Date`,"%d/%m/%Y")) as ship_days,
        `Customer Name` as customer_name
from train;

-- month
select * from (
	select *,row_number() over(partition by year order by total_sales desc) month_Rank
	from (
		select year(order_date) as year,
				month(order_date) as month,
				round(sum(Sales)) as total_sales,
                count(*) total_quantity
		from train1
		group by year,month
		)m
			)mm
where month_Rank=1 or month_Rank=12 ;
-- top selling months are always between 11 & 12 & 9 
-- less selling are always 1 & 2 

-- quarter
select * from (
	select *,row_number() over(partition by year order by total_sales desc) month_Rank
	from (
		select year(order_date) as year,
				-- month(order_date) as month,
                quarter(order_date) as quarter,
				round(sum(Sales)) as total_sales,
                count(*) total_quantity
		from train1
		group by year,quarter
		)m
			)mm
where quarter =1 or quarter=4;
-- sales are going up with quarters
-- also we have increase in sales per each quarter compared to the previous year except for q3 in 2016 and 2017 and also q1 in 2016

-- Region
select *,row_number() over(partition by Region order by total_sales desc) Year_Rank
    from (
select Region,year(order_date) as year,
		round(sum(Sales)) as total_sales
from train1
group by Region,year
order by Region,year
		)m ;
-- 2016 had the lowest sales over all Regions except for the East
-- we have upgrowing in sales over years in the East
-- also in the Central we have 2017 on the top that was an exception cuz 2018 is on the top in the other Regions


-- Avg per week day 
select dayname(order_date) as Days,
		round(avg(Sales)) as Avg_Sales
 from train1
 group by Days;


-- category & Segment, ship_mode
select category,round(sum(Sales)) as total_sales,
		round((sum(Sales)/(select sum(Sales) from train1))*100) as sales_percentage
from train1
group by category;

select  Region, avg (ship_days) 
from train1
where ship_days <>0
group by Region





