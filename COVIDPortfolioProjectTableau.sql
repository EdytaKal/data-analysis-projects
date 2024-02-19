-- ============================================================================
-- SQL queries for Tableau (PROJECT 2)
-- link to Tableau Covid Dashboard:
-- https://public.tableau.com/app/profile/edi.kal/viz/CovidDashboard_17081272022820/Dashboard1
-- ============================================================================

-- TABLE 1 ==================================================================== 
-- Showing the total detah count across all the continents
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- where location like 'Poland'
where continent is not null 
Order by 1, 2

-- TABLE 2 ==================================================================== 
-- Taking out the following for consistency purpose, since they weren't used in the earlier queries.
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location 
order by TotalDeathCount desc


-- TABLE 3 ==================================================================== 
-- Show the countires population vs the percent of the country population infected. 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)
*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population
Order by PercentPopulationInfected desc


-- TABLE 4 ==================================================================== 
-- Show the countires population vs the percent of the country population infected per each day. 
Select location, population, date , MAX(total_cases) as HighestInfectionCount 
, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population, date
order by PercentPopulationInfected desc
