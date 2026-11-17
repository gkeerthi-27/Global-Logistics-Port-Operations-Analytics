--CREATING DATABASE--
IF DB_ID(N'logistics_analytics') IS NULL
BEGIN
    CREATE DATABASE logistics_analytics;
END;
GO

USE logistics_analytics;
GO
--CREATING TABLES--
--CARRIER_MASTER--
IF OBJECT_ID(N'dbo.carrier_master', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[carrier_master]
    (
        [Carrier_ID] varchar(20) NOT NULL PRIMARY KEY,
        [Carrier_Name] varchar(50) NULL,
        [Carrier_Type] varchar(50) NULL,
        [Carrier_Details] varchar(100) NULL,
        [Service_Status] varchar(50) NULL
    );
END;
GO
--CONTAINER MASTER--
IF OBJECT_ID(N'dbo.Container_Master', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Container_Master]
    (
        [Container_ID] varchar(50) NOT NULL PRIMARY KEY,
        [Container_Number] varchar(100) NULL,
        [Container_Type] varchar(50) NULL,
        [Capacity] decimal(12,2) NULL,
        [Container_Status] varchar(50) NULL
    );
END;
GO
-----COST ANALYSIS---
IF OBJECT_ID(N'dbo.Cost_Analysis', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Cost_Analysis]
    (
        [Cost_ID] varchar(50) NOT NULL PRIMARY KEY,
        [Shipment_ID] varchar(50) NULL,
        [Transportation_Cost] decimal(12,2) NULL,
        [Warehouse_Cost] decimal(12,2) NULL,
        [Customs_Cost] decimal(12,2) NULL,
        [Total_Logistics_Cost] decimal(12,2) NULL
    );
END;
GO
---CUSTOMER_MASTER--
IF OBJECT_ID(N'dbo.Customer_Master', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Customer_Master]
    (
        [Customer_ID] varchar(50) NOT NULL PRIMARY KEY,
        [Customer_Name] varchar(100) NULL,
        [Customer_Type] varchar(50) NULL,
        [Customer_Location] varchar(100) NULL,
        [Contact_Details] varchar(100) NULL,
        [Customer_Status] varchar(30) NULL
    );
END;
GO
---CUSTOMS CLEARANCE--
IF OBJECT_ID(N'dbo.Customs_Clearance', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Customs_Clearance]
    (
        [Clearance_ID] varchar(50) NOT NULL PRIMARY KEY,
        [Shipment_ID] varchar(50) NULL,
        [Clearance_Status] varchar(30) NULL,
        [Clearance_Date] date NULL,
        [Customs_Fee] decimal(12,2) NULL,
        [Clearance_Date_Review] varchar(100) NULL
    );
END;
GO
---DELIVERY_TRACKING---
IF OBJECT_ID(N'dbo.Delivery_Tracking', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Delivery_Tracking]
    (
        [Tracking_ID] varchar(50) NOT NULL PRIMARY KEY,
        [Shipment_ID] varchar(50) NULL,
        [Current_Location] varchar(100) NULL,
        [Delivery_Status] varchar(30) NULL,
        [Delivery_Date] date NULL,
        [Date_Review] varchar(100) NULL
    );
END;
GO
-- PORT MASTER--
IF OBJECT_ID(N'dbo.Port_Master', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Port_Master]
    (
        [Port_ID] varchar(20) NOT NULL PRIMARY KEY,
        [Port_Name] varchar(100) NULL,
        [Country] varchar(100) NULL,
        [Port_Type] varchar(50) NULL,
        [Port_Status] varchar(30) NULL
    );
END;
GO
---SHIPMENT_DETAILS--
IF OBJECT_ID(N'dbo.Shipment_Details', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Shipment_Details]
    (
        [Shipment_ID] varchar(50) NOT NULL PRIMARY KEY,
        [Shipment_Date] date NULL,
        [Customer_ID] varchar(50) NULL,
        [Container_ID] varchar(50) NULL,
        [Carrier_ID] varchar(50) NULL,
        [Origin_Port_ID] varchar(20) NULL,
        [Destination_Port_ID] varchar(20) NULL,
        [Vessel_ID] varchar(50) NULL,
        [Shipment_Weight] decimal(12,2) NULL,
        [Shipment_Status] varchar(30) NULL,
        [Expected_Delivery_Date] date NULL,
        [Actual_Delivery_Date] date NULL,
        [Shipment_Status_Review] varchar(100) NULL,
        [Shipment_Weight_Review] varchar(100) NULL,
        [Actual_Delivery_Date_Review] varchar(100) NULL,
        [Delivery_Delay_Days] int NULL
    );
END;
GO
--VESSEL_SCHEDULE--
IF OBJECT_ID(N'dbo.Vessel_Schedule', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Vessel_Schedule]
    (
        [Vessel_ID] varchar(50) NOT NULL,
        [Vessel_Name] varchar(100) NULL,
        [Carrier_ID] varchar(50) NULL,
        [Origin_Port_ID] varchar(20) NULL,
        [Destination_Port_ID] varchar(20) NULL,
        [Departure_Date] date NULL,
        [Arrival_Date] date NULL,
        [Vessel_Status] varchar(30) NULL,
        [Arrival_Date_Review] varchar(100) NULL
    );
END;
GO
--WAREHOUSE MASTER--

IF OBJECT_ID(N'dbo.Warehouse_Master', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[Warehouse_Master]
    (
        [Warehouse_ID] varchar(50) NOT NULL PRIMARY KEY,
        [Warehouse_Name] varchar(100) NULL,
        [Warehouse_Location] varchar(100) NULL,
        [Storage_Capacity] decimal(12,2) NULL,
        [Warehouse_Type] varchar(50) NULL
    );
END;
GO
--DATA VALIDATION--
--SECTION 1: ROW COUNTS FOR ALL TABLES--
SELECT 'Carrier_Master' AS Table_Name, COUNT(*) AS Total_Rows FROM dbo.Carrier_Master
UNION ALL
SELECT 'Container_Master', COUNT(*) FROM dbo.Container_Master
UNION ALL
SELECT 'Cost_Analysis', COUNT(*) FROM dbo.Cost_Analysis
UNION ALL
SELECT 'Customer_Master', COUNT(*) FROM dbo.Customer_Master
UNION ALL
SELECT 'Customs_Clearance', COUNT(*) FROM dbo.Customs_Clearance
UNION ALL
SELECT 'Delivery_Tracking', COUNT(*) FROM dbo.Delivery_Tracking
UNION ALL
SELECT 'Port_Master', COUNT(*) FROM dbo.Port_Master
UNION ALL
SELECT 'Shipment_Details', COUNT(*) FROM dbo.Shipment_Details
UNION ALL
SELECT 'Vessel_Schedule', COUNT(*) FROM dbo.Vessel_Schedule
UNION ALL
SELECT 'Warehouse_Master', COUNT(*) FROM dbo.Warehouse_Master
ORDER BY Table_Name;
GO
--SECTION 2: CHECK DUPLICATE IDENTIFIERS--
SELECT 'Shipment_Details.Shipment_ID' AS Check_Name, COUNT(*) AS Duplicate_Count
FROM (
    SELECT Shipment_ID
    FROM dbo.Shipment_Details
    GROUP BY Shipment_ID
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'Carrier_Master.Carrier_ID', COUNT(*)
FROM (
    SELECT Carrier_ID FROM dbo.Carrier_Master
    GROUP BY Carrier_ID HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'Container_Master.Container_ID', COUNT(*)
FROM (
    SELECT Container_ID FROM dbo.Container_Master
    GROUP BY Container_ID HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'Customer_Master.Customer_ID', COUNT(*)
FROM (
    SELECT Customer_ID FROM dbo.Customer_Master
    GROUP BY Customer_ID HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'Cost_Analysis.Cost_ID', COUNT(*)
FROM (
    SELECT Cost_ID FROM dbo.Cost_Analysis
    GROUP BY Cost_ID HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'Customs_Clearance.Clearance_ID', COUNT(*)
FROM (
    SELECT Clearance_ID FROM dbo.Customs_Clearance
    GROUP BY Clearance_ID HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'Delivery_Tracking.Tracking_ID', COUNT(*)
FROM (
    SELECT Tracking_ID FROM dbo.Delivery_Tracking
    GROUP BY Tracking_ID HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'Port_Master.Port_ID', COUNT(*)
FROM (
    SELECT Port_ID FROM dbo.Port_Master
    GROUP BY Port_ID HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'Warehouse_Master.Warehouse_ID', COUNT(*)
FROM (
    SELECT Warehouse_ID FROM dbo.Warehouse_Master
    GROUP BY Warehouse_ID HAVING COUNT(*) > 1
) AS d;
GO
--  SECTION 3: MISSING VALUES IN IMPORTANT COLUMNS--
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Shipment_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Shipment_ID,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Customer_ID,
    SUM(CASE WHEN Carrier_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Carrier_ID,
    SUM(CASE WHEN Shipment_Status IS NULL THEN 1 ELSE 0 END) AS Missing_Shipment_Status,
    SUM(CASE WHEN Expected_Delivery_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Expected_Delivery_Date,
    SUM(CASE WHEN Actual_Delivery_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Actual_Delivery_Date
FROM dbo.Shipment_Details;
GO

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Clearance_Status IS NULL THEN 1 ELSE 0 END) AS Missing_Clearance_Status,
    SUM(CASE WHEN Clearance_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Clearance_Date,
    SUM(CASE WHEN Customs_Fee IS NULL THEN 1 ELSE 0 END) AS Missing_Customs_Fee
FROM dbo.Customs_Clearance;
GO

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Delivery_Status IS NULL THEN 1 ELSE 0 END) AS Missing_Delivery_Status,
    SUM(CASE WHEN Delivery_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Delivery_Date,
    SUM(CASE WHEN Current_Location IS NULL THEN 1 ELSE 0 END) AS Missing_Current_Location
FROM dbo.Delivery_Tracking;
GO

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Arrival_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Arrival_Date
FROM dbo.Vessel_Schedule;
GO
--   SECTION 4: SHIPMENT RELATIONSHIP CHECKS--
SELECT COUNT(*) AS Shipments_Without_Tracking
FROM dbo.Shipment_Details s
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Delivery_Tracking d
    WHERE d.Shipment_ID = s.Shipment_ID
);
GO

SELECT COUNT(*) AS Shipments_Without_Customs_Record
FROM dbo.Shipment_Details s
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Customs_Clearance cc
    WHERE cc.Shipment_ID = s.Shipment_ID
);
GO

SELECT COUNT(*) AS Tracking_Records_Without_Shipment
FROM dbo.Delivery_Tracking d
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Shipment_Details s
    WHERE s.Shipment_ID = d.Shipment_ID
);
GO

SELECT COUNT(*) AS Customs_Records_Without_Shipment
FROM dbo.Customs_Clearance cc
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Shipment_Details s
    WHERE s.Shipment_ID = cc.Shipment_ID
);
GO
---SECTION 5: SHIPMENT LINKS TO MASTER TABLES--
 SELECT COUNT(*) AS Missing_Customer
FROM dbo.Shipment_Details s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Customer_Master c
    WHERE c.Customer_ID = s.Customer_ID
);
GO

SELECT COUNT(*) AS Missing_Container
FROM dbo.Shipment_Details s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Container_Master ct
    WHERE ct.Container_ID = s.Container_ID
);
GO

SELECT COUNT(*) AS Missing_Carrier
FROM dbo.Shipment_Details s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Carrier_Master c
    WHERE c.Carrier_ID = s.Carrier_ID
);
GO

SELECT COUNT(*) AS Missing_Vessel
FROM dbo.Shipment_Details s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Vessel_Schedule v
    WHERE v.Vessel_ID = s.Vessel_ID
);
GO
-- SECTION 6: PORT ID VALIDATION--
SELECT 'Origin' AS Port_Role, s.Origin_Port_ID AS Port_ID, COUNT(*) AS Record_Count
FROM dbo.Shipment_Details s
WHERE s.Origin_Port_ID IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.Port_Master p
      WHERE p.Port_ID = s.Origin_Port_ID
  )
GROUP BY s.Origin_Port_ID

UNION ALL

SELECT 'Destination', s.Destination_Port_ID, COUNT(*)
FROM dbo.Shipment_Details s
WHERE s.Destination_Port_ID IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.Port_Master p
      WHERE p.Port_ID = s.Destination_Port_ID
  )
GROUP BY s.Destination_Port_ID
ORDER BY Port_Role, Record_Count DESC;
GO

--SECTION 7: COST DATA VALIDATION---
SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE
        WHEN Transportation_Cost IS NULL
          OR Warehouse_Cost IS NULL
          OR Customs_Cost IS NULL
          OR Total_Logistics_Cost IS NULL
        THEN 1 ELSE 0
    END) AS Records_With_Missing_Costs,
    SUM(CASE
        WHEN Transportation_Cost IS NOT NULL
         AND Warehouse_Cost IS NOT NULL
         AND Customs_Cost IS NOT NULL
         AND Total_Logistics_Cost IS NOT NULL
         AND ABS(
             Total_Logistics_Cost -
             (Transportation_Cost + Warehouse_Cost + Customs_Cost)
         ) > 0.01
        THEN 1 ELSE 0
    END) AS Cost_Mismatches
FROM dbo.Cost_Analysis;
GO
--SECTION 8: CUSTOMS CLEARANCE DATE REVIEW--
SELECT
    Clearance_Status,
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN Clearance_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Clearance_Dates
FROM dbo.Customs_Clearance
GROUP BY Clearance_Status
ORDER BY Clearance_Status;
GO

SELECT
    Clearance_ID,
    Shipment_ID,
    Clearance_Status,
    Clearance_Date,
    Customs_Fee,
    Clearance_Date_Review
FROM dbo.Customs_Clearance
WHERE Clearance_Status = 'Cleared'
  AND Clearance_Date IS NULL;
GO
---SECTION 9: DELIVERY TRACKING DATE REVIEW--
SELECT
    Delivery_Status,
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN Delivery_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Delivery_Dates
FROM dbo.Delivery_Tracking
GROUP BY Delivery_Status
ORDER BY Delivery_Status;
GO

SELECT
    s.Shipment_ID,
    s.Shipment_Status,
    s.Actual_Delivery_Date,
    d.Delivery_Status,
    d.Delivery_Date,
    CASE
        WHEN s.Shipment_Status = 'Delivered'
         AND d.Delivery_Status IS NOT NULL
         AND d.Delivery_Status <> 'Delivered'
            THEN 'Review - Status Mismatch'
        WHEN s.Actual_Delivery_Date IS NOT NULL
         AND d.Delivery_Date IS NOT NULL
         AND d.Delivery_Date > s.Actual_Delivery_Date
            THEN 'Review - Tracking Date After Actual Date'
        ELSE 'No Issue Detected'
    END AS Data_Quality_Flag
FROM dbo.Shipment_Details s
INNER JOIN dbo.Delivery_Tracking d
    ON s.Shipment_ID = d.Shipment_ID
WHERE (
        s.Shipment_Status = 'Delivered'
        AND d.Delivery_Status IS NOT NULL
        AND d.Delivery_Status <> 'Delivered'
      )
   OR (
        s.Actual_Delivery_Date IS NOT NULL
        AND d.Delivery_Date IS NOT NULL
        AND d.Delivery_Date > s.Actual_Delivery_Date
      )
ORDER BY s.Shipment_ID;
GO
--BUSINESS KPI'S----
---SECTION 10: KPI 1 - ON-TIME DELIVERY RATE---
SELECT
    COUNT(*) AS Total_Delivered_Shipments,
    SUM(CASE
        WHEN Actual_Delivery_Date <= Expected_Delivery_Date
        THEN 1 ELSE 0
    END) AS On_Time_Shipments,
    SUM(CASE
        WHEN Actual_Delivery_Date > Expected_Delivery_Date
        THEN 1 ELSE 0
    END) AS Delayed_Shipments,
    CAST(
        100.0 * SUM(CASE
            WHEN Actual_Delivery_Date <= Expected_Delivery_Date
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS On_Time_Delivery_Rate_Percent
FROM dbo.Shipment_Details
WHERE Shipment_Status = 'Delivered'
  AND Actual_Delivery_Date IS NOT NULL
  AND Expected_Delivery_Date IS NOT NULL;
GO
-- SECTION 11: KPI 2 - AVERAGE AND MAXIMUM DELIVERY DELAY--
SELECT
    COUNT(*) AS Total_Delayed_Shipments,
    CAST(AVG(
        DATEDIFF(DAY, Expected_Delivery_Date, Actual_Delivery_Date) * 1.0
    ) AS DECIMAL(10,2)) AS Average_Delay_Days,
    MAX(
        DATEDIFF(DAY, Expected_Delivery_Date, Actual_Delivery_Date)
    ) AS Maximum_Delay_Days
FROM dbo.Shipment_Details
WHERE Shipment_Status = 'Delivered'
  AND Actual_Delivery_Date IS NOT NULL
  AND Expected_Delivery_Date IS NOT NULL
  AND Actual_Delivery_Date > Expected_Delivery_Date;
GO
---SECTION 12: CARRIER ON-TIME DELIVERY PERFORMANCE--
SELECT
    c.Carrier_ID,
    c.Carrier_Name,
    COUNT(*) AS Total_Delivered_Shipments,
    SUM(CASE
        WHEN s.Actual_Delivery_Date <= s.Expected_Delivery_Date
        THEN 1 ELSE 0
    END) AS On_Time_Shipments,
    SUM(CASE
        WHEN s.Actual_Delivery_Date > s.Expected_Delivery_Date
        THEN 1 ELSE 0
    END) AS Delayed_Shipments,
    CAST(
        100.0 * SUM(CASE
            WHEN s.Actual_Delivery_Date <= s.Expected_Delivery_Date
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS On_Time_Rate_Percent
FROM dbo.Shipment_Details s
INNER JOIN dbo.Carrier_Master c
    ON s.Carrier_ID = c.Carrier_ID
WHERE s.Shipment_Status = 'Delivered'
  AND s.Actual_Delivery_Date IS NOT NULL
  AND s.Expected_Delivery_Date IS NOT NULL
GROUP BY c.Carrier_ID, c.Carrier_Name
ORDER BY On_Time_Rate_Percent DESC;
GO
--SECTION 13: CARRIER AVERAGE AND MAXIMUM DELIVERY DELAY--
SELECT
    c.Carrier_ID,
    c.Carrier_Name,
    COUNT(*) AS Delayed_Shipments,
    CAST(AVG(
        DATEDIFF(DAY, s.Expected_Delivery_Date, s.Actual_Delivery_Date) * 1.0
    ) AS DECIMAL(10,2)) AS Average_Delay_Days,
    MAX(
        DATEDIFF(DAY, s.Expected_Delivery_Date, s.Actual_Delivery_Date)
    ) AS Maximum_Delay_Days
FROM dbo.Shipment_Details s
INNER JOIN dbo.Carrier_Master c
    ON s.Carrier_ID = c.Carrier_ID
WHERE s.Shipment_Status = 'Delivered'
  AND s.Actual_Delivery_Date IS NOT NULL
  AND s.Expected_Delivery_Date IS NOT NULL
  AND s.Actual_Delivery_Date > s.Expected_Delivery_Date
GROUP BY c.Carrier_ID, c.Carrier_Name
ORDER BY Average_Delay_Days DESC;
GO
--SECTION 14: TOTAL LOGISTICS COST BY CARRIER--
SELECT
    c.Carrier_ID,
    c.Carrier_Name,
    COUNT(DISTINCT s.Shipment_ID) AS Total_Shipments,
    SUM(ca.Transportation_Cost) AS Total_Transportation_Cost,
    SUM(ca.Warehouse_Cost) AS Total_Warehouse_Cost,
    SUM(ca.Customs_Cost) AS Total_Customs_Cost,
    SUM(ca.Total_Logistics_Cost) AS Total_Logistics_Cost
FROM dbo.Shipment_Details s
INNER JOIN dbo.Carrier_Master c
    ON s.Carrier_ID = c.Carrier_ID
INNER JOIN dbo.Cost_Analysis ca
    ON s.Shipment_ID = ca.Shipment_ID
GROUP BY c.Carrier_ID, c.Carrier_Name
ORDER BY Total_Logistics_Cost DESC;
GO
--SECTION 15: AVERAGE LOGISTICS COST PER SHIPMENT BY CARRIER--
SELECT
    c.Carrier_ID,
    c.Carrier_Name,
    COUNT(*) AS Total_Shipments,
    SUM(ca.Total_Logistics_Cost) AS Total_Logistics_Cost,
    CAST(AVG(ca.Total_Logistics_Cost) AS DECIMAL(15,2))
        AS Average_Cost_Per_Shipment
FROM dbo.Shipment_Details s
INNER JOIN dbo.Carrier_Master c
    ON s.Carrier_ID = c.Carrier_ID
INNER JOIN dbo.Cost_Analysis ca
    ON s.Shipment_ID = ca.Shipment_ID
GROUP BY c.Carrier_ID, c.Carrier_Name
ORDER BY Average_Cost_Per_Shipment DESC;
GO
--SECTION 16: COST COMPONENT BREAKDOWN--
SELECT 'Transportations' AS COST_COMPONENT,
SUM(Transportation_Cost)as Total_Cost
FROM dbo.cost_analysis

UNION ALL 

SELECT 'Warehouse',
SUM(Warehouse_Cost)
FROM dbo.cost_analysis

UNION ALL 

SELECT 'Customs',
SUM(Customs_Cost)
FROM dbo.cost_analysis
ORDER BY Total_Cost desc;
GO
--SECTION 17:Shipment volume by port--
SELECT P.PORT_ID,
P.PORT_NAME,
P.COUNTRY,
COUNT(*) AS TOTAL_ORGIN_SHIPMENTS
FROM dbo.Shipment_Details as S 
INNER JOIN 
dbo.Port_Master as P
ON S.Origin_Port_ID = P.Port_ID
GROUP BY Port_ID,
Port_Name,
P.Country
ORDER BY TOTAL_ORGIN_SHIPMENTS DESC;
--SECTION 18 : the busiest destination ports--
SELECT P.PORT_ID,
P.PORT_NAME,
P.COUNTRY,
COUNT(*) AS TOTAL_DESTINATION_SHIPMENTS
FROM dbo.Shipment_Details as S 
INNER JOIN 
dbo.Port_Master as P
ON S.Destination_Port_ID = P.Port_ID
GROUP BY P.Port_ID,
P.Port_Name,
P.Country
ORDER BY TOTAL_DESTINATION_SHIPMENTS DESC;
--SECTION 19 : Analyze shipment status--
SELECT SHIPMENT_STATUS,
COUNT(*) AS TOTAL_SHIPMENTS
FROM dbo.Shipment_Details
GROUP BY Shipment_Status
ORDER BY TOTAL_SHIPMENTS DESC;
--SECTION 20 :Analyze shipment status by carrier--
SELECT C.Carrier_Name,
S.SHIPMENT_STATUS,
COUNT(*) AS TOTAL_SHIPMENTS
FROM dbo.Shipment_Details S
INNER JOIN dbo.carrier_master C
ON S.Carrier_ID = C.Carrier_ID
GROUP BY C.Carrier_Name,
S.Shipment_Status
ORDER BY C.CARRIER_NAME,TOTAL_SHIPMENTS DESC;
--SECTION 21: Calculate the delay rate for each carrier--
SELECT
    C.Carrier_Name,
    COUNT(*) AS Total_Shipments,
    SUM(CASE
        WHEN S.Shipment_Status = 'Delayed' THEN 1
        ELSE 0
    END) AS Delayed_Shipments,
    CAST(
        100.0 * SUM(CASE
            WHEN S.Shipment_Status = 'Delayed' THEN 1
            ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS Delay_Rate_Percent
FROM dbo.Shipment_Details AS S
INNER JOIN dbo.Carrier_Master AS C
    ON S.Carrier_ID = C.Carrier_ID
GROUP BY C.Carrier_Name
ORDER BY Delay_Rate_Percent DESC;
--SECTION 22:Analyze logistics cost by destination country--
SELECT P.COUNTRY as destination_port_country,
COUNT(DISTINCT S.SHIPMENT_ID) AS TOTAL_SHIPMENTS,
SUM(CA.TRANSPORTATION_COST) AS TOTAL_TRANSPORTATION_COST,
SUM(CA.WAREHOUSE_COST)AS TOTAL_WAREHOUSE_COST,
SUM(CA.CUSTOMS_COST)AS TOTAL_CUSTOMS_COST,
SUM(CA.Total_Logistics_Cost)AS TOTAL_LOGISTIC_COST
FROM dbo.shipment_details as s
inner join 
dbo.port_master as p 
on s.destination_port_id = p.port_id 
inner join 
dbo.cost_analysis as ca 
on s.shipment_id = ca.shipment_id 
group by p.country
order by total_logistic_cost desc;
--SECTION 23:Calculate average logistics cost per shipment by country--
SELECT P.COUNTRY,
COUNT(DISTINCT S.SHIPMENT_ID) AS TOTAL_SHIPMENTS,
CAST(
SUM(CA.Total_Logistics_Cost)*1.0/NULLIF(count(distinct S.SHIPMENT_ID),0) 
AS DECIMAL(18,2)) AS Avg_cost_per_shipment
FROM dbo.shipment_details as s 
INNER JOIN 
dbo.port_master as p
on s.Destination_Port_ID = p.Port_ID
INNER JOIN 
dbo.Cost_Analysis as ca 
on s.Shipment_ID = ca.Shipment_ID
group by p.Country
order by Avg_cost_per_shipment desc;
--SECTION 24: Analyze shipment weight by carrier--
SELECT C.CARRIER_NAME,
COUNT(S.SHIPMENT_ID) AS TOTAL_SHIPMENTS,
CAST(AVG
(CAST(S.SHIPMENT_WEIGHT AS DECIMAL(18,2)))
AS DECIMAL(18,2)) AS AVG_SHIPMENT_WEIGHT,
MAX(S.SHIPMENT_WEIGHT) AS MAX_SHIPMENT_WEIGHT 
FROM dbo.shipment_details as s
inner join 
dbo.carrier_master as c 
on s.carrier_id = c.carrier_id
where s.shipment_weight is not null 
group by c.carrier_name
order by avg_shipment_weight desc;
--SECTION 24:Analyze monthly shipment trends--
SELECT 
YEAR(SHIPMENT_DATE)AS SHIPMENT_YEAR,
MONTH(SHIPMENT_DATE)AS SHIPMENT_MONTH,
COUNT(*) AS TOTAL_SHIPMENTS
FROM dbo.Shipment_Details 
WHERE Shipment_Date IS NOT NULL 
GROUP BY YEAR(SHIPMENT_DATE),
MONTH(SHIPMENT_DATE)
ORDER BY SHIPMENT_YEAR,
SHIPMENT_MONTH
--SECTION 26:COMPARE SHIPMENT VOLUME BY YEAR--
SELECT
    YEAR(Shipment_Date) AS Shipment_Year,
    COUNT(*) AS Total_Shipments,
    COUNT(DISTINCT MONTH(Shipment_Date)) AS Months_With_Data,
    CAST(
        COUNT(*) * 1.0 /
        COUNT(DISTINCT MONTH(Shipment_Date))
        AS DECIMAL(10,2)
    ) AS Average_Shipments_Per_Month
FROM dbo.Shipment_Details
WHERE Shipment_Date IS NOT NULL
GROUP BY YEAR(Shipment_Date)
ORDER BY Shipment_Year;
---SECTION 27 : FINDING THE BUSISET SHIPMENT ROUTES--
SELECT OP.PORT_NAME AS ORGIN_PORT,
DP.PORT_NAME AS DESTINATION_PORT,
COUNT(*) AS TOTAL_SHIPMENTS 
FROM dbo.Shipment_Details as s 
INNER JOIN 
dbo.Port_Master as op 
on s.Origin_Port_ID = op.Port_ID
INNER JOIN dbo.Port_Master as dp
on s.Destination_Port_ID = dp.Port_ID
group by 
op.port_name,
dp.port_name
order by TOTAL_SHIPMENTS desc;
--SECTION 28 : Customer-wise shipment and cost analysis--
SELECT
    C.Customer_ID,
    C.Customer_Name,
    COUNT(DISTINCT S.Shipment_ID) AS Total_Shipments,
    SUM(CA.Total_Logistics_Cost) AS Total_Logistics_Cost,
    CAST(
        SUM(CA.Total_Logistics_Cost) * 1.0
        / NULLIF(COUNT(DISTINCT S.Shipment_ID), 0)
        AS DECIMAL(18,2)
    ) AS Average_Cost_Per_Shipment
FROM dbo.Shipment_Details AS S
INNER JOIN dbo.Customer_Master AS C
    ON S.Customer_ID = C.Customer_ID
INNER JOIN dbo.Cost_Analysis AS CA
    ON S.Shipment_ID = CA.Shipment_ID
GROUP BY
    C.Customer_ID,
    C.Customer_Name
ORDER BY Total_Shipments DESC;
---SECTION 29:Customs clearance performance--
SELECT
    Clearance_Status,
    COUNT(*) AS Total_Records,
    SUM(
        CASE
            WHEN Clearance_Date IS NULL THEN 1
            ELSE 0
        END
    ) AS Missing_Clearance_Dates
FROM dbo.Customs_Clearance
GROUP BY Clearance_Status
ORDER BY Total_Records DESC;
--SECTION 30 : Delivery tracking performance--
SELECT
    Delivery_Status,
    COUNT(*) AS Total_Tracking_Records,
    SUM(
        CASE
            WHEN Delivery_Date IS NULL THEN 1
            ELSE 0
        END
    ) AS Missing_Delivery_Dates
FROM dbo.Delivery_Tracking
GROUP BY Delivery_Status
ORDER BY Total_Tracking_Records DESC;
--SECTION 31:Warehouse capacity--
SELECT TOP 10 *
FROM dbo.Warehouse_Master;
SELECT
    Warehouse_ID,
    Warehouse_Name,
    Warehouse_Location,
    Warehouse_Type,
    Storage_Capacity
FROM dbo.Warehouse_Master
ORDER BY Storage_Capacity DESC;
--Compare warehouse types--
SELECT
    Warehouse_Type,
    COUNT(*) AS Total_Warehouses,
    SUM(Storage_Capacity) AS Total_Storage_Capacity,
    AVG(Storage_Capacity) AS Average_Storage_Capacity,
    MAX(Storage_Capacity) AS Maximum_Storage_Capacity
FROM dbo.Warehouse_Master
GROUP BY Warehouse_Type
ORDER BY Total_Storage_Capacity DESC;
---SECTION 32:Overall Shipment Delay Percentage--
SELECT
    COUNT(*) AS Total_Shipments,
    SUM(
        CASE
            WHEN Shipment_Status = 'Delayed' THEN 1
            ELSE 0
        END
    ) AS Delayed_Shipments,
    CAST(
        100.0 * SUM(
            CASE
                WHEN Shipment_Status = 'Delayed' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS Shipment_Delay_Percentage
FROM dbo.Shipment_Details
WHERE Shipment_Status IS NOT NULL;
-- Section 33: Average Transit Time

SELECT
    COUNT(*) AS Delivered_Shipments,
    CAST(
        AVG(
            CAST(
                DATEDIFF(
                    DAY,
                    Shipment_Date,
                    Actual_Delivery_Date
                ) AS DECIMAL(10,2)
            )
        ) AS DECIMAL(10,2)
    ) AS Average_Transit_Time_Days
FROM dbo.Shipment_Details
WHERE Shipment_Status = 'Delivered'
  AND Shipment_Date IS NOT NULL
  AND Actual_Delivery_Date IS NOT NULL;
-- Section 34: Transportation Cost per Shipment

SELECT
    COUNT(*) AS Total_Shipments,
    CAST(
        SUM(Transportation_Cost) AS DECIMAL(18,2)
    ) AS Total_Transportation_Cost,
    CAST(
        AVG(Transportation_Cost) AS DECIMAL(18,2)
    ) AS Average_Transportation_Cost_Per_Shipment
FROM dbo.Cost_Analysis
WHERE Transportation_Cost IS NOT NULL;


