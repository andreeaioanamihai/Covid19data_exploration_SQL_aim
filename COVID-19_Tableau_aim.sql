/*

Queries used for Tableau Dashboard

*/


-- 1.

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;



-- 2.

SELECT location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count DESC;



-- 3.

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS percentage_infected_population
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_infected_population DESC;



-- 4.


SELECT date, location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS percentage_infected_population
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
GROUP BY location, population, date
ORDER BY percentage_infected_population DESC;