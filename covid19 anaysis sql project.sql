Select *
From PortfolioProject..coviddeaths
where continent is not null
Order by 3,4


--Select *
--From PortfolioProject..covidvaccination
--Order by 3,4

-- This research data is based on the covid19 pandemic outbreak.
-- Update null values to zero for total_cases and total_deaths

UPDATE PortfolioProject..coviddeaths
SET total_cases = ISNULL(total_cases, 0),
    total_deaths = ISNULL(total_deaths, 0)
WHERE total_cases IS NULL OR total_deaths IS NULL
and continent is not null

-- Calculate DeathPercentage and select relevant data
SELECT continent, location, population, total_cases, date, new_cases, total_deaths, reproduction_rate, hosp_patients,
  CASE
    WHEN total_cases = 0 THEN 0  -- Avoid division by zero
    ELSE CAST(total_deaths AS decimal) / CAST(total_cases AS decimal) * 100
  END AS DeathPercentage, weekly_icu_admissions
FROM PortfolioProject..coviddeaths
--WHERE location LIKE '%Nigeria%'
where continent is not null
ORDER BY 1, 2, 5;


-- looking at total cases vs population
-- Calculate InfectedPercentage and select relevant data
SELECT continent, location, population, total_cases, date, new_cases, total_deaths, reproduction_rate, hosp_patients,
  CASE
    WHEN total_cases = 0 THEN 0  -- Avoid division by zero
    ELSE CAST(total_cases AS decimal) / CAST(population AS decimal) * 100
  END AS PercentPopulationInfected, weekly_icu_admissions
FROM PortfolioProject..coviddeaths
--WHERE location LIKE '%States%'
ORDER BY 1, 5;

-- looking at countries with highest infection rate
SELECT
    continent,
    MAX(population) AS population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(new_cases) AS new_cases,
    CASE
        WHEN MAX(total_cases) = 0 THEN 0  -- Avoid division by zero
        ELSE MAX(CAST(total_cases AS decimal)) / MAX(CAST(population AS decimal)) * 100
    END AS MaxPercentPopulationInfected
FROM PortfolioProject..coviddeaths

GROUP BY continent
ORDER BY MaxPercentPopulationInfected DESC;

-- looking at country with the highest death count per population

SELECT
    location,
    MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..coviddeaths
where continent is not null
GROUP BY location
ORDER BY TotalDeathsCount DESC;

-- Lets break it down by continent

SELECT
    continent,
    MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC;

-- Global Number

-- Calculate DeathPercentage and select relevant data
-- probability of dying if you contact covid


-- Lets break it down by continent

SELECT
    continent,
    MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC;



SELECT
date,
SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS int)) AS TotalDeaths,
    CASE
        WHEN SUM(CAST(new_cases AS int)) = 0 THEN NULL  -- Display NULL when no new cases
        ELSE (SUM(CAST(new_deaths AS decimal)) / NULLIF(SUM(CAST(new_cases AS decimal)), 0)) * 100
    END AS DeathPercentage
FROM PortfolioProject..coviddeaths
--WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT  dea.continent,dea.location,  dea.date, dea.population,  vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated,
    (SUM(CONVERT(bigint, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) / NULLIF(dea.population, 0)) * 100.0 as PercentageVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3;



--CTE

WITH popvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated, PercentageVaccinated) AS
(
  
SELECT  dea.continent,dea.location,  dea.date, dea.population,  vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated,
    (SUM(CONVERT(bigint, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) / NULLIF(dea.population, 0)) * 100.0 as PercentageVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3 
)
SELECT 
    Continent,
    Location,
    Date,
    Population,
    New_Vaccination,
    RollingPeopleVaccinated,
    PercentageVaccinated
FROM popvsVac;

--CTE

WITH popvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated, PercentageVaccinated) AS
(
    SELECT  
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated,
        (SUM(CONVERT(bigint, vac.new_vaccinations)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) / NULLIF(dea.population, 0)) * 100.0 as PercentageVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccination vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 
)
SELECT 
    Continent,
    Location,
    Date,
    Population,
    New_Vaccination,
    RollingPeopleVaccinated,
    PercentageVaccinated
FROM popvsVac;


--TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);


WITH popvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated, PercentageVaccinated) AS
(
    SELECT  
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated,
        (SUM(CONVERT(bigint, vac.new_vaccinations)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) / NULLIF(dea.population, 0)) * 100.0 as PercentageVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccination vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    --WHERE dea.continent IS NOT NULL 
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
    Continent,
    Location,
    Date,
    Population,
    New_Vaccination,
    RollingPeopleVaccinated
FROM popvsVac;

SELECT *, (RollingPeopleVaccinated / Population) * 100 as PercentageVaccinated
FROM #PercentPopulationVaccinated;

DROP TABLE #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 