-- SELECT DATA THAT WE ARE GOING TO BE STARTED WITH --
Select Location, date, total_cases, new_cases, total_deaths, population
From covid_deaths
Where continent is not null 
order by 1,2;

-- TOTAL CASES/TOTAL DEATHS --
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY --
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid_deaths
Where location like '%states%'
and continent is not null 
order by 1,2;

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION --
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population
order by PercentPopulationInfected DESC;

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION --
Select Location, MAX(Total_deaths)as TotalDeathCount
From covid_deaths
Where continent is not null 
and location not in ('world','High income','Upper middle income','Europe','Asia','Africa','North america','South income',
'South America','Lower middle income','European Union')
Group by Location
order by TotalDeathCount desc;

-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION --
Select continent, MAX(Total_deaths) as TotalDeathCount
From covid_deaths
where location like '%states%'
and continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS --
select date, sum(new_cases) as total_cases , sum(total_deaths) as total_deaths, sum(total_deaths)/sum(total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%india%' 
and continent is not null
group by date
order by 1,2;

-- LETS CHECK ALL NEW CASES BY DATE. -- LETS DO PERCENTAGE OF NEW DEATHS BASED ON NEW CASES --
select date, sum(new_cases) as New_cases , sum(new_deaths) as New_deaths,
sum(new_deaths)/sum(new_cases)*100 as Death_percentage
from covid_deaths
where continent is not null
group by date
order by Death_percentage desc;

-- TOTAL POPULATION/TOTAL VACCINATION --
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, d.Date) as Total_vaccinations
From covid_deaths as d
Join covid_vaccination as v
On d.location = v.location and d.date = v.date
where d.continent is not null 
order by 2,3;

-- PERCENTAGE OF NEW VACCINATION BY POPULATION --
-- USING CTE --
With PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeoplevaccinated
From covid_deaths as d
Join covid_vaccination as v
On d.location = v.location and d.date = v.date
where d.continent is not null 
)
Select *, round(Rollingpeoplevaccinated/population*100,3) as VaccinationPercentage
From PopvsVac;

-- TEMP TABLE
Create Table PercentPopulationVaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
date DATE,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated BIGINT
);

INSERT INTO PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(new_vaccinations)
OVER (PARTITION BY d.location order by d.location, d.date) AS RollingPeopleVaccinated
FROM covid_deaths as d
JOIN covid_vaccination as v
ON d.location = v.location AND d.date = v.date
where d.continent IS NOT NULL;

select *, (Rollingpeoplevaccinated/population)*100 as Vaccinationpercentage
from PercentPopulationVaccinated;

-- CREATING VIEW --
create view PercentPopulationVaccinatedd AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(new_vaccinations)
OVER (PARTITION BY d.location order by d.location, d.date) AS RollingPeopleVaccinated
FROM covid_deaths as d
JOIN covid_vaccination as v
ON d.location = v.location AND d.date = v.date
where d.continent IS NOT NULL;



