select*
from PortfolioProject..coviddeaths
order by 3,4

--select*
--from PortfolioProject..covidvaccinations
--order by 3,4

--select data that we are going to be using


select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths
order by 1,2

--looking at total cases vs tota deaths
-- shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at total cases vs pupolation
--shows what percentage of population got covid

select location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infectionrate compared to population

select location,population,max(total_cases) as HighestInfectionCount ,max((total_cases/population)*100 )as PercentPopulationInfected
from PortfolioProject..coviddeaths
 group by location,population
--where location like '%states%'
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
 --where location like '%states%'
where continent is not null 
group by location
order by TotalDeathCount desc

--let's break things down by continent

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
 --where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--showing contintents with the highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
 --where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast
   (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 




-- looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations  vac
   on dea.location =vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RllingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations  vac
   on dea.location =vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RllingPeopleVaccinated/Population)*100
from PopvsVac

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Loation nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations  vac
   on dea.location =vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations  vac
   on dea.location =vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated

