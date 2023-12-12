use portfolio_projects;
select * from hotel;
                                                  -- Data Cleaning
-- fixing the Headers
alter table hotel
drop column `Unnamed: 17`, -- unwanted column
rename column `Arrival Date` to Arrival_Date,
rename column `Cancelled (0/1)` to Cancelled,
rename column `Booking ID` to Booking_ID,
rename column `Booking Date` to Booking_Date,
rename column `Lead Time` to Lead_Time,
rename column `Distribution Channel` to Dis_Channel,
rename column `Customer Type` to Customer_Type,
rename column `Deposit Type` to Deposite_Type,
rename column `Avg Daily Rate` to Avg_Daily_Rate,
rename column `Status Update` to Status_Update,
rename column `Revenue Loss` to Revenue_Loss;


-- Reformatting columns
SET SQL_SAFE_UPDATES = 0;
update hotel
set 
	Revenue= trim(substring_index(Revenue,'$',-1)),
    Avg_Daily_Rate= trim(substring_index(Avg_Daily_Rate,'$',-1)),
    Revenue_Loss= trim(substring_index(Revenue_Loss,'$',-1)),
    Booking_Date= date(Booking_Date),
	Arrival_Date= date(Arrival_Date),
	Status_Update= date(Status_Update) ;
update hotel
set  Revenue_Loss= Revenue_Loss * (-1) where Revenue_Loss <> 0 ; -- can't use the same column twice in one update


-- checking for duplicates
select 
	count(*), count( distinct Booking_ID)
from 
	hotel ;    -- no duplicates




-- Exploring the data
select * from hotel;

														-- Categories
select 
	distinct Dis_Channel -- Customer_Type, Deposite_Type, Hotel 
from 
	hotel;

 
													-- Revenue Segments
select 
	(select count(*) from hotel where Revenue <> 0 and Revenue_Loss= 0) as Profit,
    (select count(*) from hotel where Revenue = 0 and Revenue_Loss= 0) as Non_Profit,
    (select count(*) from hotel where Revenue = 0 and Revenue_Loss <> 0) as Loss ; -- summing the results, it's the same as total count

alter table hotel 
add column Revenue_segm varchar(255) ;

SET SQL_SAFE_UPDATES = 0;
update hotel 
set Revenue_segm =
	case 
        when Revenue <> 0 and Revenue_Loss = 0 then 'Profit'
        when Revenue = 0 and Revenue_Loss = 0 then 'Non Profit'
        when Revenue = 0 and Revenue_Loss <> 0 then 'Loss' 
	end;


													-- Comparison
select 
	Hotel, Revenue_segm,   -- Customer_Type, Deposite_Type, Dis_Channel 
    count(*) Total_Counts
from 
	hotel 
group by 
	Hotel, Revenue_segm
order by 
	Revenue_segm , Total_Counts desc ;
    
/*
Non-Profit reservations are all with no-deposites, 
non-refundable has only profits, 
no-deposite has losses higher than refundable 
*/


select * ,      row_number() over(order by tot desc ) as _rows 
from (
select 
	 Dis_Channel  , Customer_Type,  
     count(*) as tot
from 
	hotel
group by  Dis_Channel  , Customer_Type
order by tot desc
) m ;


														-- Cancellation
select 
		Cancelled, Revenue_segm, Deposite_Type,
		count(*) as total_count
from 
		hotel
group by 
		Cancelled, Revenue_segm, Deposite_Type 
order by 
		Cancelled;
/*
almost all non-refundable reservations are cancelled, that might be an issue.
no check-out has a loss, either non-profit or profit
no-deposite cancelled reservations have high losses
*/

														-- Status 
select Status, Deposite_Type, Cancelled,
		count(*) as total_count
from hotel
-- where Status="NO-Show"
group by Status, Deposite_Type, Cancelled;
/* 
people who didn't show at all are with no-deposite
*/



select status , diff - Lead_time as Additional_Days
from  (
select Booking_Date, Arrival_Date, Lead_Time,
		Status_Update, Status, Deposite_Type,
		datediff(Status_Update,Booking_Date) as diff
from hotel
-- where Status = 'Check-Out'
-- where Status = 'Canceled'
-- where Status = 'No-Show'           		-- wrong entry 
		)m
-- 	where Lead_Time = diff
    where Lead_Time <> diff;
/*
it turned out that the majority of reservations don't meet the lead time but exceed it
some of them were canceled at the end of lead time (no-show) and others weren't  
until they were checked out. why? may be if we message them or give them more time they 
would check-out also.
*/ 


select Lead_segm, 
		Revenue_segm, count(*) as total
from 
		(
	select Lead_Time,
			case 
				when Lead_Time between 0 and 90 then "less than 3 Month"
				when Lead_Time between 90 and 180 then "between 3 and 6"
				when Lead_Time between 180 and 270 then "between 6 and 9"
				when Lead_Time between 270 and 365 then "between 9 and 12"
				when Lead_Time > 365 then "more than year" 
			end as Lead_segm,
			Revenue_segm   -- change the status with Revenue_segm
	from hotel
		) m
-- where status ="Canceled"
group by Lead_segm, Revenue_segm
order by Lead_segm, total desc ;
/* 
canceled reservations with lead_time more than 9 months are 
almost two times bigger than checked-out ones.
let's look at them
*/



select Lead_segm, Deposite_Type, Revenue_segm, count(*) as total_count
from (
	select Lead_Time,
			case 
				when Lead_Time between 0 and 90 then "less than 3 Month"
				when Lead_Time between 90 and 180 then "between 3 and 6"
				when Lead_Time between 180 and 270 then "between 6 and 9"
				when Lead_Time between 270 and 365 then "between 9 and 12"
				when Lead_Time > 365 then "more than year" 
			end as Lead_segm, 
            Deposite_Type, Revenue_segm, status
			
	from hotel
    where status = "Canceled"
    ) mm
where Lead_segm = "between 9 and 12" or Lead_segm = "more than year" 
group by Lead_segm, Deposite_Type, Revenue_segm
order by Lead_segm, total_count desc;
/* 
despite high cancelations, they are still making some profit so we can  
make all reservations with lead time over than 9 months non refundable 
 or partly refundable to avoid some losses.
*/
 

