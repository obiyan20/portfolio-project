SELECT *
FROM  portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM  portfolioproject..CovidVaccinations
WHERE continent is not null
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--looking at the total_cases vs total deaths
--this showed the liklyhood of dlying if you contract covid 19 in NIGERIA 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM portfolioproject..CovidDeaths
WHERE location like '%NIGERIA%'
AND continent is not null
ORDER BY 1,2

--Looking at the total cases vs the polulation
--shows the percentage of nigeria population got covid 19

SELECT location, date, population, total_cases, (total_cases/population)*100 as deathpercentage
FROM portfolioproject..CovidDeaths
WHERE location like '%NIGERIA%'
and continent is not null
ORDER BY 1,2

--looking at countries with highest infection rate compared to population 

SELECT location, population, MAX(total_cases) as highestinfectioncount, MAX(total_cases/population)*100 as percentpopulationinfected
FROM portfolioproject..CovidDeaths
--WHERE location like '%NIGERIA%'
GROUP BY location, population
ORDER BY percentpopulationinfected desc

--showing countries with highest deaths count per population 

SELECT location, MAX(cast(Total_deaths as int)) as totaldeathcount
FROM portfolioproject..CovidDeaths
--WHERE location like '%NIGERIA%'
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount desc

--let's break things down by continent

SELECT continent, MAX(cast(Total_deaths as int)) as totaldeathcount
FROM portfolioproject..CovidDeaths
--WHERE location like '%NIGERIA%'
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount desc

--showing the continent with the highest death count per population 

SELECT continent, MAX(cast(Total_deaths as int)) as totaldeathcount
FROM portfolioproject..CovidDeaths
--WHERE location like '%NIGERIA%'
C
GROUP BY continent
ORDER BY totaldeathcount desc



--looking at the total population vs vaccinations



SELECT *
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date 


  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpoeoplevaccinated, 
( rollingpoeoplevaccinated/population)*100
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  order by 2,3 

  --using a CTE 

  with popvsvac (continent, location ,date, population, new_vaccinations, rollingpeoplevaccinated)
  as
  (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpoeoplevaccinated 
--,(rollingpoeoplevaccinated/population)*100
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
 -- order by 2,3 
  )
  select *,(rollingpeoplevaccinated/population)*100
  from popvsvac



  -- TEMP TABLE

  DROP table if exists #percentpopulationvaccinated
  create table #percentpopulationvaccinated
  (
  continent nvarchar(255),
  location  nvarchar(255),
  date datetime,
  population numeric, 
  new_vaccinations numeric,
  rollingpeoplevaccinated numeric
  )


  INSERT into #percentpopulationvaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpoeoplevaccinated 
--,(rollingpoeoplevaccinated/population)*100
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
 -- order by 2,3 
 
  select *,(rollingpeoplevaccinated/population)*100
  from #percentpopulationvaccinated



  -- creating view to store for later visualization 
  
  create view percentpopulationvaccinated as 
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpoeoplevaccinated 
--,(rollingpoeoplevaccinated/population)*100
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
-- order by 2,3 

select *
from percentpopulationvaccinated
 
  create view liklyhoodofdyingfromcovidinnigeria as 
  SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM portfolioproject..CovidDeaths
WHERE location like '%NIGERIA%'
AND continent is not null
--ORDER BY 1,2

create view percentageofnigeriathatgotcovid as
SELECT location, date, population, total_cases, (total_cases/population)*100 as deathpercentage
FROM portfolioproject..CovidDeaths
WHERE location like '%NIGERIA%'
and continent is not null
--ORDER BY 1,2


create view conutrieswithhighestinfectioncomparewithpopulation as
SELECT location, population, MAX(total_cases) as highestinfectioncount, MAX(total_cases/population)*100 as percentpopulationinfected
FROM portfolioproject..CovidDeaths
--WHERE location like '%NIGERIA%'
GROUP BY location, population
--ORDER BY percentpopulationinfected desc