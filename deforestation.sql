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
