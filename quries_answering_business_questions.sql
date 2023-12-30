--A) a.When is the peak season of our ecommerce ?
Select top 1 count(f.order_id) , d.season
From order_fact as f
Inner join dateDim as d
on d.[DateKey] = f.[order_date_key]
Group by d.season
Order by count(f.order_id) desc

--b.What time users are most likely make an order or using the ecommerce app?
SELECT top 1 t.TimeOfDay,COUNT(f.order_id) AS OrdersCount
FROM  order_fact f
INNER JOIN timeDim t 
ON f.[order_time] = t.[TimeKey]
GROUP BY  t.TimeOfDay
ORDER BY OrdersCount DESC

--c.What is the preferred way to pay in the ecommerce?
Select top 1 Count(payment_type) ,payment_type
From paymentDim
Group by payment_type
Order by Count(payment_type) desc

--d.How many installment is usually done when paying in the ecommerce?
Select  Count(payment_installments) as count , payment_installments 
From PaymentDim
Group by payment_installments
Order by Count(payment_installments) desc

--e.What is the average spending time for user for our ecommerce?
	/*considered each order should multiplayed with factor >> this is a comparison between spending time between users ,
	the more orders is a stronger indicator he spend more time on this ecommerce
	*/
select [user_key],count ([order_id]) as no_of_orders_per_day ,[order_date_key]
from [dbo].[Order_Fact]
group by [order_date_key] ,[user_key]
order by count ([order_id]) desc


--f.What is the frequency of purchase on each state?
Select count(order_id) as [purchases on each state] ,[user_state]
From [dbo].[Order_Fact] as o
Inner join userdim as u
On u.[user_key] =o.[user_key]
Group by ([user_state])
Order by Count(order_id) desc


--g.Which logistic route that have heavy traffic in our ecommerce?
/* WE considered heavy traffic  in days f delevary (if mch) , or in order_totals*/
SELECT 
    sd.seller_city AS origin_city,
    ud.user_city AS destination_city,
    COUNT(*) AS total_orders,
    AVG(DATEDIFF(DAY, 
        DATEADD(DAY, d1.DateKey % 100, DATEADD(MONTH, (d1.DateKey / 100) % 100 - 1, DATEADD(YEAR, d1.DateKey / 10000 - 1900, '1900-01-01'))),
        DATEADD(DAY, d2.DateKey % 100, DATEADD(MONTH, (d2.DateKey / 100) % 100 - 1, DATEADD(YEAR, d2.DateKey / 10000 - 1900, '1900-01-01')))
    )) AS avg_delivery_time
FROM 
  UserDim AS ud
INNER JOIN  Order_Fact AS o 
	ON o.user_key = ud.user_key
INNER JOIN Seller AS sd 
	ON o.seller_key = sd.seller_key
INNER JOIN DateDim AS d1 
	ON o.pickup_date_key = d1.DateKey
INNER JOIN DateDim AS d2 
	ON o.delivered_date_key = d2.DateKey
WHERE 
    o.delivered_date_key IS NOT NULL
    AND o.pickup_date_key IS NOT NULL
GROUP BY 
    sd.seller_city, ud.user_city
ORDER BY 
    total_orders DESC, avg_delivery_time DESC;

--------------in db :
/* Select sd.seller_city AS origin_city,
ud.[user_city] AS destination_city,
COUNT(*) AS total_orders,
AVG(DATEDIFF(day ,pickup_date,delivered_date )) AS avg_delivery_time
FROM userdim as UD
Inner join [dbo].[Order_Fact] AS o
On o.[user_key] = UD.[user_key]
Inner join [dbo].[Seller] as sd
On o.[seller_key] = sd.[seller_key]
inner join [dbo].[DateDim] as d
on o.[pickup_date_key] = d.[DateKey]
WHERE 
    o.delivered_date IS NOT NULL
GROUP BY 
   seller.seller_city,  u.customer_city
ORDER BY 
    total_orders DESC, avg_delivery_time DESC;
*/


--h.How many late delivered order in our ecommerce? Are late order affecting the customer satisfaction?
Select order_id ,del_d.[Date] as delivered_date ,est_d.[Date] as estimated_time_delivery , DATEDIFF(day ,est_d.[Date] 
,del_d.[Date] ) as Days_of_delay ,[feedback_score]
FROM order_fact as o
inner join [dbo].[DateDim] as est_d
on est_d.[DateKey] = o.[estimated_date_delivery_key]
inner join [dbo].[DateDim] as del_d
on del_d.[DateKey] = o.[delivered_date_key]
inner join [dbo].[Feedback] as fd
on fd.feedback_key = o.feedback_key
where o.[delivered_date_key] > o.[estimated_date_delivery_key]
order by Days_of_delay desc , [feedback_score]
	---
	select count(order_id)
	FROM order_fact as o
	where o.[delivered_date_key] > o.[estimated_date_delivery_key]
/* here we calculate the diff of est_d and del_d for each order */

--i.How long are the delay for delivery / shipping process in each state?
/*here we calculate the diff of est_d and del_d for each state (taking the avg of course)*/
 Select UD.user_state as state ,avg( DATEDIFF(day ,pic_d.[Date] 
,del_d.[Date] )) as shipping_process_time
FROM order_fact as o
inner join [dbo].[DateDim] as pic_d
on pic_d.[DateKey] = o.[pickup_date_key]
inner join [dbo].[DateDim] as del_d
on del_d.[DateKey] = o.[delivered_date_key]
inner join [dbo].[UserDim] as UD
on UD.[user_key] = o.[user_key]
where del_d.[Date] > pic_d.[Date] 
group by UD.user_state
order by shipping_process_time desc

--j.How long are the difference between estimated delivery time and actual delivery time in each state?
 Select UD.user_state as state ,avg( DATEDIFF(day ,est_d.[Date] 
,del_d.[Date] )) as avg_long_of_delay
FROM order_fact as o
inner join [dbo].[DateDim] as est_d
on est_d.[DateKey] = o.[estimated_date_delivery_key]
inner join [dbo].[DateDim] as del_d
on del_d.[DateKey] = o.[delivered_date_key]
inner join [dbo].[UserDim] as UD
on UD.[user_key] = o.[user_key]
where del_d.[Date] > est_d.[Date] 
group by UD.user_state
order by avg_long_of_delay desc



