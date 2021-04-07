/*
SQL Deforestation Project

I am a Data Analyst working for an NPO called 'ForestQuery'. I need to submit a
written report to the ForestQuery executive team which will assist the executive
team in making decisions regarding the issue of global deforestation viewed over
a period of 26 years, from 1990 until 2016.

These are the steps to be completed:

1. Create a VIEW called 'forestation' by JOINing all 3 tables - being
  'forest_area', 'land_area' and regions.

2. The 'forest_area' and 'land_area' tables JOIN  on both the country_code and
   year columns.

3. The 'regions' table JOINs these based only on the country_code column.

4. In the 'forestation' VIEW, include the following:

       * All the columns of the origin tables

       * A New column that returns a 'Percentage' of land area that is designated
         as forest

5. Note that the columns forest_area_sqkm and land_area_sqmi are in different
   units. Therefore an adjustment must be made in order to properly perform any
   calculations involving the 2 values. Since I am from a country that uses the
   metric system, I will stick with kilometers squared as my preferred value.

   1 mile squared = 2.5899 kilometers squared

*/

/*
Initial Table comments/thoughts

* 'forest_area'

The 'forest_area' table has 4 columns, which are:

  1. country_code
  2. country_name
  3. year
  4. forest_area_sqkm

Now, at this stage I feel that the forest_area_sqkm column looks a bit untidy as
the values are rounded off to 6 decimal places. For better visual clarity, I will
ROUND these values to either 2 or 3 decimal places.

From a quick SELECT * query, 'forest_area' has 5886 rows.


* 'land_area'

The 'land_area' table has 4 columns, which are:

  1. country_code
  2. country_name
  3. year
  4. land_area_sqmi

As noted earlier, I need to convert the last column 'land_area_sqmi' into
'land_area_sqkm' so that I can perform the necessary calculations correctly.

Running another SELECT * query, this returns 5886 rows from the 'land_area' table


* 'regions'

The 'regions' table has 4 columns, which are:

  1. country_name
  2. country_code
  3. region
  4. income_group

A SELECT * query shows that the 'regions' table has 219 rows in total.

*/

/*
Creating the 'forestation' VIEW
*/

/*
To make the calculations a bit easier (avoiding decimal values) and to make the
columns a bit easier to read, I am using the ROUND function to round off the
values for both forest area and land area to the nearest unit.
*/

/*
This is the query rounding off the forest area.
*/
SELECT fa.country_code AS code,
       fa.country_name AS country,
       fa.year AS year,
       ROUND(fa.forest_area_sqkm) AS forest_area_sq_km
FROM forest_area fa
LIMIT 100;

/*
This is the query rounding off the land area.
*/
SELECT la.country_code AS code,
       la.country_name AS country,
       la.year AS year,
       ROUND(la.total_area_sq_mi * 2.5899) AS total_area_sq_km
FROM land_area la
LIMIT 100;


/*
This is a test query that focused on returning the forest percentage as a new
column, which will be incorporated in the final VIEW table.
*/
SELECT la.country_code AS code,
       la.country_name AS country,
       la.year AS year,
       ROUND(fa.forest_area_sqkm) AS forest_area_sq_km,
       ROUND(la.total_area_sq_mi * 2.5899) AS total_area_sq_km,
       ROUND((ROUND(fa.forest_area_sqkm) / ROUND(la.total_area_sq_mi * 2.5899)) * 100) AS forest_percentage
FROM land_area la
JOIN forest_area fa
ON la.country_code = fa.country_code AND la.year = fa.year
ORDER BY 2, 3
LIMIT 100;


SELECT la.country_code AS code,
       la.country_name AS country,
       rg.region AS region,
       rg.income_group AS income_group,
       la.year AS year,
       ROUND(fa.forest_area_sqkm) AS forest_area_sq_km,
       ROUND(la.total_area_sq_mi * 2.5899) AS total_area_sq_km,
       ROUND((ROUND(fa.forest_area_sqkm) / ROUND(la.total_area_sq_mi * 2.5899)) * 100) AS forest_percentage
FROM land_area la
JOIN forest_area fa
ON la.country_code = fa.country_code AND la.year = fa.year
JOIN regions rg
ON rg.country_code = la.country_code
ORDER BY 2, 4
LIMIT 100;

/*
This is the first step completed. This is the 'forestation' VIEW.
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
JOIN forest_area fa
ON la.country_code = fa.country_code AND la.year = fa.year
JOIN regions rg
ON rg.country_code = la.country_code;



/*
1. GLOBAL SITUATION

a. What was the total forest area (in sq km) of the world in 1990?
   Please keep in mind that you can use the country record denoted as “World"
   in the region table.
*/
SELECT country,
       year,
       forest_area_sq_km,
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

c. What was the change (in sq km) in the forest area of the world from 1990 to
   2016?
*/
SELECT country,
       year,
       forest_area_sq_km,
       COALESCE(forest_area_sq_km - LAG(forest_area_sq_km) OVER (ORDER BY year), 0) AS change
FROM forestation
WHERE (year = 1990 OR year = 2016) AND (country = 'World');



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

/*
Working with the query above in Question 1(c), I first have to change the value
returned in 1(c) to a positive value so that the query below can return an integer
that is positive.

To eliminate the 0 value returned in 1(c), and to incorporate this query as a
scalar subquery as part of the Outer Query, this query filters the values to
only return a negative value. This negative value is then converted into a
positive value using the ABS function.
*/
SELECT ABS(change) AS change
FROM (
  SELECT country,
         year,
         forest_area_sq_km,
         COALESCE(forest_area_sq_km - LAG(forest_area_sq_km) OVER (ORDER BY year), 0) AS change
  FROM forestation
  WHERE (year = 1990 OR year = 2016) AND (country = 'World')
) sub
WHERE change < 0;


/*
The Outer Query below returns a list of countries, sorted by 'total_area_sq_km'
in descending order. To get the latest results, the year is filtered to return
only the values for 2016.

The subquery written above is used as a Scalar Subquery here to filter all the
countries out that have a total land area greater than the amount of forest area
lost in the 27 period of the data.
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
2. REGIONAL OUTLOOK

a. What was the percent forest of the entire world in 2016? Which region had the
   HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
*/

/*
Question 2(a) can be broken down into 3 sub questions, firstly the percentage of
forest for the world, secondly region with the highest percentage of forest (2
decimal places) and lastly the region with the lowest percentage of forest (2
decimal places).
*/

/*
This query calculates the total forest and land areas per region and returns the
values, filtered to include only the 2016 values. This specific query also
filters the results further by only returning the data for the 'World'
*/
SELECT region,
       year,
       SUM(forest_area_sq_km) AS forest_area_sum,
       SUM(total_area_sq_km) AS land_area_sum,
       (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
FROM forestation
WHERE year = 2016 AND region = 'World'
GROUP BY 1, 2
ORDER BY 1, 2

/*
This query utilises the query above in the form of a Common Table Expression
(CTE). By using the subquery in the CTE, the main query identifies the region
with the highest forest area in 2016 by limiting the results to 1 row and sorting
the results in descending order according to 'forest_percentage'.
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
Similar to the query above, this specific query identifies the region with the
lowest forest area in 2016. This is done by limiting the results to 1 row and
sorting the 'forest_percentage' column in ascending (default) order.
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
ORDER BY 3
LIMIT 1;
/*
Note that I was struggling to round off to decimal places earlier for this
specific question, Question 2(a). To solve this, I used the CAST data cleaning
function to convert the existing numeric values (double precision) into a
decimal value type and it is now possible to round off to 2 decimal places.
*/
