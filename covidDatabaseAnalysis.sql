Select *
From CovidDeaths
Order BY 3,4; 

Select *
From CovidVaccinations
Order BY 3,4;


-- Select Data that we are going to be starting with European Countries

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where location  = 'European Union' or continent = 'Europe'
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows the propability of dying if you contract covid in My country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage_perDay
From CovidDeaths
Where location  = 'European Union' or continent = 'Europe'
order by 1,2

-- Total Cases vs Population
-- Shows the percentage of population infected with Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location  = 'European Union' or continent = 'Europe'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Where continent Is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount 
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
Group By date
order by 1,2


-- Now looking to Vaccination Data 
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select *
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date





Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentage
From PopvsVac



DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated, 
(RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 