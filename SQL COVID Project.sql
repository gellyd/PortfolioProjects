SELECT *
FROM CovidVaccinations

--Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/Total_cases)*100 AS DeathPercentage
FROM CovidDeaths
ORDER BY 1,2

--Looking at tital cases vs total deaths in Canada
--Shows the likelihood of dying if you contract covid in Canada as of April 2021
SELECT location, date, total_cases, total_deaths, (total_deaths/Total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%canad%'
ORDER BY 1,2 

--Shows what percentage of population contracted Covid in Canada as of April 2021
SELECT location, date, total_cases, population, (Total_cases/population)*100 AS PercentageofPopulationwithCovid
FROM CovidDeaths
WHERE location LIKE '%canad%' 
ORDER BY 1,2 

--Looking at countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/population))*100 AS PercentageofPopulationwithCovid
FROM CovidDeaths
GROUP BY location, population
ORDER BY  PercentageofPopulationwithCovid DESC

--Looking at countries with the highest covid deaths per population
SELECT location, population, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PercentageofPopulationDeaths
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY TotaldeathCount DESC

--Looking at continents with the highest percentage of covid deaths per populatiion
SELECT location, population, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PercentageofPopulationDeaths
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location, population
ORDER BY TotaldeathCount, population is not NULL DESC

--Looking at the global percentages of covid deaths per popultaions
SELECT date, population, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_cases)/SUM(new_deaths)*100 As DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date, population
ORDER BY 1,2

--Looking at global percentage of covid deaths in totality
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_cases)/SUM(new_deaths)*100 As DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--joining CovidDeaths table with CovidVaccinations table
SELECT *
from CovidDeaths AS dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date

--What is the total amount of people in the world that have been vaccinated by population of countries?
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION by dea.location ORDER BY dea.location, dea.date) as 	RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--Using a CTE to include Percentages of Rolling People Vaccinated
WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevacinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION by dea.location ORDER BY dea.location, dea.date) as 	RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (rollingpeoplevacinated/Population)*100 as RollingPeopleVaccinatePercentages
FROM PopvsVac


--Using Temp Table to look at percentage of rolling people people_vaccinated
DROP TABLE IF EXISTS PercentagePopulationVaccinated;
CREATE TEMPORARY TABLE PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);
INSERT INTO PercentagePopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as 	RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL;
SELECT *, (rollingPeoplevaccinated/Population)*100 as RollingPeopleVaccinatedPercentages
FROM PercentagePopulationVaccinated


SELECT date, location, MIN(new_vaccinations) AS StartDateforVaccinations
FROM CovidVaccinations
WHERE location like '%canad%'
GROUP BY date, location
ORDER BY StartDateforVaccinations ASC;

SELECT date, location, COUNT(new_deaths) OVER (PARTITION BY location ORDER BY location, date) AS TotalNewDeathsBeforeDec15
FROM CovidDeaths
WHERE location like '%canad%' AND date < '2020-12-15'


--Creating view to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT date, location, MIN(new_vaccinations) AS StartDateforVaccinations
FROM CovidVaccinations
WHERE location like '%canad%'
GROUP BY date, location
ORDER BY StartDateforVaccinations ASC;


