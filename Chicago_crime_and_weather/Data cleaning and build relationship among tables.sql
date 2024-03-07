drop table if exists crimes;

create table crimes (
crime_id int PRIMARY KEY IDENTITY,
date_reported datetime,
city_block nvarchar(50),
primary_type nvarchar(50),
primary_description nvarchar(100),
location_description nvarchar(100),
arrest int,
domestic int,
community_area tinyint,
year smallint,
latitue float,
longitute float,
location nvarchar(100));

ALTER TABLE crimes
DROP CONSTRAINT PK__crimes__C10AEBBD94CE994B;
alter table dbo.crimes
DROP COLUMN crime_id;
ALTER TABLE crimes
ALTER COLUMN location text;

-- concatenate all crime tables together to create a new table named crimes
INSERT into dbo.crimes 
select * from dbo.chicago_crime_2018
union 
select * from dbo.chicago_crime_2019
union 
select * from dbo.chicago_crime_2021
union 
select * from dbo.chicago_crime_2022

alter table crimes
add crime_id int identity primary key


------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM DBO.[chicago_temps_18-22]

ALTER TABLE [chicago_temps_18-22]
add weather_id int identity primary key
------------------------------------------------------------------------------------------------------------------------------------
select * from dbo.chicago_areas
select * from dbo.crimes

------------------------------------------------------------------------------------------------------------------------------------
-- create a schema and tables for permenent tables
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Chicago')
BEGIN
    EXEC('CREATE SCHEMA Chicago')
END

DROP TABLE IF EXISTS Chicago.crime

create table Chicago.crime(
crime_id int identity primary key,
reported_crime_date date,
reported_crime_time time,
street_name TEXT,
crime_type TEXT,
crime_description TEXT,
location_description TEXT,
arrest bit,
domestic bit,
community_id int,
latitude float,
longitute float,
crime_location TEXT,
);

SET IDENTITY_INSERT Chicago.crime ON;


INSERT INTO Chicago.crime (
crime_id,
reported_crime_date,
reported_crime_time,
street_name,
crime_type,
crime_description,
location_description,
arrest,
domestic,
community_id,
latitude,
longitute,
crime_location
) select 
c.crime_id,
CAST(c.date_reported as DATE),
CAST(c.date_reported as TIME),
PARSENAME(REPLACE(c.city_block, ' ', ','),4) + ' ' + PARSENAME(REPLACE(C.city_block, ' ', ','), 3),
LOWER(c.primary_type),
LOWER(c.primary_description),
LOWER(c.location_description),
CAST(c.arrest as bit),
CAST(c.domestic as bit),
CAST(c.community_area as int),
CAST(c.latitue as float),
CAST(c.longitute as float),
c.location
from dbo.crimes as c

select * from [Chicago_crime_ and_weather].Chicago.crime
---------------------------------------------------------------------------------------------------------------------------------
SET IDENTITY_INSERT Chicago.community ON;
DROP TABLE IF EXISTS Chicago.community
create table Chicago.community(
community_id int identity primary key,
community_name text,
population int,
area_size float,
density float
)

SET IDENTITY_INSERT Chicago.community ON;

INSERT INTO Chicago.community(
community_name,
population,
area_size,
density
) select
LOWER(d.name),
d.population,
d.area_sq_mi,
d.density
from dbo.chicago_areas as d

-------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Chicago.weather
create table Chicago.weather(
weather_id int identity primary key,
weather_date date unique,
temp_high int,
temp_low int,
average float,
precipitation float
)

SET IDENTITY_INSERT Chicago.weather ON;

INSERT INTO Chicago.weather(
weather_date,
temp_high,
temp_low,
average,
precipitation
)select
W.weather_date,
W.temp_high,
w.temp_low,
w.average,
w.precipitation
from dbo.[chicago_temps_18-22] as w

select * from Chicago.weather
---------------------------------------------------------------------------------------------
--ADD foreign keys to chicago.crime table
alter table Chicago.crime
add constraint fk_community_id
foreign key (community_id)
references chicago.community (community_id)

--add constraint fk_data_reported in crime table in order to reference to weather table
alter table chicago.crime
add constraint fk_date_reported
foreign key (reported_crime_date)
references chicago.weather (weather_date)



----
--DROP TABLE DBO.CRIMES
DROP TABLE DBO.crimes
























