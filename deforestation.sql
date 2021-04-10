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
FULL OUTER JOIN forest_area fa
ON la.country_code = fa.country_code AND la.year = fa.year
FULL OUTER JOIN regions rg
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
GROUP BY 1, 2

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
This query utilises the first query above in the form of a Common Table
Expression (CTE). By using the subquery in the CTE, the main query identifies
the region with the highest forest area in 2016 by limiting the results to 1 row
and sorting the results in descending order according to 'forest_percentage'.
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
Note that I was struggling to round off to decimal places earlier for this
specific question, Question 2(a). To solve this, I used the CAST data cleaning
function to convert the existing numeric values (double precision) into a
decimal value type and it is now possible to round off to 2 decimal places.
*/



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
This query calculates the total forest and land areas per region and returns the
values for each year per region.
*/
SELECT region,
       year,
       SUM(forest_area_sq_km) AS forest_area_sum,
       SUM(total_area_sq_km) AS land_area_sum,
       (SUM(forest_area_sq_km)/SUM(total_area_sq_km)) * 100 AS forest_percentage
FROM forestation
GROUP BY 1, 2
ORDER BY 1, 2

/*
Question 2(b)(i)

This query uses the query above in the form of a CTE. Using the subquery, this
specific query identifies the total forest area of the world in 1990. This is
achieved by filtering via a WHERE clause where the year is filtered to 1990 and
the region is filtered to 'World'.
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

Similar to the query in Question 2(b)(i) above, this query uses the same CTE.
The table that is returned lists the region with their respective forest_percentage
area, in descending order.
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
Question 2(b)(iii)

Similar to the query in Question 2(b)(i) above, this query uses the same CTE.
The table that is returned lists the region with their respective forest_percentage
area, in ascending (default) order.
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

/*
I need to use a PARTITION BY clause in this question in order to solve this
problem correctly.
*/

/*
This specific query is an interim query which will be used later in this question
as a subquery within a CTE. This query refines the data by returning the forest
area percentage as a decimal value rounded to 2 decimal places. It returns the
values for 1990 and 2016.

This query is one of the interim steps in calculating the LAG/LEAD difference in
a later query which will answer the question at hand. This query provides the
starting values for both years, which are needed for the LAG/LEAD functions.
*/
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
ORDER BY 1, 2

/*
This query uses the table in the CTE to return the LAG value for each row and
it also calculates the LAG Difference by subtracting the LAG value from the
current row value. To avoid NULL data types, I have modified the LAG function to
return a '0' string where there is no LAG value for a current row (ie the firstl
row).

This query is implemented to test that the LAG function returns the correct
values and also to test and verify the LAG difference calculation.
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
       LAG(forest_percentage, 1, '0') OVER
       (PARTITION BY region ORDER BY forest_percentage) AS lag_value,
       forest_percentage - LAG(forest_percentage) OVER
       (PARTITION BY region ORDER BY forest_percentage) AS lag_difference
FROM region_percent
ORDER BY 1, 2

/*
This is the final query for this question. It's similar to the query above. The
LAG value column is removed as it's not necessary to be displayed for a user.

If the LAG difference value is displayed in the 2016 row, then this is a positive
value. If the LAG difference value is displayed in the 1990 row, then this is a
negative value.
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
SELECT country,
       year,
       forest_area_sq_km AS forest_area_1990
FROM forestation f90
WHERE (year = 1990)
ORDER BY 1, 2;


SELECT country,
       year,
       forest_area_sq_km AS forest_area_2016
FROM forestation
WHERE (year = 2016)
ORDER BY 1, 2;

SELECT country,
       year,
       forest_area_sq_km AS forest_area_1990
FROM forestation
WHERE (year = 1990)

UNION

SELECT country,
       year,
       forest_area_sq_km AS forest_area_2016
FROM forestation
WHERE (year = 2016)

ORDER BY 1, 2;


SELECT f90.country,
       f90.year,
       f90.forest_area_sq_km AS forest_area_1990,
       f16.year,
       f16.forest_area_sq_km AS forest_area_2016
FROM forestation f90
LEFT JOIN forestation f16
ON f90.country = f16.country
WHERE (f90.year = 1990) AND (f16.year = 2016)
ORDER BY 1, 2

/*
This query contains a Self JOIN which is used in order to make it easier to
calculate the difference between the forest area between 1990 and 2016.
*/
SELECT f90.country AS country,
       f90.forest_area_sq_km AS forest_area_1990,
       f16.forest_area_sq_km AS forest_area_2016
