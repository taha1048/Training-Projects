use portfolio_projects;
select * from hr 
limit 2;

                                             -- 1. Attrition Analysis
-- What is the overall attrition rate in the company?
select 
	((
		select count(*) from hr
		where Attrition = 'Yes')/count(*) )*100 as Attrition_Percentage
from hr ;

-- Is there a significant difference in attrition rates between different departments or job roles?
select *, round((Total_Attritions/Total_Employees) * 100,2) as Attrition_Percentage 
from (
			Select a.Department,Total_Employees, Total_Attritions
			from 	(
					select Department,count(*) as Total_Employees
					from hr 
					group by Department) a
			join
					(
					select Department,count(*) as Total_Attritions
					from hr 
					where Attrition = 'Yes'
					group by Department) b
			on a.Department=b.Department
) c    ; -- the same query for the JobRole
-- (Research & Development Department) is less in Attrition_Percentage by 6% compared to other Department
-- (Sales Representative) role has a very high rate (40%) let's find out why
-- Research Director, Manager, Healthcare Representative,and Manufacturing Director are doing well ( <7%)


										-- 2. Employee Demographics
-- What is the distribution of employees by gender, education level, and marital status?
select Gender, MaritalStatus,Education, 
		count(*) as Total_Employees
from hr
group by Gender, MaritalStatus,Education  -- we can group them one by one 
order by Total_Employees desc;
-- answer:
-- the most common case for employees is (male,marrid,education level 3,4) followed by (male,single,education level 3)
										
-- Is there any correlation between age and job level?
select JobLevel,min(Age) as Min_Age,
		avg(Age) as Avg_Age,
		max(Age) as Max_Age,count(*) as Total_Employees
from hr
group by JobLevel
order by JobLevel;
-- answer:
--  it's kind of a Positive relationship between JobLevel & Age, and a negative one for count of employees

											-- 3. Job Satisfaction and Performance:
-- Is there a relationship between job satisfaction and performance ratings?
Select JobSatisfaction, Avg(PerformanceRating) as Avg_PerformanceRating 
from hr
group by JobSatisfaction; -- not working

Select JobSatisfaction, PerformanceRating, 
		count(*) as Total_Employees  
from hr
group by JobSatisfaction, PerformanceRating;
-- answer:
-- every satisfaction level has less than 20% of it's employees with rating 4 


-- Do employees with higher job satisfaction tend to have longer tenures in the company?
Select JobSatisfaction,
		min(YearsAtCompany) as Min_YearsAtCompany, 
		avg(YearsAtCompany) as Avg_YearsAtCompany,
		max(YearsAtCompany) as Max_YearsAtCompany,count(*) as Total_Employees
from hr
group by JobSatisfaction
order by Avg_YearsAtCompany desc; -- not working

select segm, count(*) as Total_Employees ,
		JobSatisfaction
from 	
		(
		select JobSatisfaction,YearsAtCompany,
		case
			when YearsAtCompany between 0 and 10 then "segm1"
            when YearsAtCompany between 11 and 20 then "segm2"
            when YearsAtCompany between 21 and 30 then "segm3"
            when YearsAtCompany between 31 and 40 then "segm4"
		end as segm
		from hr
        ) m
where segm = "segm4"  -- same for 2,3,4       
group by segm, JobSatisfaction
order by Total_Employees desc;
-- answer : 
-- there is no pattern here 


												-- 4. Work-Life Balance:
-- How does work-life balance impact job satisfaction and attrition rates?
select WorkLifeBalance, JobSatisfaction, 
		count(*) as Total_Employees
from hr
where WorkLifeBalance = 1 -- same for 2,3,4
group by WorkLifeBalance,JobSatisfaction
order by WorkLifeBalance,Total_Employees desc;
-- answer:
-- the majority of employees over all Work-Life Balances have 3 or 4 in jobsatisfaction

 -- Attrition
select  c.WorkLifeBalance, a.Total_Employees, 
		c.Total_Attritions, round((c.Total_Attritions/a.Total_Employees) * 100) as percentage
