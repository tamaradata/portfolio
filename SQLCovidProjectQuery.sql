/* 
Data Exploration of two Covid datasets (Covid Deaths and Covid Vaccinations)

*/

--Viewing the tables

Select *
From PortfolioProject.dbo.CovidDeaths
order by 3,4;

Select *
From PortfolioProject..CovidVaccinations
order by 3,4;

--Initial Query on Covid Deaths Dataset

Select Location, date, total_cases,new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2;

--Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2;

--Percentage of U.S. population with Covid infection

Select Location, date, total_cases,population, (total_cases/population)*100 AS Infection_Percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2;

--Countries with the Highest Infection Rate compared to Population

Select Location, max(total_cases)AS Highest_Infection_Count,population, Max((total_cases/population))*100 AS Infection_Percentage
From PortfolioProject..CovidDeaths
Group by location,population
order by Infection_Percentage DESC;

--Countries with Highest Death Count

Select Location, max(total_deaths)AS Death_Count
From PortfolioProject..CovidDeaths
Group by location
Order by Death_Count DESC;

--Contintents with Highest Death Count ( as a drill down)

Select continent, max(cast(total_deaths as int))AS Death_Count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by Death_Count DESC;

--Inaccurate count, converting data type from nvarchar(255) to int

Select Location, max(cast(total_deaths as int))AS Death_Count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by Death_Count DESC;

--Query including Canada in the Death Count for North America

Select Location, max(cast(total_deaths as int))AS Death_Count
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by Death_Count DESC;

--Global Daily Case Count and Death Percentages

Select date, SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2;

--Global Case Count and Death Percentage

Select SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2;

--Total Population vs Vaccinations

Select *
from PortfolioProject.dbo.CovidVaccinations cv
Join
PortfolioProject..CovidDeaths cd
ON cv.location = cd.location 
AND cv.date = cd.date;


Select cd.continent, cd.location, cd.date,cd.population,cv.new_tests, cv.new_vaccinations
from PortfolioProject.dbo.CovidVaccinations cv
Join
PortfolioProject..CovidDeaths cd
ON cv.location = cd.location 
AND cv.date = cd.date
Where cd.continent is not null
order by 2,3;



--USE CTE to determine percent of vaccinated population

Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations)) OVER (Partition BY cd.location order by cv.location, cv.date) AS Daily_Vaccination_Running_Total
from PortfolioProject.dbo.CovidVaccinations cv
Join
PortfolioProject..CovidDeaths cd
ON cv.location = cd.location 
AND cv.date = cd.date
Where cd.continent is not null
order by 2,3;

WITH PopvsVac ( continent, location, date, population, new_vaccinations, Daily_Vaccination_Running_Total)
as
(Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations)) OVER (Partition BY cd.location order by cv.location, cv.date) AS Daily_Vaccination_Running_Total
from PortfolioProject.dbo.CovidVaccinations cv
Join
PortfolioProject..CovidDeaths cd
ON cv.location = cd.location 
AND cv.date = cd.date
Where cd.continent is not null
)

Select *,(Daily_Vaccination_Running_Total/population)*100 AS Vaccination_Percentage
from PopvsVac;

--Use CTE for Highest Vaccination Percentage by location

WITH MaxVac ( continent, location, population, new_vaccinations, Daily_Vaccination_Running_Total)
as
(Select cd.continent, cd.location,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations)) OVER (Partition BY cd.location order by cv.location, cv.date) AS Daily_Vaccination_Running_Total
from PortfolioProject.dbo.CovidVaccinations cv
Join
PortfolioProject..CovidDeaths cd
ON cv.location = cd.location 
AND cv.date = cd.date
Where cd.continent is not null
)

Select Distinct(location),(MAX(Daily_Vaccination_Running_Total/population))*100 AS Vaccination_Percentage
from MaxVac
Group by location
Order by Vaccination_Percentage DESC;

--Temp Table

Drop Table if exists #PopulationVacPercentage

Create Table #PopulationVacPercentage
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Daily_Vaccination_Running_Total numeric)

Insert Into #PopulationVacPercentage
Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations)) OVER (Partition BY cd.location order by cv.location, cv.date) AS Daily_Vaccination_Running_Total
from PortfolioProject.dbo.CovidVaccinations cv
Join
PortfolioProject..CovidDeaths cd
ON cv.location = cd.location 
AND cv.date = cd.date
Where cd.continent is not null
order by 2,3

Select *,(Daily_Vaccination_Running_Total/population)*100 AS Vaccination_Percentage
from  #PopulationVacPercentage;



--Creating views to store data for visulizations

Create View PopulationVacPercentage as 
Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations)) OVER (Partition BY cd.location order by cv.location, cv.date) AS Daily_Vaccination_Running_Total
from PortfolioProject.dbo.CovidVaccinations cv
Join
PortfolioProject..CovidDeaths cd
ON cv.location = cd.location 
AND cv.date = cd.date
Where cd.continent is not null


Create View  CaseCount as
Select SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null


select *
from CaseCount;
