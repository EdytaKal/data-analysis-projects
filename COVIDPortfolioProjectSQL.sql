--ctrl + k + c
--crtl + k + u
--link to youtube:
--https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=2&t=2108s

Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--where continent is not null
--order by 3,4


-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1, 2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you would contract covid in the country where I am from
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like 'Poland'
-- and where continent is not null 
Order by 1, 2

-- Looking the Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths$
-- where location like 'Poland'
-- and where continent is not null 
Order by 1, 2
 
 -- Looking at countries with highest Infection Rates compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths$
-- where location like 'Poland'
-- and where continent is not null 
Group by location, population
Order by PercentOfPopulationInfected asc

-- Looking at countries with highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- where location like 'Poland'
-- and where continent is not null 
Group by location
Order by TotalDeathCount desc
 

-- Showing continents with the highest death count.
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null 
Group by continent
Order by TotalDeathCount desc


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- where location like 'Poland'
where continent is not null 
Group By date
Order by 1, 2

-- Showing the total detah count across all the continents
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- where location like 'Poland'
where continent is not null 
Order by 1, 2

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualisations
Create View DeathsInSelectedCountry as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like 'Poland'


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null

Select * 
From DeathsInSelectedCountry