FROM forestation f90
LEFT JOIN forestation f16
ON f90.country = f16.country
WHERE (f90.year = 1990) AND (f16.year = 2016)
ORDER BY 1, 2

/*
This query uses the above query as an Inline Subquery to calculate the change in
(or difference) in forest area between 1990 and 2016.

Calculating the change in this manner is ideal because the returned value can be
negative, NULL, 0 (such as Afghanistan) or positive.
*/
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
ORDER BY 1;

/*
This query leverages the query above in the form of a CTE. The query returns a
table which pulls the 'change' value from the CTE. Using these 'change' values,
the query then uses a Ranking Window function to rank the countries according to
their 'change' values.

ROW_NUMBER() is used here as it's unlikely that that there will be any identical
'change' values. To eliminate countries where there was no data available to
calculate the 'change' value (such as Kosovo), the 'change' value is filtered to
exclude any 'change' values that are NULL.

This particular query is used to provide information regarding '3.1 Success
Stories' within the report. This is evident as the ranking is sorted in
descending order.
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
This query is used to provide the numerical information for the total land area
for China and the USA for footnote 2 within the report.
*/
SELECT country,
       year,
       total_area_sq_km
FROM forestation
WHERE (country = 'China' OR country = 'United States') AND (year =2016)
ORDER BY 1, 2

/*
This query includes the land area of each country as well as a column which
returns the percentage of forest area for each country. This is an interim
query which will be used as part of a larger query to extract the information
needed to complete the '3.1 Success Stories' section of the report.
*/
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
ORDER BY 1

/*
This query uses the above query as an Inline Subquery. The query returns the
percentage change (difference) between 1990 and 2016. To make the ROUND function
useable, the difference value is converted into a decimal data type. This query
as a whole is the Inner Query to be used in the queries where the RANKING of
countries according to the percentage change will be required.
*/
SELECT sub.country AS country,
       ROUND(CAST(forest_percentage_2016 - forest_percentage_1990 AS decimal), 2) AS percent_change
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
ORDER BY 1

/*
This query uses the above query as a CTE in order to return a ranking of the
countries, as per their percentage change in forest area over the 27 years. The
RANK() function is used here, as it is possible to have values that overlap. The
ranking is sorted in descending order to identify the country that had the best
percentage increase in terms of forest area.

To clear the rankings of countries with NULL values and/or no values, the data
is filtered to exclude NULL values and also excludes the 'World' as a country.
The CTE name 'fapc' stands for 'forest_area_percentage_change'.
*/
WITH fapc AS
(
  SELECT sub.country AS country,
         ROUND(CAST(forest_percentage_2016 - forest_percentage_1990 AS decimal), 2) AS percent_change
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
)
SELECT country,
       percent_change,
       RANK() OVER (ORDER BY percent_change DESC) AS percent_ranking
FROM fapc
WHERE (percent_change IS NOT NULL) AND (country != 'World')



/*
3. COUNTRY-LEVEL DETAIL

a. a. Which 5 countries saw the largest amount decrease in forest area from 1990
   to 2016? What was the difference in forest area for each?
*/

/*
This query uses a SELECT DISCTINCT statement to cut away all the repetition of
the country names when displayed alongside their region.

With an ordinary 'SELECT country' statement, the query would return 27 rows of
a specific country's name all containing the same region. This is far from ideal
so this query cleans the data up so that it can be used as part of a larger
query later.
*/
SELECT DISTINCT country,
       region
FROM forestation

