select location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths
order by 1,2

--Likelihood of dying if you contract Covid in your Country
--Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'Kenya'
order by 2

--shows what percentage of Population has Covid
--Total cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 as CovidPopulationPC
from CovidDeaths
where location = 'Kenya'
order by 2

--Country with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Countries with highest death count per population
Select Location, Population, MAX (cast(total_deaths as int)) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDead
From CovidDeaths
Where continent is not null
Group by Location, Population
order by 3 desc, 4 desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent IS NOT NULL
Group by date
order by 1,2 

-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

--USE CTE
-- Shows Percentage of Population that has recieved at least one Covid Vaccine using CTE
WITH CTE_Popvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select*, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPC
from CTE_Popvac

--TempTable
-- Shows Percentage of Population that has recieved at least one Covid Vaccine but with temp tables

DROP Table if exists #temp_VaccinatedPopulationPC
CREATE TABLE #temp_VaccinatedPopulationPC (
continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #temp_VaccinatedPopulationPC
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPC
from #temp_VaccinatedPopulationPC

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 







