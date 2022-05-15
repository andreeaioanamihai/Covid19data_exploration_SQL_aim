SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;



-- Select the Data we are going to be using.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



-- Total Cases vs. Total Deaths in our country - United States.
-- Shows the percentage rate of dying if you get infected with Covid-19 in United States.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'United States'
AND continent IS NOT NULL
ORDER BY 1,2;



-- Total Cases vs. Population in our country - United States.
-- Shows the percentage of population who got Covid-19.

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentage_infected_population
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2;



-- Which country has the Highest Infection Rate compared to Population.

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS percentage_infected_population
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_infected_population DESC;



-- Total deaths by Country.

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;



-- Total deaths by Continent.
-- Showing contintents with the highest death count per population.

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;



-- Global numbers.

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


SELECT *
FROM PortfolioProject..CovidVaccinations

SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON  dea.location = vac.location AND dea.date = vac.date;


-- Total Population vs. Vaccinations.
-- Shows Percentage of Population that has recieved at least one Covid-19 Vaccine.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition By in previous query.

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER by 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_vaccinated_percent
FROM PopvsVac;


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;



-- Table 2

SELECT location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count DESC;



-- Table 3

SELECT date, location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS percentage_infected_population
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'United States'
GROUP BY location, population, date
ORDER BY percentage_infected_population DESC;



-- Total vaccinations per continent

SELECT continent, SUM(CAST(people_fully_vaccinated AS BIGINT)) AS total_vaccinations
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY continent;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

Create View PercentOfPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


