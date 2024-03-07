
-- 1.List the total number of reported crimes between 2018 and 2022.
select 
Year(c.reported_crime_date) as years,
count(*) as [Reported Crime]
from Chicago.crime as c
where year(c.reported_crime_date) between 2018 and 2022
group by Year(c.reported_crime_date)
order by Year(c.reported_crime_date)

--2.List the total number of homicides, batteries and assaults reported between 2018 and 2022.
select
crime_type,
count(*) as [Numnber of Crime]
from Chicago.crime
where crime_type in ('homicide', 'battery', 'assault')
group by crime_type


--3.Which are the most common crimes reported and what percentage amount are they from the total amount of reported crimes?
with percentages
as (
select
crime_type,
count(*) as number
from chicago.crime
group by crime_type
)
select 
crime_type,
round(cast(number as float) * 100 /(select sum(number) from percentages),2) as [Percentage]
from percentages

--4.What are the top ten communities that had the MOST number of crimes reported? Include the current population, 
--density, and order by the number of reported crimes.

select top 10
n.community_name,
n.population as [population],
n.density,
count(c. crime_type) as [Number of Crimes]
from chicago.crime c
join chicago.community n
on c.community_id = n.community_id
group by n.community_name, n.population, n.density
order by [Number of Crimes] desc

--5.What are the top communities that had the LEAST number of crimes reported? 
--Include the current population, density, and order by the number of reported crimes.
select TOP 1
n.community_name,
n.population as [population],
n.density,
count(c. crime_type) as [Number of Crimes]
from chicago.crime c
join chicago.community n
on c.community_id = n.community_id
group by n.community_name, n.population, n.density
order by [Number of Crimes] ASC

--6.What month had the most crimes reported and what was the average and median temperature high in the last five years?
with subquery as
(select 
        w.weather_date,
	    c.crime_type,
        temp_high,
	PERCENTILE_DISC(0.5) within group (order by temp_high) over (partition by (month(w.weather_date))) as mediantemp
    from chicago.crime c
    join chicago.weather w
    on c.reported_crime_date = w.weather_date
    group by w.weather_date,c.crime_type, w.temp_high
	
)
select top 1
    MONTH(weather_date) AS Mon,
        COUNT(crime_type) OVER (PARTITION BY MONTH(weather_date)) AS crimenum,
        AVG(temp_high) OVER (PARTITION BY MONTH(weather_date)) AS averagehigh,
        AVG(mediantemp) OVER (PARTITION BY MONTH(weather_date)) AS mediantemp
from subquery
group by Month(weather_date), temp_high, mediantemp, crime_type
order by crimenum desc

--7.What month had the most homicides reported and what was the average and median temperature high in the last five years?
with subquery as (
select 
    w.weather_date,
	c.crime_type as homicide,
	w.temp_high
	from chicago.crime c
	join chicago.weather w
	on c.reported_crime_date = w.weather_date
	where c.crime_type = 'homicide'
) 
select top 1 
    MONTH(weather_date) as Mon,
	count(homicide) over (partition by (MONTH(weather_date))) as homicount,
	AVG(temp_high) OVER (PARTITION BY MONTH(weather_date)) AS averagehigh,
	PERCENTILE_DISC(0.5) within group (order by temp_high) over (partition by (month(weather_date))) as mediantemp
	from subquery
	group by MONTH(weather_date), temp_high, homicide
	order by homicount desc

-- 8.List the most violent year and the number of arrests with percentage.
-- Order by the number of crimes in descending order. Determine the most violent year by the number of reported Homicides, 
-- Assaults and Battery for that year.
select
   Year(reported_crime_date) as Years,
   count(crime_type)  as[Violentnum],
   sum(cast(arrest as float)) as arrest,
   round(sum(cast(arrest as float)) * 100/ count(crime_type),2) as percentages
from 
    chicago.crime
where crime_type in ('homicide', 'assault', 'battery')
group by Year(reported_crime_date)

--9. List the day of the week, year, average precipitation,
-- average high temperature and the highest number of reported crimes for days with and without precipitation.

select * from chicago.weather
select * from chicago.crime

select
day(c.reported_crime_date) as daayofmonth,
DATEPART(WEEKDAY, c.reported_crime_date) as weekdays,
DATEPART(DAYOFYEAR, c.reported_crime_date) as [Day of Year],
AVG(w.precipitation) as avgprecip,
avg(w.temp_high) as avgtemp,
count(c.crime_type) as [reportednum]
from chicago.crime c
join chicago.weather w
on c.reported_crime_date = w.weather_date
group by reported_crime_date
order by reportednum