/*
The table in the report requires not only the country name, but also each
country's region. To achieve this, I have created a CTE which contains 2 tables.
The first table 'fadc' (forest_area_data_change) has been used before. The 2nd
table returns a table with each country listed along with their respective
region.

To obtain the table needed, the CTE tables are JOINed on the country column.
Additionally countries with NULL values and the 'World' are excluded. The change
value is ranked via the RANK() function, which identifies the countries most
affected by deforestation by sorting the ranking in ascending order.
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


/*
I need to return to this question later, as I am not sure if my query is right
or if the question is incorrect.
*/
WITH fapc AS
(
  SELECT sub.country AS country,
         ROUND(CAST(forest_percentage_2016 - forest_percentage_1990 AS decimal), 2) AS percent_change
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
SELECT fapc.country,
       rgn.region,
       fapc.percent_change,
       RANK() OVER (ORDER BY fapc.percent_change DESC) AS percent_ranking
FROM fapc
JOIN rgn
ON fapc.country = rgn.country
WHERE (fapc.percent_change IS NOT NULL) AND (fapc.country != 'World')



/*
3 COUNTRY-LEVEL DETAIL

c. If countries were grouped by percent forestation in quartiles, which group
   had the most countries in it in 2016?
*/

/*
This query pulls the forest percentage per country for 2016. It's arranged in
alphabetical order and the query is filtered
*/
SELECT country,
       year,
       CAST(forest_percentage AS decimal) AS forest_percentage
FROM forestation
WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')
ORDER BY 1;


/*
This query was a failed attempt at resolving the data into quartiles. All this
query did was split up the 204 countries into 4 parts. This is not what I need
in order to answer this question.
*/
SELECT sub.country AS country,
       sub.forest_percentage AS forest_percentage,
       NTILE(4) OVER
       (ORDER BY sub.forest_percentage) AS quartile,
       CASE WHEN NTILE(4) OVER (ORDER BY sub.forest_percentage) = 1 THEN 'first_quartile'
            WHEN NTILE(4) OVER (ORDER BY sub.forest_percentage) = 2 THEN 'second_quartile'
            WHEN NTILE(4) OVER (ORDER BY sub.forest_percentage) = 3 THEN 'third_quartile'
            ELSE 'fourth_quartile' END AS quartile_label
FROM (
  SELECT country,
         year,
         forest_percentage
  FROM forestation
  WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')
) sub


/*
After understanding the question a bit better after my error above, this query
uses a CASE statement to classify each country into a quartile according to
their forest area percentage. The CASE statement results in the creation of a
Derived Column whose row values are dependen on the WHEN/ELSE conditions being
satisfied by a specific country.
*/
SELECT sub.country AS country,
       sub.forest_percentage AS forest_percentage,
       CASE WHEN sub.forest_percentage <= 25 THEN '1st_quartile'
            WHEN sub.forest_percentage > 25 AND sub.forest_percentage <= 50 THEN '2nd_quartile'
            WHEN sub.forest_percentage > 50 AND sub.forest_percentage < 75 THEN '3rd_quartile'
            ELSE '4th_quartile' END AS quartile
FROM (
  SELECT country,
         year,
         CAST(forest_percentage AS decimal) AS forest_percentage
  FROM forestation
  WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')
) sub
ORDER BY 3


/*
Using the above query as a CTE, this query uses the COUNT function to return a
count of each quartile. COUNT must be used in this case as the data type in the
'quartile' column is a string, so SUM would not work in this case.
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

/*
Using the CTE that was created in Question 3(c), containing the query which
returns the quartile category for each country according to their forest
percentage area, another query is added as a second table to this CTE which
provides the region information for each country.

The table in the project template for this section has a 'Region' column, thus
the query itself must also return a list of countries, their region and their
forest percentage area (being greater than 75%).

This query uses the 2 subqueries contained in the CTE to return a list of all
countries (including their region) which have a forest percentage area greater
than 75% and it also display's the country's 2016 forest area percentage.
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

/*
This query isolates the United States as a country and returns their 2016 forest
area percentage. This query will be used as a foundation to create a Scalar
Subquery which only returns the forest area percentage value.
*/
SELECT country,
       year,
       forest_percentage
FROM forestation
WHERE (country = 'United States' AND year = 2016)

/*
This query builds on the query above by using it as an Inline Subquery to return
only the value of the USA's forest area percentage.
*/
SELECT ABS(sub1.forest_percentage) AS usa_fap
FROM (
  SELECT country,
         year,
         forest_percentage
  FROM forestation
  WHERE (country = 'United States' AND year = 2016)
) sub1


/*
This query uses the above query as a Scalar Subquery to return a list of countries
which have a forest area percentage greater than the USA. Again, this query will
be used
*/
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
ORDER BY 3 DESC;

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

The reason I have created these queries is that I make a reference to the
number of countries that have a 0 forest percentage value within the RECOMMENDATION
portion of the report.
*/
SELECT country,
       year,
       forest_percentage
FROM forestation
WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')


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


/*
3. COUNTRY-LEVEL DETAIL

b. Which 5 countries saw the largest percent decrease in forest area from 1990
   to 2016? What was the percent change to 2 decimal places for each?
*/

/*
After posting on Udacity's Knowledge page about this question, I believe that
I misunderstood the question. I need to modify my query such that it uses the
following formula for Percentage Decrease over time:

Percentage Decrease = [1 - (End % / Start %) * 100]

I still don't quite understand this question 100%.
*/

/*
This the standard query that I used to return all the applicable data for 1990
and 2016 regarding forest and land area as well as forest area percentage for
both years. This will be used as a subquery in a further query.
*/
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
ORDER BY 1

/*
This query uses the query above as an Inline Subquery. My main aim with this
query is to extract only the necessary data (1990 & 2016 values) and to calculate
and verify the quotient when the 2016 forest area percentage is divided by the
1990 forest area percentage.

I am returning the quotient in this query as it will allow the creation of the
finaly query to be much cleaner.
*/
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

/*
This is the final query for Question 3(b). 'Leveraging' a CTE containing 2
queries, the forest percentage change is calculated (which is made much easier
by already having the quotient to work with) and the results are displayed,
limited to 5 countries as per the question.
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
I made a mistake when it comes to the initial calculation values that were used
in the first version of this project. Using Rounded Off values worked for the
most part, but the Reviewer picked up an issue with Question 3 (c).

Also, I made a mistake in 'Success Stories' where I seem to have used the wrong
year when it came to calculating the country with the highest forest area
percentage. I used the 2016 land area instead of the 1990 land area.

Let's fix these 2 issues.
*/

/*
I need to modify the 'forestation' VIEW so that it will be able to return a
forest area percentage value rounded off to 2 decimal places.
*/
CREATE VIEW forestation AS
SELECT la.country_code AS code,
       la.country_name AS country,
       rg.region AS region,
       rg.income_group AS income_group,
       la.year AS year,
       ROUND(fa.forest_area_sqkm) AS forest_area_sq_km,
       ROUND(la.total_area_sq_mi * 2.5899) AS total_area_sq_km,
       ((ROUND(fa.forest_area_sqkm) / ROUND(la.total_area_sq_mi * 2.5899)) * 100) AS forest_percentage
FROM land_area la
FULL OUTER JOIN forest_area fa
ON la.country_code = fa.country_code AND la.year = fa.year
FULL OUTER JOIN regions rg
ON rg.country_code = la.country_code;


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

SELECT sub.country,
       sub.year,
       sub.forest_area_sq_km,
       sub.change,
       ROUND(CAST(sub.change_percentage AS decimal), 2) AS change_percentage
FROM (
  SELECT country,
         year,
         forest_area_sq_km,
         COALESCE(forest_area_sq_km - LAG(forest_area_sq_km) OVER (ORDER BY year), 0) AS change,
         ((COALESCE(forest_area_sq_km - LAG(forest_area_sq_km) OVER (ORDER BY year), 0)) / forest_area_sq_km) * 100 AS change_percentage
  FROM forestation
  WHERE (year = 1990 OR year = 2016) AND (country = 'World')
) sub
ORDER BY 2;



/*
This section is aimed at fixing the 'Success Stories' issue
*/
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
WHERE (f90.year = 1990) AND (f16.year = 2016) AND (country = 'Iceland')
ORDER BY 1


SELECT sub.country AS country,
       CAST((sub.forest_area_2016 - sub.forest_area_1990) / sub.forest_area_1990 AS decimal) AS quotient
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
ORDER BY 1;


WITH fapc AS (
  SELECT sub.country AS country,
         CAST((sub.forest_area_2016 - sub.forest_area_1990) / sub.forest_area_1990 AS decimal) AS quotient
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
)
SELECT country,
       ROUND(quotient * 100, 2) AS percent_change
FROM fapc
WHERE (ROUND(quotient * 100, 2) IS NOT NULL) AND (country != 'World')
ORDER BY 2 DESC


/*
This section is aimed at fixing Question 3(c)
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
           CAST(forest_percentage AS decimal) AS forest_percentage
    FROM forestation
    WHERE (year = 2016) AND (forest_percentage IS NOT NULL) AND (country != 'World')
  ) sub
  ORDER BY 3
)
SELECT quartile,
       COUNT(quartile) AS quartile_count
FROM qtl
GROUP BY 1
ORDER BY 1;
  
