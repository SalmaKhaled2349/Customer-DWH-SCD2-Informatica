-- Read-only checks for the Customer DWH learning project.
-- Execute individual SELECT statements in CDI_Training after verifying schema names.

-- 1. Current row counts across the three layers.
SELECT 'LANDING' AS Layer, COUNT(*) AS Row_Count FROM landing_layer.Customer
UNION ALL
SELECT 'STAGING', COUNT(*) FROM staging_layer.Customers
UNION ALL
SELECT 'DIM', COUNT(*) FROM dwh_layer.Dim_Customers;

-- 2. Every customer should have at most one current STAGING version.
SELECT Customer_ID, COUNT(*) AS Current_Count
FROM staging_layer.Customers
WHERE Is_Current = 1
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

-- 3. Historical versions with inconsistent End_Date / Is_Current flags.
SELECT Stage_SK, Customer_ID, Is_Current, Is_Deleted, Start_Date, End_Date
FROM staging_layer.Customers
WHERE (Is_Current = 1 AND End_Date IS NOT NULL)
   OR (Is_Current = 0 AND End_Date IS NULL);

-- 4. Inspect all versions of one customer after a test.
SELECT Stage_SK, Customer_ID, Customer_Name, City, Start_Date,
       End_Date, Is_Current, Is_Deleted
FROM staging_layer.Customers
WHERE Customer_ID = 'C003'
ORDER BY Stage_SK;

-- 5. Find staging versions missing from the dimension.
SELECT s.Stage_SK, s.Customer_ID
FROM staging_layer.Customers AS s
LEFT JOIN dwh_layer.Dim_Customers AS d
  ON d.Stage_SK = s.Stage_SK
WHERE d.Stage_SK IS NULL;

-- 6. Check current/end-date mismatch after synchronization.
-- EXCEPT treats NULL as equal for set comparisons in SQL Server.
SELECT Stage_SK, Is_Current, End_Date, Is_Deleted
FROM staging_layer.Customers
EXCEPT
SELECT Stage_SK, Is_Current, End_Date, Is_Deleted
FROM dwh_layer.Dim_Customers;

-- 7. Check that one STAGING version does not map to duplicate DIM rows.
SELECT Stage_SK, COUNT(*) AS Dim_Row_Count
FROM dwh_layer.Dim_Customers
GROUP BY Stage_SK
HAVING COUNT(*) > 1;
