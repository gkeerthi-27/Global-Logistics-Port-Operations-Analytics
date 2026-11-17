--creating views--
--vw_Shipment_Overview--

USE logistics_analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Shipment_Overview
AS
SELECT
    s.Shipment_ID,
    s.Shipment_Date,
    s.Shipment_Status,
    s.Expected_Delivery_Date,
    s.Actual_Delivery_Date,
    s.Shipment_Weight,
    s.Delivery_Delay_Days,

    c.Customer_Name,
    c.Customer_Type,
    c.Customer_Location,

    cr.Carrier_Name,
    cr.Carrier_Type,

    ct.Container_Number,
    ct.Container_Type,

    op.Port_Name AS Origin_Port,
    op.Country AS Origin_Country,

    dp.Port_Name AS Destination_Port,
    dp.Country AS Destination_Country

FROM dbo.Shipment_Details s

LEFT JOIN dbo.Customer_Master c
    ON s.Customer_ID = c.Customer_ID

LEFT JOIN dbo.Carrier_Master cr
    ON s.Carrier_ID = cr.Carrier_ID

LEFT JOIN dbo.Container_Master ct
    ON s.Container_ID = ct.Container_ID

LEFT JOIN dbo.Port_Master op
    ON s.Origin_Port_ID = op.Port_ID

LEFT JOIN dbo.Port_Master dp
    ON s.Destination_Port_ID = dp.Port_ID;
GO

SELECT TOP 10 *
FROM dbo.vw_Shipment_Overview;

SELECT COUNT(*) AS Total_Rows
FROM dbo.vw_Shipment_Overview;

--vw_Carrier_Performance--

USE logistics_analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Carrier_Performance
AS
SELECT
    c.Carrier_ID,
    c.Carrier_Name,
    c.Carrier_Type,

    COUNT(s.Shipment_ID) AS Total_Shipments,

    SUM(CASE
        WHEN s.Shipment_Status = 'Delivered'
        THEN 1 ELSE 0
    END) AS Delivered_Shipments,

    SUM(CASE
        WHEN s.Shipment_Status = 'Delivered'
         AND s.Actual_Delivery_Date IS NOT NULL
         AND s.Expected_Delivery_Date IS NOT NULL
         AND s.Actual_Delivery_Date <= s.Expected_Delivery_Date
        THEN 1 ELSE 0
    END) AS On_Time_Shipments,

    SUM(CASE
        WHEN s.Shipment_Status = 'Delivered'
         AND s.Actual_Delivery_Date IS NOT NULL
         AND s.Expected_Delivery_Date IS NOT NULL
         AND s.Actual_Delivery_Date > s.Expected_Delivery_Date
        THEN 1 ELSE 0
    END) AS Late_Delivered_Shipments,

    CAST(
        100.0 * SUM(CASE
            WHEN s.Shipment_Status = 'Delivered'
             AND s.Actual_Delivery_Date IS NOT NULL
             AND s.Expected_Delivery_Date IS NOT NULL
             AND s.Actual_Delivery_Date <= s.Expected_Delivery_Date
            THEN 1 ELSE 0
        END)
        / NULLIF(SUM(CASE
            WHEN s.Shipment_Status = 'Delivered'
             AND s.Actual_Delivery_Date IS NOT NULL
             AND s.Expected_Delivery_Date IS NOT NULL
            THEN 1 ELSE 0
        END), 0)
        AS DECIMAL(5,2)
    ) AS On_Time_Delivery_Percentage,

    CAST(AVG(CASE
        WHEN s.Shipment_Status = 'Delivered'
         AND s.Actual_Delivery_Date > s.Expected_Delivery_Date
        THEN DATEDIFF(
            DAY, s.Expected_Delivery_Date, s.Actual_Delivery_Date
        ) * 1.0
    END) AS DECIMAL(10,2)) AS Average_Delay_Days

FROM dbo.Carrier_Master c
LEFT JOIN dbo.Shipment_Details s
    ON c.Carrier_ID = s.Carrier_ID

GROUP BY
    c.Carrier_ID,
    c.Carrier_Name,
    c.Carrier_Type;
GO

