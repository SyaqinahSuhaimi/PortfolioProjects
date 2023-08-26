/*
Covid 19 Data Exploration

Skills used: Windows Functions, Aggregate Functions, Converting Data Types, CTE's Temp Tables, Creating Views
*/

SELECT *
FROM [Portfolio Project - Covid]..CovidDeaths
ORDER BY 3,4



-- Selecting Data that are going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project - Covid]..CovidDeaths
ORDER BY 1,2



-- Total Cases vs Total Deaths (Daily)
-- Shows the possibility of dying when infected by Covid in each Country

SELECT location, date, total_cases, total_deaths, (total_deaths/(cast (total_cases as numeric)))*100 as DeathPercentage
--Note: total_cases and total_deaths were in NVARCHAR thus needing to be casted as numeric or int (interger)
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null
-- AND location = 'Malaysia'
ORDER BY 1,2



-- Total Death Percentage compared to Total Cases in each Country (Total)
-- Shows the country with the highest death percentage

SELECT location, MAX(cast(total_deaths as numeric)) as TotalDeaths, MAX(cast (total_cases as numeric)) as TotalCase, 
		((MAX(cast(total_deaths as numeric)))/(MAX(cast (total_cases as numeric))))*100 as DeathPercentage
--Note: total_cases and total_deaths were in NVARCHAR thus needing to be casted as numeric or int (interger)
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null
-- AND location = 'Malaysia'
GROUP BY location
ORDER BY 4 desc, 3 desc



-- Total Cases vs Population (Daily)
-- Shows the likelihood to be infected by Covid in each country

SELECT location, date, total_cases, population, ((cast (total_cases as numeric)/population))*100 as InfectionRate
--Note: total_cases were in NVARCHAR thus needing to be casted as numeric or int (interger)
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null
-- AND location = 'Malaysia'
ORDER BY 1, 2



-- Total Cases vs Population (Total)
-- Shows the likelihood to be infected by Covid in each country

SELECT location, MAX(cast (total_cases as numeric)) as TotalCase, MAX(population) Population,
				(((MAX((cast(total_cases as numeric))/population)))*100) as InfectionRate
--Note: total_cases were in NVARCHAR thus needing to be casted as numeric or int (interger)
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null
-- AND location = 'Malaysia'
GROUP BY location, population
ORDER BY 1



-- Showing Countries with the Highest Infection Rate compared to Population

SELECT location, MAX(cast (total_cases as numeric)) as TotalCase, MAX(population) Population,
				(((MAX((cast(total_cases as numeric))/population)))*100) as InfectionRate
--Note: total_cases were in NVARCHAR thus needing to be casted as numeric or int (interger)
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null 
--AND continent = 'Malaysia'
GROUP BY location
ORDER BY 4 desc




-- Shows Countries with the Highest Death Count compared to Population
SELECT location, MAX(cast (total_deaths as numeric)) as DeathCount, MAX(population) Population, 
				((MAX(cast (total_deaths as numeric))/(MAX(population)))*100) as DeathRate
--Note: total_deaths were in NVARCHAR thus needing to be casted as numeric or int (interger)
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null 
--AND continent = 'Malaysia'
GROUP BY location
ORDER BY 4 desc





-- BREAKING THINGS DOWN BY CONTINENT

-- Continent with the Highest Death Count compared to Population

SELECT location as Continent, MAX(cast (total_deaths as numeric)) as DeathCount, MAX(population) Population, 
				((MAX(cast (total_deaths as numeric))/(MAX(population)))*100) as DeathRate
--Note: total_deaths were in NVARCHAR thus needing to be casted as numeric or int (interger)
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE location not like '%income%' AND continent is null 
-- WHERE location is 'Asia' AND continent is not null
GROUP BY location
ORDER BY 4 desc



-- Total Death Percentage compared to Total Cases for each Continent 

SELECT location, MAX(cast(total_deaths as numeric)) as TotalDeaths, MAX(cast (total_cases as numeric)) as TotalCase, 
		((MAX(cast(total_deaths as numeric)))/(MAX(cast (total_cases as numeric))))*100 as DeathPercentage
--Note: total_cases and total_deaths were in NVARCHAR thus needing to be casted as numeric or int (interger)
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE location not like '%income%' and continent is null 
GROUP BY location
ORDER BY 1





-- GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as numeric)) as TotalDeath, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null 
ORDER BY 1, 2



-- Joins
SELECT *
FROM [Portfolio Project - Covid]..CovidDeaths dea
Join [Portfolio Project - Covid]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as AccumulatedVaccinations
FROM [Portfolio Project - Covid]..CovidDeaths dea
Join [Portfolio Project - Covid]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	--AND dea.location = 'Malaysia'
ORDER BY 2, 3



--Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, AccumulatedVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as AccumulatedVaccinations
FROM [Portfolio Project - Covid]..CovidDeaths dea
Join [Portfolio Project - Covid]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	--AND dea.location = 'Malaysia'
--ORDER BY 2, 3
)
SELECT *, (AccumulatedVaccinations/Population)*100 VaccinatedRate
FROM PopvsVac



--Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #VaccinatedRateperPopulation
CREATE TABLE #VaccinatedRateperPopulation
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
NewVaccinations numeric,
AccumulatedVaccinations numeric
)

INSERT INTO #VaccinatedRateperPopulation
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as AccumulatedVaccinations
FROM [Portfolio Project - Covid]..CovidDeaths dea
Join [Portfolio Project - Covid]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	--AND dea.location = 'Malaysia'
--ORDER BY 2, 3


SELECT *, (AccumulatedVaccinations/Population)*100 VaccinatedRate
FROM #VaccinatedRateperPopulation





-- Creating View to store data for visualisations

CREATE VIEW VaccinatedRateperPopulation as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as AccumulatedVaccinations
FROM [Portfolio Project - Covid]..CovidDeaths dea
Join [Portfolio Project - Covid]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	--AND dea.location = 'Malaysia'
--ORDER BY 2, 3

