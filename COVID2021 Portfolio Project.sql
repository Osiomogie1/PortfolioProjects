Select *
From CovidDeaths
Where continent is not null
order by 3, 4

--Select *
--From CovidVaccinations
--order by 3, 4
--
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order by 1, 2

--Checking Total cases vs Total deaths
-- This shows likelihood of dyring after contracting the virus

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'Canada'
and continent is not null
Order by 1, 2

--Checking Total cases vs Population
--This shows the percentage of the population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From CovidDeaths
Where location = 'Canada'
and continent is not null
Order by 1, 2

--Checking countries with highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as CovidPercentage
From CovidDeaths
--Where location = 'Canada'
Where continent is not null
Group by location, population
Order by 4 Desc

--Showing Countries with Highest Death Count per population
Select location, Max(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location = 'Canada'
Where continent is not null
Group by location
Order by TotalDeathCount Desc

--REVIEWING STATS BY CONTINENT

--Correct way to get real figures
Select location, Max(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location = 'Canada'
Where continent is null
Group by location
Order by TotalDeathCount Desc

--For analysis and breakdown purpose
--Showing continents with highest death counts
Select continent, Max(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location = 'Canada'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc

-- Global Numbers

Select date, SUM(new_cases) as Total_cases , SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location = 'Canada'
Where continent is not null
Group by date
Order by 1, 2

--Showing total of cases, death and percentage
Select SUM(new_cases) as Total_cases , SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location = 'Canada'
Where continent is not null
--Group by date
Order by 1, 2

--Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopVac
-- , (RollingPopVac/population) * 100
From CovidDeaths dea
Join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

-- Using CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPopVac)
as 
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopVac
-- , (RollingPopVac/population) * 100
From CovidDeaths dea
Join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *,(RollingPopVac/Population) * 100 as PopVaccinated
From PopvsVac

--Creating view

Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopVac
-- , (RollingPopVac/population) * 100
From CovidDeaths dea
Join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3