from
					(
			select WorkLifeBalance,count(*) as Total_Attritions
			from hr
			where Attrition = 'Yes' -- same for no
			group by WorkLifeBalance

					) c 
join 
			(
			select WorkLifeBalance,count(*) as Total_Employees
			from hr
			group by WorkLifeBalance
			) a
			on a. WorkLifeBalance=c. WorkLifeBalance;
-- answer:
-- employees with  WorkLifeBalance 1 have the highest attrition rate when 3 has the highest number            
            
            
												-- 5. Career Progression:
-- What is the average number of years employees spend in their current roles before promotion?
select min(YearsInCurrentRole) Min_No,
		avg(YearsInCurrentRole) as Avg_YearsInCurrentRole,
		max(YearsInCurrentRole) Max_NO,
        count(*) as Total_Employees 
from hr
where YearsSinceLastPromotion = 0;

-- Is there a correlation between years in current role and job level?
select JobLevel,min(YearsInCurrentRole) Min_No,avg(YearsInCurrentRole) as Avg_YearsInCurrentRole,
		max(YearsInCurrentRole) Max_NO,count(*) as Total_Employees 
from hr
group by JobLevel
order by Avg_YearsInCurrentRole desc ;
-- answer: 
-- yes the higher YearsInCurrentRole the higher the joblevel

											--  6. Compensation Analysis:
-- How does monthly income vary by job role, department, and education level?
select JobRole,min(MonthlyIncome) Min_sal,
		round(avg(MonthlyIncome)) as Avg_MonthlyIncome,
		max(MonthlyIncome) Max_sal,count(*) as Total_Employees 
from hr
group by JobRole  -- change JobRole with department or EducationField
order by Avg_MonthlyIncome desc;

													-- 7. Employee Tenure:
-- What is the average tenure of employees in the company?
select JobLevel,min(YearsAtCompany) as Min_YearsAtCompany, 
		avg(YearsAtCompany) as Avg_YearsAtCompany,
        max(YearsAtCompany) as Max_YearsAtCompany,count(*) as Total_Employees
from hr
Group by JobLevel  -- change to Department
order by Avg_YearsAtCompany desc; 
-- answer:
-- higher Job levels have higher avg tensure

												-- 8. Impact of Business Travel:
-- Does the frequency of business travel impact attrition rates?
select  c.BusinessTravel, 
		round((c.Total_Employees/a.Total) * 100) as percentage
from
					(
			select BusinessTravel,count(*) as Total_Employees
			from hr
			where Attrition = 'Yes' -- same for no
			group by BusinessTravel

					) c 
join 
			(
			select BusinessTravel,count(*) as Total
			from hr
			group by BusinessTravel
			) a
			on a. BusinessTravel=c. BusinessTravel;
-- answer:
-- yes, it seems to have an impact


												-- 9. Overtime and Productivity:
-- Does working overtime lead to higher performance ratings or higher attrition rates?
select
(select count(*) from hr where OverTime='Yes' and Attrition='Yes') as Yes_Yes,
(select count(*) from hr where OverTime='No' and Attrition='Yes') as No_Yes,
(select count(*) from hr where Attrition='Yes') as total_Attrition;

select
(select count(*) from hr where OverTime='Yes' and PerformanceRating=3) as Yes_3,
(select count(*) from hr where OverTime='No' and PerformanceRating=3) as No_3,
(select count(*) from hr where OverTime='Yes' and PerformanceRating=4) as Yes_4,
(select count(*) from hr where OverTime='No' and PerformanceRating=4) as No_4 ;
-- answer:
-- it doesn't seem to have a relationship

											-- 10. Impact of Distance from Home:
-- Is there a relationship between distancefromhome/StockOptionLevel and attrition rates?
select DistanceFromHome,count(*) as cou
from hr 
where Attrition='Yes'
group by DistanceFromHome  -- StockOptionLevel
order by cou desc;
-- order by cou asc;
-- limit 10

-- answer:
-- there is no pattern here for (DistanceFromHome)
-- the lower the StockOptionLevel the higher the attrition counts



		






