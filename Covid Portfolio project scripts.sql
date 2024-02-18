select * from CovidDeaths
order by 3, 4

--select * from CovidVaccinations
--order by 3, 4

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

-- total cases vs total deaths
-- shows stats of dying from covid by country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1, 2


-- total cases vs pop
-- what percentage of total pop that got infected
select location, date, total_cases, population, (total_cases/population)*100 as PopPercentage
from CovidDeaths
where location like '%states%'
order by 1, 2

--countries with highest infection rate compared to pop

-- what percentage of total pop that got infected
select location,  population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as percentPopInfected
from CovidDeaths
group by location,  population
order by 4 desc

-- show countries with highest death count per pop
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--breaking it down by contenent
--showing contintents with the highest death count per pop
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Global numbers

select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2

select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1, 2

-- looking at total pop vs vacs

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PopVacinated
from CovidDeaths as CD
join  CovidVaccinations as CV
	on CD.location = CV.location and CD.date = CV.date
where CD.continent is not null
order by 1, 2, 3

-- use cte

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as (
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PopVacinated
from CovidDeaths as CD
join  CovidVaccinations as CV
	on CD.location = CV.location and CD.date = CV.date
where CD.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentofPopVacced
from PopvsVac


--temp table

drop table if exists #PercentPopulationVacced
create table #PercentPopulationVacced
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVacced
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PopVacinated
from CovidDeaths as CD
join  CovidVaccinations as CV
	on CD.location = CV.location and CD.date = CV.date
where CD.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentofPopVacced
from #PercentPopulationVacced;

--creating view to store data for later Vizs
create view PercentPopulationVacced as
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PopVacinated
from CovidDeaths as CD
join  CovidVaccinations as CV
	on CD.location = CV.location and CD.date = CV.date
where CD.continent is not null;

select *, (RollingPeopleVaccinated/population)*100 as PercentofPopVacced
from PercentPopulationVacced;