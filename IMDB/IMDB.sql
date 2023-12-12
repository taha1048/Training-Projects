use portfolio_projects;

-- data exploration
select * from imdb
where Series_Title is null;  -- no nulls
select distinct Certificate from imdb; 
select distinct Genre from imdb;
select Released_Year from imdb;
select count(*) as a,count(distinct Series_Title) as b from imdb ; -- there is one duplicate

-- fixing some missing data
SET SQL_SAFE_UPDATES = 0;
update imdb
set Certificate ='Unrated'
where Certificate is null;

-- creating a view for clean data (830 rows of 1000)
create view cls_imdb as 
select * from (
select *, row_number() over(partition by Series_Title,Runtime) as rn
from imdb )m
where rn =1 and Gross is not null
and Released_Year <> 'PG' ; -- we can search for the Released_Year for this movie as it's only one record

-- What are the top 10 movies with the highest IMDB ratings?
select Series_Title, IMDB_Rating
 from cl_imdb
order by IMDB_Rating desc,Meta_score desc,No_of_Votes desc
limit 10;

-- What are the total number of votes received for each certificate category?
select Certificate, sum(No_of_Votes) as Total_Votes 
from cl_imdb
group by Certificate
order by Total_Votes desc;

-- How many movies were released in each year?
select Released_Year, count(Series_title) as total_Movies
from cl_imdb 
group by Released_Year
order by Total_Movies desc;

-- What is the average runtime of movies in the dataset?
select  round(avg(min),0) as Avg_Runtime -- , Released_Year
from 	(
	select Released_Year, substring_index(Runtime," ",1) as min
	from cl_imdb)s;
-- group by Released_Year

-- Which star (actor/actress) appears most frequently in the dataset?
-- for Each role
select Star1 ,count(*) as appearence    -- same for star 2,3,4
from cl_imdb 
group by Star1 -- 2,3,4
having appearence >1
order by appearence desc;
-- cross all
with cte as (
		select Star1 as stars,count(*) as appearence , 'Star1'    -- same for star 2,3,4
		from cl_imdb 
		group by Star1 
		having appearence >1
union all
		select Star2,count(*) as appearence  ,'Star2'  -- same for star 2,3,4
		from cl_imdb 
		group by Star2 
		having appearence >1
union all 
		select Star3,count(*) as appearence, 'Star3'    -- same for star 2,3,4
		from cl_imdb 
		group by Star3 
		having appearence >1
union all 
		select Star4,count(*) as appearence, 'Star4'    -- same for star 2,3,4
		from cl_imdb 
		group by Star4 
		having appearence >1)
select stars,sum(appearence) as Total_appearence 
from cte
group by stars
order by Total_appearence desc;

-- Which genre has the highest number of movies in the dataset?
select Genre , count(*) as Total_Movies
from cl_imdb
group by Genre
order by Total_Movies desc 
limit 5;  -- All about drama -_-

-- Which directors have the highest average IMDB ratings for their movies? Display the top 5 directors.
select Director, round(avg(IMDB_Rating),2) as Avg_Rating,
		count(*) as Total_Movies
from cl_imdb
group by Director
order by Avg_Rating desc
limit 5;

-- How many movies were released for each combination of genre and certificate?
select Genre, Certificate, count(*) as Total_Movies
from cl_imdb
where Genre = 'Drama' -- change the Genre to top five
and Certificate is not null
group by Genre, Certificate 
order by Total_Movies desc;  -- pivot them in excel


-- What is the average/Total gross revenue for movies in each certificate category?
select Certificate, round(Avg(New_Gross),0) as Avg_Gross,
		round(sum(New_Gross),0) as Total_Gross
	from(
		select Certificate,replace(Gross,',','') as New_Gross 
		from cl_imdb
        )m
group by Certificate
order by Total_Gross desc ;


-- How many movies have a meta score greater than 80?
select count(*) as Total_Count 
from cl_imdb
where Meta_score >80;



-- Which year had the highest average IMDB rating for movies released in that year? Show the top 3 years with the highest average rating.
select Released_Year, avg(IMDB_Rating) as Avg_Rating
from cl_imdb 
group by Released_Year
order by Avg_Rating desc 
limit 3;


-- What is the distribution of movie runtimes? Display the count of movies falling within different runtime ranges.
select 
	case
		 when Runtime <=90 then "Below 1.5 h"
		 when Runtime between 90 and 120 then "1.5 h : 2 h"
		 when Runtime between 120 and 180 then "2 h : 3 h"
		 when Runtime>180 then "More than 3 h" 
	end as Runtime_Distribution,
count(*) as Total_Movies 
	from(
		select  substring_index(Runtime," ",1) as Runtime 
		from cl_imdb
		)g
group by Runtime_Distribution 
order by Runtime_Distribution desc ;

-- Who are the top 5 actors/actresses with the highest average IMDB ratings for the movies they starred in?
select Star1, round(avg(IMDB_Rating),2) as Avg_Rating,
		count(*) as Total_Movies  -- change it for star 2,3,4
from cl_imdb
group by Star1
order by Avg_Rating desc
limit 5;


-- How does the average IMDB rating vary across different certificate categories?
select Certificate,round(avg(IMDB_Rating),2) as Avg_Rating
from cl_imdb
group by Certificate
order by Avg_Rating desc;


-- What is the correlation between the number of votes and the IMDB rating of movies in the dataset?
select IMDB_Rating,No_of_Votes
from cl_imdb
order by No_of_Votes desc -- try asc
limit 20; 

-- anthor solution

select segm,round(avg(IMDB_Rating),2) as Avg_Rating
	from (
	select  IMDB_Rating,No_of_Votes,
			ntile(10) over(order by No_of_Votes ) as segm
	from cl_imdb
		) s
group by segm
order by Avg_Rating desc,segm desc; -- it's kind of a linear relationship 





 

