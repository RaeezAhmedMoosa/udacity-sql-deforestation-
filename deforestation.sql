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
