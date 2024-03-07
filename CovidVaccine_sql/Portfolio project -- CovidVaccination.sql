--select * 
--from dbo.CovidVaccination
--order by 3,4

--SELECT * FROM DBO.COVIDDEATHS

-- select date that we are going to use.

select location, date, total_cases, total_deaths, new_cases, population
from Portfolio.dbo.CovidDeaths
order by 1,2

-- Lookint at total_cases and total_deaths
-- shows likelihood of dying if you contract covid in your country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Portfolio.dbo.CovidDeaths
where location like '%china%'
order by 1,2

--Looking at total cases vs population.
select location, date, total_cases, population, (total_cases/population)*100 as contractionpercentage
from Portfolio.dbo.CovidDeaths
where location like '%china%'
order by 2

--Looking at countries with highest Infection rate compared to population
select location, population, max(total_cases) as Highestpopulationinfected, max((total_cases/population)) *100as InfectionRate
from dbo.CovidDeaths
group by location, population
order by InfectionRate desc

--Shows countries with Highest death per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
group by location
order by TotalDeathCount desc

select location , max(cast(total_deaths as int)) as totalDeathcount
from dbo.CovidDeaths
where continent is null
group by location
order by totalDeathcount desc

--showing continent with highest death count per population
select continent, MAX(cast(total_deaths as int)) as  totaldeathcount
from dbo.CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--Global number
select date, SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths,
(SUM(new_deaths)/SUM(new_cases))*100 as percentofdeath
from dbo.CovidDeaths
where continent is not null
group by date
order by 1
 
--Looking at total population vs vaccinations 
select * from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location) as Rollingpeoplevaccinated
, (Rollingpeoplevaccinated/population)
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with Popvsvac (continent, location, date, population, vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingpeoplevaccinated/population)*100 from Popvsvac

--Temp Table
Drop table if exists #percentpopulationvaccinate
create table #percentpopulationvaccinate
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinate
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location) as Rollingpeoplevaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (Rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinate


--Create view to store data for later visualization
create view percentpopulationvaccinate as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location) as Rollingpeoplevaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


--Summary: New knowledge during doing this portfolio practice

--1. what are declare and set functions in SQL? 

-- Declare statement is used to define a variable by specifying a value.
-- Set statement is used to assign a value to a variable that has been declared
--declare @code nvarchar(50) = 'AFG' 
--or
--declare @code nvarchar(50)
--set @code = 'AFG'
--select * from dbo.CovidDeaths
--where iso_code = @code

--2. what is bigint? A bigint in SQL is a data type which can store very large integer values.

--3. what are the differences between CTE AND TEMP TABLE?

--Temp tables are physically created in the tempdb database and can have constraints and indexes like normal tables. CTE are named temporary result sets that are used to manipulate complex sub-queries data.
--Temp tables can be reused multiple times, while CTE have an execution scope of a single statement.
--Temp tables can be either global or local, while CTE are always local.
--CTE can be recursive, while temp tables cannot.


--4. Usage of 'Drop table if exists TABLE'

--5. Familiarize create a view

--6. Can we create a view of a CTE OR Temp table? How?
--No, a view consists of a single SELECT statement. We cannot create or drop a table in view.
--We can use a common table expression(CTE) to create a temporary result set that can be used in view.
create view myview as
with Popvsvac (continent, location, date, population, vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingpeoplevaccinated/population)*100  as percentvaccinated from Popvsvac