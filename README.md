# Data Analyst Portfolio Project — SQL Data Exploration

Exploring global COVID-19 deaths and vaccinations data using SQL Server, covering:
- Total cases vs. total deaths (death likelihood by country)
- Total cases vs. population (infection rate)
- Countries and continents with highest infection/death counts
- Global daily case and death trends
- Joining deaths and vaccinations tables on location and date
- Rolling vaccination count using window functions (SUM OVER PARTITION BY)

## Key Insights
- India's death % was highest early in the pandemic (~2.9% in April 2020), 
  trending down over time as testing and treatment improved.
- Small countries like Andorra topped the infection-rate-by-population list.
- United States had the highest total death count, making North America 
  the hardest-hit continent overall.
- India's vaccination drive began 16-01-2021, with 191,181 people 
  vaccinated on day one — the rolling total climbs steadily from there.

## Challenges Solved
- Cleaned messy imported data (data type mismatches, mixed date formats
  across tables) before joining and analyzing.

## Tools Used
SQL Server, SSMS
