/* raw data explanation */
/** ECE_2S_2019_WEB.sav **/

* Broad concepts ---#

This table contains the raw data necessary to perform the calculations it was
collected in 2019 by the Ministry of Education. This nationwide iniciative 
that took place across Peru is considered an "effective planning tool", and for the
purposes of this analysis it will also be "an effective case study".
The exam in 2019 consisted of three main areas of knowledge: reading,
mathematics and natural science each one with their own baseline values.

* Data concepts -----#

** ISE (índice socioeconómico)

1. Content: It is the result of a principal component analysis on the following 4 
variables per each student: (1) parents' years of study; (2) building materials of
the house in which the student lives; (3) basic services available in the house;
(4) other services available in their house.

2. Validity: We are getting closer to the intended variable (a latent
variable which measure economic factors) per each student by capturing
all information in those 4 variables. In addition to that, as we aggregate
the results per student to per district information is lost, so that is one
of the assumptions of the present study.


/* Summary of produced tables */

(1)  01_ece_2019_indicator_eco.rds 
* rows = 1781, cols = 4.
* key = the column which identifies each row, it consists of the district of Peru which
in this case amounts to 1781. 
* Data cleaning:
** I aggregated the results from per student to per district using a simple average. My
intention is to use this proxy variable as a column which hopefully will make
possible to measure economic factors per district.

(2) 02_resultados_ece.rds 
* rows = 14520 , cols = 5
* Each row of this table contains information about schools, so it is in a different
level of aggregation to that of 01_ece_2019_indicator_eco.rds. It contains the test 
score achieved by each school.

(3) workfile.rds

* rows = 11166, cols = 8
* When merging the two tables(02_resultados_ece.rds AND 01_ece_2019_indicator_eco.rds) I
used an inner join so that I can get the rows which have a match in both tables.
* Each row of this table contains information about school and the associated
economic factors per district, namely all schools who belongs to a district
share the same economic indicator.
 