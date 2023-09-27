SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%philippines%'
and continent is not null
Order By 1,2


-- Looking at Total Cases vs. Population
-- Shows what percentage of the population got COVID
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%philippines%'
and continent is not null
Order By 1,2


-- Looking at countries with the highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%philippines%'
Where continent is not null
Group By Location, Population
Order By PercentPopulationInfected DESC


-- Showing the countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%philippines%'
Where continent is not null
Group By Location
Order By TotalDeathCount DESC


-- Let's break things down by continent
Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%philippines%'
Where continent is not null -- when continent is null, it selects those with continent columns with no content, going to those with continent markers and selecting the countries along side it
Group By continent
Order By TotalDeathCount DESC


-- Showing the continents with the highest death count
Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%philippines%'
Where continent is not null -- when continent is null, it selects those with continent columns with no content, going to those with continent markers and selecting the countries along side it
Group By continent
Order By TotalDeathCount DESC

--Showing the countries in ASIA
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent like '%Asia%'
Group By location
Order By Location ASC


-- Global numbers
-- aggregate functions
Select date, SUM(new_cases) AS Cases, SUM(cast(new_deaths as int)) AS NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

-- removes the grouping and gives singular value
Select SUM(new_cases) AS Cases, SUM(cast(new_deaths as int)) AS NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
Order By 1,2


-- Join in terms of location and date
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date

-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3


-- Looking at total population vs vaccinations
-- IF THERE IS AN ERROR WITH NUMVAR YOU CAN USE CAST() AND CONVERT()
-- Example cast(vac.new_vaccinations as int) or convert(int, vac.new_vaccinations) 
-- This partitions (segregates into a new column), the sum of the vaccinations divided into location, then into date, becoming a rolling count (cumulative)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3

-- Dividing the Rolling People Vaccinated with the Population
-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated