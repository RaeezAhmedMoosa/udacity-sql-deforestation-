/*
1. Create a VIEW called 'forestation' by JOINing all 3 tables - being
  'forest_area', 'land_area' and regions.
*/
CREATE VIEW forestation AS
SELECT la.country_code AS code,
       la.country_name AS country,
       rg.region AS region,
       rg.income_group AS income_group,
       la.year AS year,
       ROUND(fa.forest_area_sqkm) AS forest_area_sq_km,
       ROUND(la.total_area_sq_mi * 2.5899) AS total_area_sq_km,
       ROUND((ROUND(fa.forest_area_sqkm) / ROUND(la.total_area_sq_mi * 2.5899)) * 100) AS forest_percentage
FROM land_area la
FULL OUTER JOIN forest_area fa
ON la.country_code = fa.country_code AND la.year = fa.year
FULL OUTER JOIN regions rg
ON rg.country_code = la.country_code;


/*
QUESTION 1 GLOBAL SITUATION
*/


/*
1. GLOBAL SITUATION

a. What was the total forest area (in sq km) of the world in 1990?
   Please keep in mind that you can use the country record denoted as “World"
   in the region table.
*/
SELECT country,
       year,
       forest_area_sq_km
FROM forestation
WHERE (year = 1990 AND country = 'World');


/*
1. GLOBAL SITUATION

b. What was the total forest area (in sq km) of the world in 2016?
*/
SELECT country,
       year,
       forest_area_sq_km
FROM forestation
WHERE (year = 2016 AND country = 'World');


/*
1. GLOBAL SITUATION

d.  What was the percent change in forest area of the world between 1990 and
    2016?
*/
SELECT country,
       year,
       forest_area_sq_km,
       COALESCE(forest_area_sq_km - LAG(forest_area_sq_km) OVER (ORDER BY year), 0) AS change,
       ((COALESCE(forest_area_sq_km - LAG(forest_area_sq_km) OVER (ORDER BY year), 0)) / forest_area_sq_km) * 100 AS change_percentage
FROM forestation
WHERE (year = 1990 OR year = 2016) AND (country = 'World');


/*
1. GLOBAL SITUATION

e. If you compare the amount of forest area lost between 1990 and 2016, to which
   country's total area in 2016 is it closest to?
*/
SELECT country,
       year,
       total_area_sq_km
FROM forestation
WHERE total_area_sq_km <= (
  SELECT ABS(change) AS change
  FROM (
    SELECT country,
           year,
           forest_area_sq_km,
           COALESCE(forest_area_sq_km - LAG(forest_area_sq_km) OVER (ORDER BY year), 0) AS change
    FROM forestation
    WHERE (year = 1990 OR year = 2016) AND (country = 'World')
  ) sub
  WHERE change < 0
)
AND year = 2016
ORDER BY 3 DESC;



/*
QUESTION 2 REGION OUTLOOK
*/

/*
2. REGIONAL OUTLOOK

a. What was the percent forest of the entire world in 2016? Which region had the
   HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
*/
WITH region_sum AS
(
  SELECT region,
         year,
         SUM(forest_area_sq_km) AS forest_area_sum,
         SUM(total_area_sq_km) AS land_area_sum,
         (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
  FROM forestation
  GROUP BY 1, 2
)
SELECT region,
       year,
       ROUND(CAST(forest_percentage AS decimal), 2) AS forest_percentage
FROM region_sum
WHERE (year = 2016 AND region = 'World')


/*
2. REGIONAL OUTLOOK

a. Which region had the HIGHEST percent forest in 2016 to 2 decimal places?
*/
WITH region_sum AS
(
  SELECT region,
         year,
         SUM(forest_area_sq_km) AS forest_area_sum,
         SUM(total_area_sq_km) AS land_area_sum,
         (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
  FROM forestation
  WHERE year = 2016
  GROUP BY 1, 2
)
SELECT region,
       year,
       ROUND(CAST(forest_percentage AS decimal), 2) AS forest_percentage
FROM region_sum
WHERE region != 'World'
ORDER BY 3 DESC
LIMIT 1;


/*
2. REGIONAL OUTLOOK

a. Which region had the LOWEST percent forest in 2016 to 2 decimal places?
*/
WITH region_16 AS
(
  SELECT region,
         year,
         SUM(forest_area_sq_km) AS forest_area_sum,
         SUM(total_area_sq_km) AS land_area_sum,
         (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
  FROM forestation
  WHERE year = 2016
  GROUP BY 1, 2
)
SELECT region,
       year,
       ROUND(CAST(forest_percentage AS decimal), 2) AS forest_percentage
FROM region_16
WHERE region != 'World'
ORDER BY 3
LIMIT 1;


/*
2. REGIONAL OUTLOOK

b. What was the percent forest of the entire world in 1990? Which region had the
   HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
*/

/*
Similar to Question 2(a) above, this question can also be broken down into 3
sub questions:

(b)(i) What was the percent forest of the entire world in 1990?

(b)(ii) Which region had the HIGHEST percent forest in 1990, to 2 decimal places

(b)(iii) Which region had the LOWEST percent forest in 1990, to 2 decimal places
*/

/*
Question 2(b)(i)
*/
WITH region_sum AS
(
  SELECT region,
         year,
         SUM(forest_area_sq_km) AS forest_area_sum,
         SUM(total_area_sq_km) AS land_area_sum,
         (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
  FROM forestation
  GROUP BY 1, 2
)
SELECT region,
       year,
       ROUND(CAST(forest_percentage AS decimal), 2) AS forest_percentage
FROM region_sum
WHERE (year = 1990 AND region = 'World')


/*
Question 2(b)(ii)
*/
WITH region_sum AS
(
  SELECT region,
         year,
         SUM(forest_area_sq_km) AS forest_area_sum,
         SUM(total_area_sq_km) AS land_area_sum,
         (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
  FROM forestation
  GROUP BY 1, 2
)
SELECT region,
       year,
       ROUND(CAST(forest_percentage AS decimal), 2) AS forest_percentage
FROM region_sum
WHERE year = 1990
ORDER BY 3 DESC;


/*
Question 2(b)(ii)
*/
WITH region_sum AS
(
  SELECT region,
         year,
         SUM(forest_area_sq_km) AS forest_area_sum,
         SUM(total_area_sq_km) AS land_area_sum,
         (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
  FROM forestation
  GROUP BY 1, 2
)
SELECT region,
       year,
       ROUND(CAST(forest_percentage AS decimal), 2) AS forest_percentage
FROM region_sum
WHERE year = 1990
ORDER BY 3;


/*
2. REGIONAL OUTLOOK

c. Based on the table you created, which regions of the world DECREASED in
   forest area from 1990 to 2016?
*/
WITH region_percent AS
(
  SELECT sub.region AS region,
         sub.year AS year,
         ROUND(CAST(sub.forest_percentage AS decimal), 2) AS forest_percentage
  FROM (
    SELECT region,
           year,
           SUM(forest_area_sq_km) AS forest_area_sum,
           SUM(total_area_sq_km) AS land_area_sum,
           (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
    FROM forestation
    GROUP BY 1, 2
  ) sub
  WHERE (sub.year = 1990 OR sub.year = 2016)
)
SELECT region,
       year,
       forest_percentage,
       forest_percentage - LAG(forest_percentage) OVER
       (PARTITION BY region ORDER BY forest_percentage) AS change
FROM region_percent
ORDER BY 1, 2



/*
3. COUNTRY-LEVEL DETAIL
*/


/*
Success Stories data
*/
WITH fadc AS
(
  SELECT country,
         forest_area_2016 -forest_area_1990 AS change
  FROM (
    SELECT f90.country,
           f90.forest_area_sq_km AS forest_area_1990,
           f16.forest_area_sq_km AS forest_area_2016
    FROM forestation f90
    LEFT JOIN forestation f16
    ON f90.country = f16.country
    WHERE (f90.year = 1990) AND (f16.year = 2016)
  ) sub
)
SELECT country,
       change,
       ROW_NUMBER() OVER (ORDER BY change DESC) AS ranking
FROM fadc
WHERE (change IS NOT NULL) AND (country != 'World')


/*
Footnote 2 data
*/
SELECT country,
       year,
       total_area_sq_km
FROM forestation
WHERE (country = 'China' OR country = 'United States') AND (year =2016)
ORDER BY 1, 2


/*
3. COUNTRY-LEVEL DETAIL

a. a. Which 5 countries saw the largest amount decrease in forest area from 1990
   to 2016? What was the difference in forest area for each?
*/
WITH fadc AS
(
  SELECT country,
         forest_area_2016 - forest_area_1990 AS change
  FROM (
    SELECT f90.country,
           f90.forest_area_sq_km AS forest_area_1990,
           f16.forest_area_sq_km AS forest_area_2016
    FROM forestation f90
    LEFT JOIN forestation f16
    ON f90.country = f16.country
    WHERE (f90.year = 1990) AND (f16.year = 2016)
  ) sub
),
     rgn AS
(
  SELECT DISTINCT country,
         region
  FROM forestation
)
SELECT fadc.country,
       rgn.region,
       fadc.change,
       RANK() OVER (ORDER BY fadc.change ) AS ranking
FROM fadc
JOIN rgn
ON fadc.country = rgn.country
WHERE (fadc.change IS NOT NULL) AND (fadc.country != 'World')


/*
3. COUNTRY-LEVEL DETAIL

b. Which 5 countries saw the largest percent decrease in forest area from 1990
   to 2016? What was the percent change to 2 decimal places for each?
*/
WITH pad AS
(
  SELECT sub.country AS country,
         ROUND(CAST(sub.forest_percentage_1990 AS decimal), 2) AS forest_percent_1990,
         ROUND(CAST(sub.forest_percentage_2016 AS decimal), 2) AS forest_percent_2016,
         CAST(sub.forest_percentage_2016 / sub.forest_percentage_1990 AS decimal) AS quotient
  FROM (
    SELECT f90.country AS country,
           f90.forest_area_sq_km AS forest_area_1990,
           f90.total_area_sq_km AS land_area_1990,
           (f90.forest_area_sq_km/f90.total_area_sq_km) * 100 AS forest_percentage_1990,
           f16.forest_area_sq_km AS forest_area_2016,
           (f16.forest_area_sq_km/f16.total_area_sq_km) * 100 AS forest_percentage_2016,
           f16.total_area_sq_km AS land_area_2016
    FROM forestation f90
    LEFT JOIN forestation f16
    ON f90.country = f16.country
    WHERE (f90.year = 1990) AND (f16.year = 2016)
  ) sub
),
     rgn AS
(
  SELECT DISTINCT country,
         region
  FROM forestation
)
SELECT pad.country,
       rgn.region,
       ROUND((1 - pad.quotient) * 100, 2) AS forest_area_percent_change
FROM pad
JOIN rgn
ON pad.country = rgn.country
WHERE (pad.country != 'World') AND (ROUND((1 - pad.quotient) * 100, 2) IS NOT NULL)
ORDER BY 3 DESC
LIMIT 5;


/*
3 COUNTRY-LEVEL DETAIL

c. If countries were grouped by percent forestation in quartiles, which group
   had the most countries in it in 2016?
*/
WITH qtl AS (
  SELECT sub.country AS country,
         sub.forest_percentage AS forest_percentage,
         CASE WHEN sub.forest_percentage <= 25 THEN '1st_quartile'
              WHEN sub.forest_percentage > 25 AND sub.forest_percentage <= 50 THEN '2nd_quartile'
              WHEN sub.forest_percentage > 50 AND sub.forest_percentage < 75 THEN '3rd_quartile'
              ELSE '4th_quartile' END AS quartile
  FROM (
    SELECT country,
           year,
           forest_percentage
    FROM forestation
    WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')
  ) sub
)
SELECT quartile,
       COUNT(quartile) AS quartile_count
FROM qtl
GROUP BY 1
ORDER BY 1;

/*
3. COUNTRY-LEVEL DETAIL

d. List all of the countries that were in the 4th quartile (percent forest >
   75%) in 2016.
*/
WITH qtl AS
(
  SELECT sub.country AS country,
         sub.forest_percentage AS forest_percentage,
         CASE WHEN sub.forest_percentage <= 25 THEN '1st_quartile'
              WHEN sub.forest_percentage > 25 AND sub.forest_percentage <= 50 THEN '2nd_quartile'
              WHEN sub.forest_percentage > 50 AND sub.forest_percentage < 75 THEN '3rd_quartile'
              ELSE '4th_quartile' END AS quartile
  FROM (
    SELECT country,
           year,
           forest_percentage
    FROM forestation
    WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')
  ) sub
),
     rgn AS
(
  SELECT DISTINCT country,
         region
  FROM forestation
)
SELECT qtl.country,
       rgn.region,
       qtl.forest_percentage,
       qtl.quartile
FROM qtl
JOIN rgn
ON qtl.country = rgn.country
WHERE qtl.quartile = '4th_quartile'
ORDER BY 3 DESC;


/*
3. COUNTRY-LEVEL DETAIL

e. How many countries had a percent forestation higher than the United States
   in 2016?
*/
WITH gtusa AS
(
  SELECT country,
         year,
         forest_percentage
  FROM forestation
  WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')
        AND forest_percentage > (
          SELECT ABS(sub1.forest_percentage) AS usa_fap
          FROM (
            SELECT country,
                   year,
                   forest_percentage
            FROM forestation
            WHERE (country = 'United States' AND year = 2016)
          ) sub1
        )
)
SELECT COUNT(*) AS country_count
FROM gtusa



/*
Below are a few queries which have been created to return the count of the
number of countries within the database that have a forest percentage value of
0.
*/
WITH nfa AS
(
  SELECT country,
         forest_percentage
  FROM (
    SELECT country,
           year,
           forest_percentage
    FROM forestation
    WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')
  ) sub
  WHERE forest_percentage = 0
)
SELECT COUNT(*) AS no_forest_count
FROM nfa