SELECT *
FROM dbo.vw_Carrier_Performance
ORDER BY On_Time_Delivery_Percentage DESC;

---vw_Port_Performance--

USE logistics_analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Port_Performance
AS

SELECT
    p.Port_ID,
    p.Port_Name,
    p.Country,
    p.Port_Type,
    'Origin' AS Port_Role,
    COUNT(s.Shipment_ID) AS Total_Shipments

FROM dbo.Port_Master p
LEFT JOIN dbo.Shipment_Details s
    ON p.Port_ID = s.Origin_Port_ID

GROUP BY
    p.Port_ID,
    p.Port_Name,
    p.Country,
    p.Port_Type

UNION ALL

SELECT
    p.Port_ID,
    p.Port_Name,
    p.Country,
    p.Port_Type,
    'Destination' AS Port_Role,
    COUNT(s.Shipment_ID) AS Total_Shipments

FROM dbo.Port_Master p
LEFT JOIN dbo.Shipment_Details s
    ON p.Port_ID = s.Destination_Port_ID

GROUP BY
    p.Port_ID,
    p.Port_Name,
    p.Country,
    p.Port_Type;
GO

SELECT *
FROM dbo.vw_Port_Performance
ORDER BY Total_Shipments DESC;

--vw_Delivery_Delay_Analysis--

USE logistics_analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Delivery_Delay_Analysis
AS
SELECT
    Shipment_ID,
    Shipment_Date,
    Shipment_Status,
    Expected_Delivery_Date,
    Actual_Delivery_Date,

    CASE
        WHEN Actual_Delivery_Date IS NOT NULL
         AND Expected_Delivery_Date IS NOT NULL
        THEN DATEDIFF(
            DAY,
            Expected_Delivery_Date,
            Actual_Delivery_Date
        )
    END AS Delivery_Delay_Days,

    CASE
        WHEN Shipment_Status = 'Delivered'
         AND Actual_Delivery_Date <= Expected_Delivery_Date
        THEN 'On Time'

        WHEN Shipment_Status = 'Delivered'
         AND Actual_Delivery_Date > Expected_Delivery_Date
        THEN 'Late'

        WHEN Shipment_Status = 'Delayed'
        THEN 'Delayed'

        ELSE 'Not Yet Delivered'
    END AS Delivery_Performance,

    CASE
        WHEN Shipment_Status = 'Delivered'
         AND Shipment_Date IS NOT NULL
         AND Actual_Delivery_Date IS NOT NULL
        THEN DATEDIFF(
            DAY,
            Shipment_Date,
            Actual_Delivery_Date
        )
    END AS Transit_Time_Days

FROM dbo.Shipment_Details;
GO

SELECT TOP 20 *
FROM dbo.vw_Delivery_Delay_Analysis;
----vw_Logistics_Cost_Analysis---

USE logistics_analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Logistics_Cost_Analysis
AS
SELECT
    ca.Cost_ID,
    ca.Shipment_ID,
    s.Shipment_Date,
    s.Shipment_Status,

    c.Carrier_Name,

    p.Country AS Destination_Country,
    p.Port_Name AS Destination_Port,

    ca.Transportation_Cost,
    ca.Warehouse_Cost,
    ca.Customs_Cost,
    ca.Total_Logistics_Cost

FROM dbo.Cost_Analysis ca

LEFT JOIN dbo.Shipment_Details s
    ON ca.Shipment_ID = s.Shipment_ID

LEFT JOIN dbo.Carrier_Master c
    ON s.Carrier_ID = c.Carrier_ID

LEFT JOIN dbo.Port_Master p
    ON s.Destination_Port_ID = p.Port_ID;
GO

SELECT TOP 20 *
FROM dbo.vw_Logistics_Cost_Analysis;

SELECT COUNT(*) AS Total_Rows
FROM dbo.vw_Logistics_Cost_Analysis;



USE logistics_analytics;
GO

SELECT
    name AS View_Name
FROM sys.views
WHERE name IN (
    'vw_Shipment_Overview',
    'vw_Carrier_Performance',
    'vw_Port_Performance',
    'vw_Delivery_Delay_Analysis',x
    'vw_Logistics_Cost_Analysis'
)
ORDER BY name;

