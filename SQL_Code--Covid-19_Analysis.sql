# Covid-19 Analysis

# 1.Total cases v/s total deaths
# Death percentage 

SELECT 
	date,
    total_cases,
    total_deaths,
	ROUND((total_deaths / total_cases)*100 ,2) AS death_percentage
FROM 
	covid_deaths
WHERE 
	total_cases AND total_deaths IS NOT NULL
ORDER BY 1,2;



# 2.Total cases v/s Population Infection_percentage 

SELECT 
	location,
    date,
    population,
    total_cases,
	ROUND((total_cases / population)*100 ,4) AS Infection_percentage 
FROM 
	covid_deaths
WHERE 
	total_cases AND total_deaths IS NOT NULL
ORDER BY 1,2;


# 3.Countries with Highest Infection_percentage to Population

SELECT 
	location,
    population,
    MAX(total_cases) AS Highest_Infection_Rate,
	ROUND(MAX(total_cases / population)*100 ,2) AS Maximum_Infection_percentage
FROM 
	covid_deaths
WHERE 
	total_cases AND total_deaths IS NOT NULL
GROUP BY 
	location,
    population
HAVING  
	Maximum_Infection_percentage <>0
ORDER BY  
	Maximum_Infection_percentage DESC;

# 4.Countries with Highest Death Count per Population

SELECT 
    location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS Total_deaths
FROM 
    covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
    location
HAVING 
	Total_deaths <> 0
ORDER BY  
    Total_deaths DESC;
    
# 5.Continents with Highest Death Count per Population

SELECT
	continent,
    MAX(CAST(total_deaths AS UNSIGNED)) AS Total_deaths
FROM 
    covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
    continent
ORDER BY  
    Total_deaths DESC;

# 6.Global statistical description

SELECT 
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    ROUND((SUM(new_deaths) / SUM(new_cases) * 100),2) AS Death_percentage
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	1,2;
    
    
# 7. Total Popualtion v/s Vaccinations

SELECT 
	deths.continent,
    deths.location,
    deths.date,
    deths.population,
    vacs.new_vaccinations
FROM 
	covid_deaths deths
JOIN 
	covid_vaccinations vacs
	ON deths.location = vacs.location AND
		deths.date = vacs.date
WHERE deths.continent IS NOT NULL 
HAVING vacs.new_vaccinations IS NOT NULL
ORDER BY 2,3;


# 8.Count Vaccination done over continent

SELECT 
    deths.continent,
    deths.location,
    deths.date,
    deths.population,
    vacs.new_vaccinations,
    SUM(CONVERT(vacs.new_vaccinations, UNSIGNED)) 
    OVER (PARTITION BY deths.location ORDER BY deths.location, deths.date) AS Rolling_sum_of_vaccination
FROM 
    covid_deaths deths
JOIN 
    covid_vaccinations vacs
    ON deths.location = vacs.location AND
       deths.date = vacs.date
WHERE 
    deths.continent  IS NOT NULL 
ORDER BY 
    deths.location, deths.date;


# 9. Vaccination Percentage by continent

WITH cte AS
(
SELECT 
    deths.continent,
    deths.location,
    deths.date,
    deths.population,
    vacs.new_vaccinations,
    SUM(CONVERT(vacs.new_vaccinations, UNSIGNED)) 
    OVER (PARTITION BY deths.location ORDER BY deths.location, deths.date) AS Rolling_sum_of_vaccination
FROM 
    covid_deaths deths
JOIN 
    covid_vaccinations vacs
    ON deths.location = vacs.location AND
       deths.date = vacs.date
WHERE 
    deths.continent IS NOT NULL 
)
SELECT *, ( Rolling_sum_of_vaccination / population)*100 AS Percentage
FROM cte
HAVING Percentage IS NOT NULL ;



# View for Tableau  visualisation

# 1. Total cases, Total deaths and Death_percentage

SELECT 
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    ROUND((SUM(new_deaths) / SUM(new_cases) * 100),2) AS Death_percentage
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL;


# 2. Death count by location
    
Select location, SUM(new_deaths) as TotalDeathCount
From covid_deaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

# 3 Location wise Population,HighestInfectionCount and PercentPopulationInfected

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc;

# 4

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population, date
order by PercentPopulationInfected desc;

# 5.Top 10 Countries with Highest Death Count per Population

SELECT 
    location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS Total_deaths
FROM 
    covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
    location
HAVING 
	Total_deaths <> 0
ORDER BY  
    Total_deaths DESC
LIMIT 10;

#6. Tests Analysis
SELECT 
    SUM(new_tests) AS New_Tests,
    SUM(total_tests) AS Total_tests,
	ROUND((SUM(new_tests) / SUM(total_tests) * 100),2) AS Test_percentage
FROM 
	covid_vaccinations
WHERE 
	continent IS NOT NULL;
    
# 7. Total Vaccinations by continent

SELECT 
	deths.continent,
    SUM(vacs.new_vaccinations) AS Vaccinations
FROM 
	covid_deaths deths
JOIN 
	covid_vaccinations vacs
	ON deths.location = vacs.location AND
		deths.date = vacs.date
WHERE deths.continent IS NOT NULL 
GROUP  BY deths.continent
ORDER BY Vaccinations DESC;

# 8. Vaccination Percentage by continent

WITH cte AS
(
SELECT 
    deths.continent,
    deths.location,
    deths.date,
    deths.population,
    vacs.new_vaccinations,
    SUM(CONVERT(vacs.new_vaccinations, UNSIGNED)) 
    OVER (PARTITION BY deths.location ORDER BY deths.location, deths.date) AS Rolling_sum_of_vaccination
FROM 
    covid_deaths deths
JOIN 
    covid_vaccinations vacs
    ON deths.location = vacs.location AND
       deths.date = vacs.date
WHERE 
    deths.continent IS NOT NULL 
)
SELECT continent,date, population, ( Rolling_sum_of_vaccination / population)*100 AS Percentage
FROM cte
HAVING Percentage IS NOT NULL ;

# 9. Top 10 Countries with Highest Vaccination Count per Population

SELECT 
	vacs.location,
    SUM(vacs.new_vaccinations) AS Vaccinations
FROM 
	covid_deaths deths
JOIN 
	covid_vaccinations vacs
	ON deths.location = vacs.location AND
		deths.date = vacs.date
WHERE deths.continent IS NOT NULL 
GROUP  BY vacs.location
ORDER BY Vaccinations DESC
LIMIT 10;

# 10. Top 10 countries by Average positive_rate

SELECT location,ROUND(AVG(positive_rate),2) AS Average_positiverate
FROM covid_vaccinations
GROUP BY location
HAVING  Average_positiverate IS NOT NULL
ORDER BY Average_positiverate DESC
LIMIT 10;

-- ------------------------------------------------------------------------------------------------------------------------------------------