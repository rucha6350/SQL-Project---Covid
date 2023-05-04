select * 
from CovidDeaths
order by 3,4

select * 
from CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Total Cases VS Total Deaths
select 
	location,date,total_cases,total_deaths
	,TRY_CAST((total_deaths/total_cases)*100 AS numeric(5,3)) as DeathPercentage
from CovidDeaths
where location like '%India%'
order by 1,2

--Total Cases Vs Population
select 
	location,date,total_cases,population
	,TRY_CAST((total_cases/population)*100 AS numeric(5,3)) as CaseVsPopulation
from CovidDeaths
where location like '%India%'
order by 1,2

--Countries with Highest Infection Rate compared to Population
select Location,population,max(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PopulationInfectedPercentage
from CovidDeaths
group by location,population
order by PopulationInfectedPercentage desc

--Continent wise total deaths
select continent,max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

--Countries with Highest Death Rate compared to Population
select Location,population,max(total_deaths) as HighestDeathCount,MAX((total_deaths/population)*100) as PopulationDeathPercentage
from CovidDeaths
where continent is not null
group by location,population
order by PopulationDeathPercentage desc

--Date wise cases and deaths
select 
	date,SUM(new_cases) as cases,SUM(new_deaths) as deaths
	--,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1

--Total cases vs deaths
select 
	SUM(new_cases) as cases,SUM(new_deaths) as deaths
	,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1

--Population vs Vaccinations Per day
select 
	dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations
from CovidDeaths dth join CovidVaccinations vac
on dth.date=vac.date and dth.location=vac.location
where dth.continent is not null
order by 1,2,3

--Rolling People Vaccination continent wise
select 
	dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations
	,sum(vac.new_vaccinations) over (partition by dth.location order by dth.location,dth.date) as RollingPeopleVaccinated
from CovidDeaths dth join CovidVaccinations vac
on dth.date=vac.date and dth.location=vac.location
where dth.continent is not null
order by 2,3

--Using CTE
With PopulationVsVaccination (Continent,Location,Date,Population,Vaccination,RollingPeopleVaccinated)
AS (
select 
	dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations
	,sum(vac.new_vaccinations) over (partition by dth.location order by dth.location,dth.date) as RollingPeopleVaccinated
from CovidDeaths dth join CovidVaccinations vac
on dth.date=vac.date and dth.location=vac.location
where dth.continent is not null
)
SELECT *,RollingPeopleVaccinated/Population*100
FROM PopulationVsVaccination
order by 1,2,3

--Using Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
	Continent nvarchar(255),
	[Location] nvarchar(255),
	[Date] datetime,
	[Population] numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccincated numeric
)

Insert into #PercentPopulationVaccinated
select 
	dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations
	,sum(vac.new_vaccinations) over (partition by dth.location order by dth.location,dth.date) as RollingPeopleVaccinated
from CovidDeaths dth join CovidVaccinations vac
on dth.date=vac.date and dth.location=vac.location

SELECT *
FROM #PercentPopulationVaccinated

--Creating View for visualisation
CREATE VIEW PercentPopulationVaccinated
as
select 
	dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations
	,sum(vac.new_vaccinations) over (partition by dth.location order by dth.location,dth.date) as RollingPeopleVaccinated
from CovidDeaths dth join CovidVaccinations vac
on dth.date=vac.date and dth.location=vac.location
where dth.continent is not null
go

