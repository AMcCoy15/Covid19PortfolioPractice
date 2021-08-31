Select * 
From [SQL Beginnings]..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From [SQL Beginnings]..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [SQL Beginnings]..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [SQL Beginnings]..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From [SQL Beginnings]..CovidDeaths
--where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [SQL Beginnings]..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--Looking at Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQL Beginnings]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--showing continents with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQL Beginnings]..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


--Global Numbers by day

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [SQL Beginnings]..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--Global Numbers total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [SQL Beginnings]..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [SQL Beginnings]..CovidDeaths dea
Join [SQL Beginnings]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2




--Use CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [SQL Beginnings]..CovidDeaths dea
Join [SQL Beginnings]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [SQL Beginnings]..CovidDeaths dea
Join [SQL Beginnings]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2


Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [SQL Beginnings]..CovidDeaths dea
Join [SQL Beginnings]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3