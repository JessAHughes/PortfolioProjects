#Select the data we'll be using

SELECT 
  location, 
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM 
  CovidDeaths
ORDER BY 1,2;

#Looking at the total caases vs the total deaths
#Shows likelihood of dying from contracting covid in your country

SELECT 
  location, 
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100       AS death_percentage
FROM 
  CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2;

#Looking at the total cases vs population
#Shows percentage of population that contracted covid

SELECT 
  location, 
  date,
  population,
  total_cases,
  (total_cases/population)*100         AS infected_percentage
FROM 
  CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2;

#Looking at countries with highest infection rate compared to population

SELECT 
  location, 
  population,
  MAX(total_cases)                     AS infection_count,
  MAX((total_cases/population))*100    AS percent_of_infected
FROM 
  CovidDeaths
GROUP BY location, population
ORDER BY percent_of_infected DESC;

#Showing continents with highest death count per population 

SELECT 
  continent,
  MAX(CAST(total_deaths AS UNSIGNED))  AS death_count
FROM 
  CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY death_count DESC;

#Global cases, deaths, and death percentage per day

SELECT 
  date,
  SUM(new_cases)                                             AS total_cases,
  SUM(CAST(new_deaths AS UNSIGNED))                          AS total_deaths,
  SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases)*100       AS death_percentage
FROM 
  CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2;

#Total cases, deaths, and death percentage globally 

SELECT 
  SUM(new_cases)                                             AS total_cases,
  SUM(CAST(new_deaths AS UNSIGNED))                          AS total_deaths,
  SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases)*100       AS death_percentage
FROM 
  CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

#Looking at total population vs vaccinations 

SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date)               AS rolling_vaccination_count
  #(rolling_vaccination_count/population)*100       AS vaccination_percentage
FROM 
  CovidDeaths dea
JOIN
  CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

#Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccination_Count)
AS
(
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date)               AS rolling_vaccination_count
FROM 
  CovidDeaths dea
JOIN
  CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
)
SELECT *,
  (Rolling_Vaccination_Count/Population)*100       AS Vaccination_Percentage
FROM 
  PopvsVac;
  
#Creating View for later visualizations

CREATE VIEW Percent_Of_Vaccinated AS 
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date)               AS rolling_vaccination_count
FROM 
  CovidDeaths dea
JOIN
  CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL

