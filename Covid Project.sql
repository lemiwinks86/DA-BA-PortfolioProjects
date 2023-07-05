
--Select *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select data to be used

Select Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like 'Austria'
Order by 1,2


-- Looking at Total Cases vs Population

Select Location, Date, total_cases, population, (total_cases/population)*100 as ChancePercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
-- Where location like 'romania'
Order by 1,2


-- Looking at Countries with Highest infection rate compared to Population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- Where location like 'Romania'
Group by location, population
Order by 4 desc

-- Looking at Countries with Highest death count compared to Population

Select Location, population, max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/population))*100 as PercentPopulationDeaths
FROM PortfolioProject..CovidDeaths
-- Where location like 'Romania'
where continent is not null
Group by location, population
Order by 4 desc


-- Showing continents with the Highest Death Count

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where location like 'Romania'
where continent is not null
Group by continent
Order by 2 desc


-- Global numbers

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
group by date
Order by 1,2



-- Looking at Total Population vs Vaccinations

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null
Order by 2, 3

-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population*100)
From PopvsVac
Order by 2, 3
-- Doesn't seem right, New_Vaccs has a lot of NULLs


-- Use Temp Table

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

Insert into #PercentPopulationVaccinated

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null

Select *, (RollingPeopleVaccinated/Population*100)
From #PercentPopulationVaccinated
Order by 2, 3


-- Create a View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null
--Order by 2, 3

Select *
From PercentPopulationVaccinated