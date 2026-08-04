/*
==================================================================
Data Analyst Portfolio Project | SQL Data Exploration
Dataset: COVID-19 Deaths & Vaccinations Data
Tables: [CovidDeaths31.7.26], [covid vaccinations]
Database: CovidProject
Author: Ravalika
Note: All numeric columns were imported as text (nvarchar), so
      CAST() is used throughout to convert them for calculations.
Note: dea.date is stored as text in DD-MM-YYYY format; vac.date
      is stored as text in YYYY-MM-DD format. A helper column
      date_converted (real date type) was added to the
      vaccinations table to make joining reliable.
==================================================================
*/


-- 1. Initial data exploration: look at the raw data
SELECT * 
FROM [CovidDeaths31.7.26]
ORDER BY location, date;


-- 2. Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in a given country
SELECT location, date, total_cases, total_deaths,
       (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM [CovidDeaths31.7.26]
WHERE location LIKE '%India%'
ORDER BY date;


-- 3. Total Cases vs Population
-- Shows what percentage of the population got infected with COVID
SELECT location, date, population, total_cases,
       (CAST(total_cases AS float)/CAST(population AS float))*100 AS InfectionRate
FROM [CovidDeaths31.7.26]
WHERE location LIKE '%India%'
ORDER BY date;


-- 4. Countries with Highest Infection Rate compared to Population
SELECT location, population, 
       MAX(CAST(total_cases AS float)) AS HighestInfectionCount,
       MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 AS PercentPopulationInfected
FROM [CovidDeaths31.7.26]
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- 5. Countries with Highest Death Count per Population
-- WHERE continent IS NOT NULL excludes continent/world summary rows
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [CovidDeaths31.7.26]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 6. BREAKING THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [CovidDeaths31.7.26]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- 7. GLOBAL NUMBERS (day by day)
SELECT date, 
       SUM(CAST(new_cases AS int)) AS TotalNewCases,
       SUM(CAST(new_deaths AS int)) AS TotalNewDeaths,
       (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 AS DeathPercentage
FROM [CovidDeaths31.7.26]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


/*
==================================================================
PART 2: VACCINATIONS - JOINS & WINDOW FUNCTIONS
==================================================================
*/

-- 8. Prep step: add a clean, real date column to the vaccinations
--    table so it can be reliably joined against CovidDeaths.
ALTER TABLE [covid vaccinations]
ADD date_converted date;

UPDATE [covid vaccinations]
SET date_converted = TRY_CONVERT(date, date, 23);


-- 9. JOIN CovidDeaths and CovidVaccinations
-- Combines both tables on matching location + date
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [CovidDeaths31.7.26] dea
JOIN [covid vaccinations] vac
    ON dea.location = vac.location
    AND TRY_CONVERT(date, dea.date, 105) = vac.date_converted
WHERE dea.location LIKE '%India%'
ORDER BY TRY_CONVERT(date, dea.date, 105);


-- 10. Rolling Vaccination Count (Window Function)
-- Running total of people vaccinated per country, day by day
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (
        PARTITION BY dea.location 
        ORDER BY TRY_CONVERT(date, dea.date, 105)
    ) AS RollingPeopleVaccinated
FROM [CovidDeaths31.7.26] dea
JOIN [covid vaccinations] vac
    ON dea.location = vac.location
    AND TRY_CONVERT(date, dea.date, 105) = vac.date_converted
WHERE dea.location LIKE '%India%'
ORDER BY TRY_CONVERT(date, dea.date, 105);


/*
==================================================================
KEY INSIGHTS FOUND:
- India's death % was highest early in the pandemic (~2.9% in
  April 2020) and generally trended down as testing expanded
  and treatment improved.
- Andorra had the highest % of population infected (~17%) -
  small countries top this list since even moderate outbreaks
  move the percentage a lot.
- United States had the highest total death count of any country,
  which also made North America the hardest-hit continent overall.
- Global death % started very high (~7% in April 2020, when
  testing was limited) and fell to roughly 1-2% by late 2020.
- India's vaccination drive began 16-01-2021, with 191,181 people
  vaccinated on day one; the rolling total climbs steadily from
  there with no resets, confirming the window function works
  correctly.

NEXT STEPS:
- Visualize findings in Tableau / Power BI
- Repeat rolling vaccination analysis for other countries
==================================================================
*/
