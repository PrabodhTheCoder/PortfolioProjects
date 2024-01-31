
SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2



--changed data types formula
SELECT *
FROM dbo.CovidDeaths
EXEC sp_help 'dbo.CovidDeaths';

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_cases int

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_deaths int
/------------------------------------


-- Looking at Total Cases vs Total Deaths
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid 
SELECT Location, date, total_cases,population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
order by 1,2

-- Looking at countries with Highest Infection rate compared to population 

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Group by Location, population
ORDER BY PercentagePopulationInfected desc
-- Column 'PortfolioProject..CovidDeaths.location' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- Showing countries with Highest Death count per population

-- Changed data type of the column
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not NULL
Group by Location
ORDER BY TotalDeathCount desc

--Breaking with Continent
SELECT Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not NULL
Group by Continent
ORDER BY TotalDeathCount desc

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not NULL
Group by continent
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not NULL
Group by continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
--Group by date
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated, (RollingPeopleVaccinated/population) * 100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3
--Msg 207, Level 16, State 1, Line 98
Invalid column name 'RollingPeopleVaccinated'.

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVacciinated) as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVacciinated
--, (RollingPeopleVacciinated/population) * 100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVacciinated/population) * 100 
From PopvsVac


-- TEMP TABLE

DROP Table if exists

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric 
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVacciinated
--, (RollingPeopleVacciinated/population) * 100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVacciinated/population) * 100 
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVacciinated
--, (RollingPeopleVacciinated/population) * 100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated