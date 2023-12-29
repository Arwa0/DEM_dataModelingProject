
CREATE TABLE dbo.[UserDim]
(
    user_key int identity(1,1) ,
    user_name varchar(50),
    user_zip_code int,
    user_city varchar(50),
    user_state varchar(50),
    PRIMARY KEY (user_key)
);

CREATE TABLE  dbo.PaymentDim
(
    payment_key int identity(1,1) ,
    payment_sequential int,
    payment_type varchar(50),
    payment_installments int,
    payment_value real,
    PRIMARY KEY (payment_key)
);


CREATE TABLE  dbo.[Seller]
(
    seller_key int identity(1,1),
    seller_id varchar(100),
    sellet_zip_code int,
    seller_city varchar(50),
    seller_state varchar(80),
    PRIMARY KEY (seller_key)
);

CREATE TABLE dbo.[Feedback]
(
    feedback_key int identity(1,1) ,
    feedback_id varchar(100),
    feedback_score int,
    PRIMARY KEY (feedback_key)
);


CREATE TABLE Order_Fact (
    user_key int,
    seller_key int,
    payment_key int,
    feedback_key int,
	order_id varchar(100),
    order_date_key int,
	order_time int ,
    order_approved_date_key int,
    pickup_date_key int,
	pickup_time int ,
    pickup_limit_date_key int,
	pickup_limit_time int,
    delivered_date_key int,
	delivered_time int ,
    estimated_date_delivery_key int,
    total_price real,
);

------
ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_date_key FOREIGN KEY (order_date_key)
    REFERENCES [dbo].[DateDim]([DateKey]);

ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_order_time FOREIGN KEY (order_time)
    REFERENCES [dbo].[TimeDim]([TimeKey]);

ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_order_approved_date FOREIGN KEY (order_approved_date_key)
    REFERENCES [dbo].[DateDim]([DateKey]);

ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_order_pickup_date FOREIGN KEY (pickup_date_key)
    REFERENCES [dbo].[DateDim]([DateKey]);
	
ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_order_pickup_time FOREIGN KEY (pickup_time)
    REFERENCES  [dbo].[TimeDim]([TimeKey]);

ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_pickup_limit_date_key FOREIGN KEY (pickup_limit_date_key)
    REFERENCES [dbo].[DateDim]([DateKey]);


ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_pickup_limit_time FOREIGN KEY (pickup_limit_time)
    REFERENCES [dbo].[TimeDim]([TimeKey]);

ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_delivered_date_key FOREIGN KEY (delivered_date_key)
    REFERENCES [dbo].[DateDim]([DateKey]);

ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_delivered_time FOREIGN KEY (delivered_time)
    REFERENCES [dbo].[TimeDim]([TimeKey]);

ALTER TABLE dbo.Order_Fact
    ADD CONSTRAINT fk_estimated_date_delivery_key FOREIGN KEY (estimated_date_delivery_key)
    REFERENCES [dbo].[DateDim]([DateKey]);

ALTER TABLE Order_Fact
ADD CONSTRAINT FK_Users_UserKey FOREIGN KEY (user_key) REFERENCES [dbo].[UserDim](user_key);

ALTER TABLE Order_Fact
ADD CONSTRAINT FK_PaymentDim_PaymentKey FOREIGN KEY (payment_key) REFERENCES PaymentDim(payment_key);

ALTER TABLE Order_Fact
ADD CONSTRAINT FK_Seller_SellerKey FOREIGN KEY (seller_key) REFERENCES Seller(seller_key);

ALTER TABLE Order_Fact
ADD CONSTRAINT FK_Feedback_FeedbackKey FOREIGN KEY (feedback_key) REFERENCES Feedback(feedback_key);



/*************************************************************************************/
-- Create the table
CREATE TABLE DateDim (
    DateKey INT PRIMARY KEY,
    [Date] DATE,
    DayOfWeek NVARCHAR(20),
    DayOfMonth INT,
    [Month] NVARCHAR(20), -- Changed column name from Month to [Month]
    Quarter NVARCHAR(5),
    [Year] INT,
    Season NVARCHAR(20)
);

-- Populate the table with sample data
DECLARE @StartDate DATE = '2016-09-04'; 
DECLARE @EndDate DATE = '2020-04-09';  
DECLARE @Date DATE = @StartDate;

WHILE @Date <= @EndDate
BEGIN
    INSERT INTO DateDim (DateKey, [Date], DayOfWeek, DayOfMonth, [Month], Quarter, [Year], Season)
    VALUES (
        YEAR(@Date) * 10000 + MONTH(@Date) * 100 + DAY(@Date), -- DateKey
        @Date, -- [Date]
        DATENAME(WEEKDAY, @Date), -- DayOfWeek
        DAY(@Date), -- DayOfMonth
        DATENAME(MONTH, @Date), -- [Month]
        'Q' + DATENAME(QUARTER, @Date), -- Quarter
        YEAR(@Date), -- Year
        CASE
            WHEN MONTH(@Date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(@Date) >= 3 AND MONTH(@Date) <= 5 THEN 'Spring'
            WHEN MONTH(@Date) >= 6 AND MONTH(@Date) <= 8 THEN 'Summer'
            ELSE 'Fall'
        END -- Season
    );

    SET @Date = DATEADD(DAY, 1, @Date);
END;

-- Create the TimeDim table
CREATE TABLE TimeDim (
    TimeKey INT PRIMARY KEY IDENTITY(1,1),
    TimeOfDay NVARCHAR(25), -- Adjust the size as needed
    [Hour] NVARCHAR(2),
    Minute NVARCHAR(2),
    TimeFormatted NVARCHAR(4)
);


-- Generate and insert times for each minute of the day
DECLARE @TimeHour INT = 0;
DECLARE @TimeMinute INT = 1;
DECLARE @TimeOfDay NVARCHAR(25);

WHILE @TimeHour < 24
BEGIN
    WHILE @TimeMinute < 60
    BEGIN
        IF @TimeHour < 12
            SET @TimeOfDay = 'Morning';
        ELSE IF @TimeHour < 17
            SET @TimeOfDay = 'Afternoon';
        ELSE IF @TimeHour < 20
            SET @TimeOfDay = 'Evening';
        ELSE
            SET @TimeOfDay = 'Night';

        INSERT INTO TimeDim (TimeOfDay, [Hour], Minute, TimeFormatted)
        VALUES (
            @TimeOfDay,
            FORMAT(@TimeHour, '00'),
            FORMAT(@TimeMinute, '00'),
            FORMAT(@TimeHour, '00') + FORMAT(@TimeMinute, '00')
        );
        
        SET @TimeMinute = @TimeMinute + 1;
    END
    
    SET @TimeMinute = 0;
    SET @TimeHour = @TimeHour + 1;
END


/******************************************************************************************************************************************************/
use [db_DEM_DataModeling]

select o.order_id ,seller_id,pickup_limit_date , seller_id,user_name,order_date
,order_approved_date ,pickup_date , delivered_date,estimated_time_delivery ,[feedback_id] , payment_value
from [db_DEM_DataModeling].[dbo].[order_item] as oi
inner join  [db_DEM_DataModeling].[dbo].[order] as o
on o.order_id = oi.order_id
inner join [db_DEM_DataModeling].[dbo].[payment] as p
on p.order_id = oi.order_id
inner join [db_DEM_DataModeling].[dbo].Feedback as f
on f.[order_id] = o.order_id

--------------------------------------------------

