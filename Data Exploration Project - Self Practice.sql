

--median age vs. covid death
-- Looking at the number of people per location over the age of 60 that died with covid (no one over 60)
-- Looking at the number of people per location under the age of 60, arranged with location in ascending order

SELECT dea.location, dea.date, dea.median_age
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
WHERE dea.median_age < 60
ORDER BY dea.location ASC


--median age vs. covid death
-- Looking at the number of people per location under the age of 60, arranged with location in ascending order, grouped by location

SELECT location, median_age
FROM PortfolioProject..CovidDeaths
WHERE median_age < 60
GROUP BY location, median_age
ORDER BY location


--total vaccination vs population
-- Looking at percent of people who have vaccination vs population for countries in Asia

SELECT dea.location, (vac.total_vaccinations/dea.population)*100 AS TotalVaccinatedPercentage
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
WHERE dea.continent like '%Asia%'
ORDER BY location ASC


-- get the maximum positive rate of all the countries
--Looking at the max positive rate partitioned in location
SELECT location, date, positive_rate, MAX(positive_rate) OVER (PARTITION by location ORDER BY location, date) RollingPositiveRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

--get the maximum new test, the sum of new case, and sum of new death grouped by the location
SELECT dea.date, dea.location,
	MAX(cast(vac.new_tests as int)) AS MaximumNewTest,
	SUM(cast(new_cases as int)) AS TotalNewCases,
	SUM(cast(new_deaths as int)) AS TotalNewDeaths
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
GROUP BY dea.date, dea.location
ORDER BY dea.location ASC


-- case statement for setting standard call for case rate per population
-- you cannot cite an alias within the same select statement, either rewrite the formula or create subquery (depending on complexity)
SELECT Location, Date, New_Cases, Population, (New_Cases/Population) AS CaseRate,
CASE
	WHEN (New_Cases/Population) < 0.01 THEN 'Low Rate'
	WHEN (new_cases/Population) = 0.01 THEN 'Threshold Rate'
	WHEN (new_cases/Population) > 0.01 THEN 'High Rate'
	ELSE 'Null Rate'
END AS CaseRateLevel
FROM PortfolioProject..CovidDeaths
ORDER BY CaseRate DESC

-- case statement for the total death using SUM per Location
SELECT DISTINCT Location, SUM(New_Cases) OVER (Partition By Location Order By Location) AS TotalCase,
    CASE
        WHEN SUM(New_Cases) OVER (Partition By Location Order By Location)  < 100000 THEN 'AcceptableTotal'
        WHEN SUM(New_Cases) OVER (Partition By Location Order By Location)  = 100000 THEN 'ThresholdTotal'
        ELSE 'AlarmingTotal'
    END AS TotalDeathLevel
FROM PortfolioProject..CovidDeaths
ORDER BY Location ASC


--case statement using a subquery to use alias on case statement
SELECT DISTINCT Location, TotalCases,
CASE
	WHEN TotalCases < 5000000 THEN 'AcceptableTotal'
	WHEN TotalCases = 5000000 THEN 'ThresholdTotal'
	ELSE 'AlarmingTotal'
END AS TotalDeathLevel
FROM
(
SELECT Location, SUM(New_Cases) OVER (Partition By Location Order By Location) AS TotalCases
FROM PortfolioProject..CovidDeaths
)
AS subquery
ORDER BY Location ASC





