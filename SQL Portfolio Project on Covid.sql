----Selecting the data that we will be using

SELECT * from covid_deaths
where continent is not null;

SELECT * from covid_vaccinations;

----Shows likelihood of dying if infected with covid
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
    (total_deaths/total_cases)*100 as death_percentage
		FROM covid_deaths
				where continent is not null;

----Total Cases Vs Population and shows what % of people got Covid
SELECT
	location,
	date,
	population,
	total_cases,
    (total_cases/population)*100 as affected_percentage
         FROM covid_deaths
               where continent is not null;

----Countries with highest infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_rate,
    MAX((total_cases  / population) * 100) AS Percent_Population_Infected
FROM 
    covid_deaths
where continent is not null    
GROUP BY 
    location, population
ORDER BY 
    Percent_Population_Infected DESC;
   
----Countries with highest death count per population
 SELECT
 	location,
 	MAX(total_deaths) as total_death_count
 		FROM covid_deaths 
 where continent is not null 
 GROUP BY 
 	location 
 order BY total_death_count desc;


----Grouping by continents

 SELECT
 	continent, 
 MAX(total_deaths) as total_death_count
 		FROM covid_deaths 
 where continent is not null
GROUP BY 
	continent 
 ORDER BY total_death_count desc;

----Using Joins

SELECT * 
	FROM covid_deaths as cd
		JOIN covid_vaccinations as cv 
		ON
			cd.location = cv.location 
				and cd.date = cv.date;

----Total Population Vs Vaccinations
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
		FROM covid_deaths as cd
			JOIN covid_vaccinations as cv
			ON 
				cd.location = cv.location 
				and cd.date = cv.date
				 where cd.continent is not null 
ORDER BY location,date;

----Using CTE
WITH PopvsVac AS (
    SELECT 
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(
            CAST(
                NULLIF(cv.new_vaccinations, '') AS int
            )
        ) OVER (
            PARTITION BY cd.location 
            ORDER BY cd.date
        ) AS rolling_people_vaccinated
    FROM 
        covid_deaths AS cd
    JOIN 
        covid_vaccinations AS cv
    ON 
        cd.location = cv.location 
        AND cd.date = cv.date
    WHERE 
        cd.continent IS NOT NULL
)

SELECT * ,(rolling_people_vaccinated/population)*100 as percentage
FROM PopvsVac;


----Using Views

DROP VIEW if EXISTS  PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated as 
SELECT 
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(
            CAST(
                NULLIF(cv.new_vaccinations, '') AS int
            )
        ) OVER (
            PARTITION BY cd.location 
            ORDER BY cd.date
        ) AS rolling_people_vaccinated
    FROM 
        covid_deaths AS cd
    JOIN 
        covid_vaccinations AS cv
    ON 
        cd.location = cv.location 
        AND cd.date = cv.date
    WHERE 
        cd.continent IS NOT null;

SELECT * from PercentPopulationVaccinated;







