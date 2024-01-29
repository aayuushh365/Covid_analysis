select location,date,total_cases, new_cases,total_deaths,population from PortfolioProject..CovidDeaths
order by 1,2;


---- total cases vs total deaths
 --this shows the percentage of dying if infected with COVID in india
select location,date,total_cases,total_deaths,population, (total_deaths/total_cases)*100 AS percent_death from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2;


---- total cases vs population shows what percent of population got infected
select location,date,total_cases,population, (total_cases/population)*100 AS infected_percent from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2;


--countries with highest infection rate compared to population
select location,MAX(total_cases) as highest_infection_count,population, Max((total_cases/population))*100 AS highest_infection_percent from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location , population
order by highest_infection_percent desc;


---- countries with highest death count percentage

select location,MAX(cast(total_deaths as int)) as highest_death_count,population, Max((total_deaths/population))*100 AS highest_death_percent from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location, population
order by highest_death_percent desc;

---- continent with highest death count

select location , max(cast(total_deaths as int)) as total_death_count from PortfolioProject..CovidDeaths
where continent is null
group by location
order by total_death_count desc;

-- global numbers

select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by date
order by 1,2;


-- looking at total population vs vaccination 

select CovidDeaths.continent , CovidDeaths.location , CovidDeaths.date , CovidDeaths.population, CovidVaccinations.new_vaccinations 
, SUM(cast(CovidVaccinations.new_vaccinations as int)) OVER (partition by covidDeaths.location
order by covidDeaths.location , covidDeaths.date) as rollingVaccinationNumber
from PortfolioProject..CovidDeaths
join PortfolioProject..CovidVaccinations 
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3;



-- using CTE 


with populationvsvaccination (continent , location, date , population , new_vaccinations, rollingVaccinationNumber)
as (
select CovidDeaths.continent , CovidDeaths.location , CovidDeaths.date , CovidDeaths.population, CovidVaccinations.new_vaccinations 
, SUM(cast(CovidVaccinations.new_vaccinations as int)) OVER (partition by covidDeaths.location 
order by covidDeaths.location , covidDeaths.date) as rollingVaccinationNumber
from PortfolioProject..CovidDeaths
join PortfolioProject..CovidVaccinations 
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3
)
select * , (rollingVaccinationNumber/population)*100 from populationvsvaccination;



-- other method than cte (temptable)

--DROP TABLE if exists #percentpopulationvaccinated
--CREATE TABLE #percentpopulationvaccinated
--(
--    continent nvarchar(255),
--    location nvarchar(255),
--    date datetime,
--    population numeric,
--    new_vaccinations numeric,
--    rollingVaccinationNumber numeric
--);

--INSERT INTO #percentpopulationvaccinated
--SELECT
--    Cd.continent,
--    Cd.location,
--    Cd.date,
--    Cd.population,
--    Cv.new_vaccinations,
--    SUM(CAST(Cv.new_vaccinations AS numeric)) OVER (PARTITION BY Cd.location ORDER BY Cd.location, Cd.date) AS rollingVaccinationNumber
--FROM PortfolioProject..CovidDeaths Cd
--JOIN PortfolioProject..CovidVaccinations Cv ON Cd.location = Cv.location AND Cd.date = Cv.date
--WHERE Cd.continent IS NOT NULL;

--SELECT *, (rollingVaccinationNumber / population) * 100 AS percent_population_vaccinated
--FROM #percentpopulationvaccinated;




-- creating view for visualisation 

CREATE VIEW populationvsvaccination AS 
SELECT 
    CovidDeaths.continent,
    CovidDeaths.location,
    CovidDeaths.date,
    CovidDeaths.population,
    CovidVaccinations.new_vaccinations,
    SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER (PARTITION BY covidDeaths.location ORDER BY covidDeaths.location, covidDeaths.date) AS rollingVaccinationNumber
FROM 
    PortfolioProject..CovidDeaths
JOIN 
    PortfolioProject..CovidVaccinations ON CovidDeaths.location = CovidVaccinations.location AND CovidDeaths.date = CovidVaccinations.date
WHERE 
    CovidDeaths.continent IS NOT NULL;


