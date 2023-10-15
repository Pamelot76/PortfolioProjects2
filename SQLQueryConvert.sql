

Select *
from PortfolioProject..CovidDeaths

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population contracted covid
Select location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to population
--United States a little over 30% of the population infected with covid
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
Group By location, population
order by PercentPopulationInfected DESC

--Showing countries with Highest Death Count per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group By location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing Death Count with the Highest Death Count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group By continent
order by TotalDeathCount desc

--GLOBAL Percentage
Select SUM(new_cases)as NewCases, SUM(cast(new_deaths as int))as NewDeath, SUM(cast( new_deaths as int)) / SUM( new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
--CTE
with PopvsVac (Continent,Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3