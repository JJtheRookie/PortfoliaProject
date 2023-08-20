select *
from CovidDeaths$
where continent is not null
order by 3,4

--select *
--from CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2


--Looking at TOtal Cases vs Total Deaths
-- Used FLOAT to change the NVARCHAR data type
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (CAST(total_deaths as float)/cast(total_cases as float))*100 DeathPercentage
from CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at total cases vs Population
-- Shows what Percentage of population got Covid

select location, date, population,total_cases, (CAST(total_cases as float)/cast(population as float))*100 PercentPopulationInfected
from CovidDeaths$
--where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

select location, population,MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as float)/cast(population as float))*100 PercentPopulationInfected
from CovidDeaths$
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count Per Population

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break things down by Continent
-- Showing the Continents with the Highest Death Count 

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%states%'
where continent is null
and location not like '%income%'
Group by location
order by TotalDeathCount desc


-- Global Numbers

select date, SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) END * 100 AS DeathPercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs Vaccinations

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
-- USE CTE
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP Table

Drop Table if exists #PercentPopulatoinVaccinated
-- drop table in case you need to alter the table and excecute the code again
Create Table #PercentPopulatoinVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulatoinVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulatoinVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulatoinVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3