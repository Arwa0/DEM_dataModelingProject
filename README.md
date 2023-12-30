# project overview
 Building a data warehouse for an E-commerce website to answer business questions. The project consists of : 
<p>  ·Schema Design and Data Modeling</p>
<p>  ·Staging Area Implementation</p>
<p>  ·Data Warehouse Construction</p>
<p>  ·ETL Process Implementation</p>
<p>  ·Answering Business questions </p>


## Date source
you can find the source data used in this [GitHub link](https://github.com/OmarEhab007/Data_Engineering_Mentorship/blob/main/level_1/Data_Modeling/projects/ecommerce/ecommerce%20dataset.zip/).

## Schema Design and Data Modeling
we have developed a dimensional model design life cycle (DMDL) which consists of the following phases:
### Identify business process requirements.
In this phase, we prioritize the business processes. The basic idea here is to identify the most and least feasible processes for building a dimensional model, so based on the data we have These are some processes for e-commerce business.
| Business processes | Date | Time | Product | Customer |seller|  feedback |…more |
| --- | --- | --- | --- | --- | --- | --- | --- |
|sales|x|x|x|x|x|x| |
| Payment |x|x|x|x| | | |
|Shipping|x|x|x| |x| | |
|Customer Service |x|x|x| ||x| |

### Identify the grain
The grain conveys the level of detail associated with the fact table measurements. Identifying the grain also means deciding on the level of detail you want to be made available in the dimensional model.The chosen grain is "Order Lifetime". It provides a comprehensive view of the entire lifecycle of each order. This level of detail allows for thorough analysis of customer behavior, order fulfillment, and payment processing. It enables tracking changes in order status over time and facilitates insights into the performance of both users and sellers throughout the order lifecycle.

### Identify the dimensions
During this phase, we identify the dimensions that are true to the grain we chose
|Dimension table|Granularity of the dimension table|
|---|---|
|Time|This dimension stores information about hour, and a description of the time, such as morning, afternoon, and night |
| Date | This dimension stores information down to the day level including month, quarter, and year |
| Users | This dimension stores information about the user. |
|Sellers |This dimension stores information about the seller. |
|Feedback |This dimension stores information about the feedback for orders. |

### Identify the facts 
**Order_Fact Table**
*Measurements:*

Total price
FKs from Dimensions:
User
Time
Payment
Seller
Feedback
Data




*Choosing Primary Keys of Dimensions:*

Dimension tables (UserDim, PaymentDim, Seller, Feedback) use   surrogate keys.
A surrogate key is:

An automatically generated unique identifier for each row
    It has no intrinsic meaning - just provides a unique id
    Usually an integer (identity) column
    For example:
   -UserDim - user_key int identity(1,1)
   -PaymentDim - payment_key int identity(1,1)
   
·This allows adding/updating rows flexibly without constraints from a natural key.


   
*TimeDim table:*
TimeKey column is used as the primary key.

It is an integer identity column.

This makes it a surrogate key.
We have used a surrogate key for TimeDim because:
Time is a continuous measure and there may be duplicate times like 12:00 AM.
A natural key based on time values alone would not be unique.
An integer key provides a simple, unique identifier for each time.



*DateDim table:*
DateKey column is used as the primary key

It is calculated as YEAR(@Date) * 10000 + MONTH(@Date) * 100 + DAY(@Date)
This makes it a composite natural key We have used a composite natural key for DateDim

### Choose a proper data warehouse model : (Star Schema)
(![Untitled](https://github.com/Arwa0/DEM_dataModelingProject/assets/74055031/605b2b3f-7d94-492b-a138-1bd0ce14cc32)


*Why did we use a star schema?*

The schema revolves around a central fact table called Order_Fact which contains the numeric facts like total price.

It has multiple dimension tables like UserDim, PaymentDim etc that provide attributes about the measures in the fact table.

The dimension tables are normalized with a primary key and connected to the fact table through foreign keys.

There are no connections between the dimension tables themselves, they only connect to the central fact table.

This structure forms a star shape with the fact table at the center and dimension tables radiating out from it.

## Staging Area:
We have Loaded the data from Excel sheets to a  temporary database so that we can clean it and prepare it
Data warehouse construction by SQL Server:

## Creating datawarehose
the code of creating it is found in this repo [link ](dwh.sql/).

## ETL pipeline
we implemented ETL (Extract - Transform -Load) process using ssis tool , 
you can found the whole project here [link ](https://github.com/Arwa0/DEM_dataModelingProject/tree/8e788ffe83c19d961548ad7dc20021a2ee5a8bb9/DEM_data%20modeling).
## Answering Business questions 
After creating the dataware house, and loading data into it now we can answer business questions using sql queries 
sample of questions the bussness need to answer it :

**When is the peak season of our e-commerce?**
```
Select top 1 count(f.order_id) , d.season
From order_fact as f
Inner join dateDim as d
on d.[DateKey] = f.[order_date_key]
Group by d.season
Order by count(f.order_id) desc
```
and creating a dashboard represent these result :
![photo_2023-12-29_19-56-30](https://github.com/Arwa0/DEM_dataModelingProject/assets/74055031/d41e5716-1535-4f84-8b95-d67198d630f2)

 to see the answers on Business questions and all the insights , see this [queries file](quries_answering_business_questions.sql)