--10. List the days with the most reported crimes when there is zero precipitation and the day when precipitation is greater than 5. 
--Including the day of the week, high temperature, amount and precipitation and the total number of reported crimes for that day.

select 
DATEPART(WEEKDAY, c.reported_crime_date) as [Day of Week],
w.temp_high,
count(temp_high) as [Crime Amount],
sum(cast(w.precipitation as float)) as Precipitation
from chicago.crime c
join chicago.weather w
on c.reported_crime_date = w.weather_date
group by DATEPART(WEEKDAY, c.reported_crime_date), temp_high
having sum(cast(w.precipitation as float)) <>0 and sum(cast(w.precipitation as float)) > 5

--11. List the most consecutive  days where a homicide occurred between 2018-2022 and the timeframe.
select * from chicago.crime
select * from chicago.weather

WITH homicidedate as (
select 
    c.reported_crime_date,
	CRIME_TYPE,
	ROW_NUMBER() over (order by c.reported_crime_date) as rownumber
	from chicago.crime c
	where c.crime_type = 'homicide'
),
consecutive_date as (
select 
reported_crime_date,
DATEADD(day, -ROW_NUMBER() over (order by reported_crime_date), reported_crime_date) as grp
from homicidedate
)
select TOP 1
MIN(reported_crime_date) as [start_date],
MAX(reported_crime_date) as end_date,
DATEDIFF(day, MIN(reported_crime_date), MAX(reported_crime_date)) + 1 as consecutive
from consecutive_date
group by grp
order by consecutive desc






--12. What are the top 10 most common locations for reported crimes and the number of reported crime ( add percentage) ?
with subquery as (
select 
cast(location_description as nvarchar(max)) as location,
count(crime_type) as reportedcrime,
rank() over (order by count(*) desc) as rank
--count(crime_type) *100/ sum(cast(count(crime_type) as float)) as Percentages
from chicago.crime
group by cast(location_description as nvarchar(max))
)
select top 10
    location,
	round(reportedcrime * 100 / sum(cast(reportedcrime as float)) over (), 3) as Percentages
from subquery
group by location ,reportedcrime
order by Percentages desc

--13.Calculate the year-over-year growth in the number of reported crimes.

with subquery as (
select 
    Year(c.reported_crime_date) as [Year],
	cast(count(*) as float) as crimeamount
from chicago.crime c
group by Year(c.reported_crime_date)
)
select 
     [Year],
	 crimeamount,
	 LAG(crimeamount) over (order by [Year]) as prev_year_crimes,
	 round((crimeamount-LAG(crimeamount) over (order by [Year])) *100/ NULLIF(LAG(crimeamount) over (order by [Year]),0),2) as YoYgrowth
from subquery

--14. Calculate the year over year growth in the number of reported domestic violence crimes.
select * from chicago.crime
with subquery as (
select
    Year(c.reported_crime_date) as [Year],
	sum(cast(c.domestic as int)) as violence

from chicago.crime c
group by Year(c.reported_crime_date)
)
select 
    Year,
	violence,
	LAG(violence) over (order by Year) as pre_year_domes,
	(violence - LAG(violence) over (order by Year)) * 100/ LAG(violence) over (order by Year) as YoYGrowth
from 
    subquery

--15. List the number of crimes reported and seasonal growth for each astronomical season and what was the average temperature for each season in 2022?
-- Use a conditional statement to display either a Gain/Loss for the season and the season over season growth.

with subquery as(
select 
    c.reported_crime_date,
    case
	    when Month( c.reported_crime_date) in (12,1,2) Then 'Winter'
	    when Month( c.reported_crime_date) in (3,4,5) Then 'Spring'
	    when Month( c.reported_crime_date) in (6,7,8) Then 'Summer'
	    else  'Fall'
	end as Season,
	c.crime_type, 
	w.average
from chicago.crime c
join chicago.weather w
on c.reported_crime_date = w.weather_date
),
subquery_2 as (
select 
     Year(reported_crime_date) as [Year],
	 Season,
	 count(crime_type) as crimenumber,
	 avg(average) as averagetemp
from subquery
--where Year(reported_crime_date) = 2020
group by Season, Year(reported_crime_date)

)
select 
    Year,
	Season,
	LAG(crimenumber) over (order by Season) as pre_crime_count,
	(crimenumber - LAG(crimenumber) over (order by Season)) *100/ LAG(crimenumber) over (order by Season) as SoSgrowth,
	averagetemp
from subquery_2
WHERE Year = 2022




