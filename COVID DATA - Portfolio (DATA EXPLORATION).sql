Select * from Portfolio_Project..CovidDeaths$ order by 3,4


Select * from Portfolio_Project..CovidVaccinations$ order by 3,4

--Total Cases VS Total Death Comparison 

Select location,date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Portfolio_Project..CovidDeaths$  where location like '%Canada%' order by 1,2

-- Total cases VS Population
-- shows what percentage of population has covid

Select location,date, total_cases, population, (total_cases/population) * 100 as CasePercentage
from Portfolio_Project..CovidDeaths$  where location like '%Canada%' order by 1,2

-- Countries with highest infection rate compared with population

Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))* 100 as PercentagePopulationInfected
from Portfolio_Project..CovidDeaths$  
--where location like '%Canada%' 
group by location,population
order by PercentagePopulationInfected desc

-- To remove continents from the data 

Select continent, location, population from Portfolio_Project..CovidDeaths$ 
where continent is not null 
order by 1

-- shows countries with highest deathcount per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths$  
--where location like '%Canada%' 
where continent is not null 
group by location
order by TotalDeathCount desc

--showing continents with Highest Death Count

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths$
group by continent 
order by TotalDeathCount desc

--Filtering out based on the whole world and date

Select date, SUM(new_cases) as newCases, SUM(cast(new_deaths as int)) as NewDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
where continent is not null 
group by date 
order by 1,2


--JOIN both data

Select * from Portfolio_Project..CovidDeaths$ dea
JOIN Portfolio_Project..CovidVaccinations$ vac
ON dea.location = vac.location 
and dea.date = vac.date

-- finding people in the world that are vaccinated

Select dea.continent, dea.location,dea.date ,dea.population ,vac.new_vaccinations
from Portfolio_Project..CovidDeaths$ dea
JOIN Portfolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- find sum of people vaccinated in a country

Select dea.continent, dea.location,dea.date ,dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
JOIN Portfolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

With PopVSVac (Continent, Location , Date , Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date ,dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
JOIN Portfolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100 from PopVSVac

-- Create View 
Create view PercentageTotalVaccinations as

Select dea.continent, dea.location,dea.date ,dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
JOIN Portfolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
from PercentageTotalVaccinations
