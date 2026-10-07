-- Customer Churn Analysis
-- Database: MariaDB

USE customer_churn;

SELECT DATABASE();

-- Create table to import dataset
CREATE TABLE churn_data (
	customerID VARCHAR(20),
	gender VARCHAR(10),
	SeniorCitizen INT,
	Partner VARCHAR(20),
	Dependents VARCHAR(20),
	Tenure INT,
	PhoneService VARCHAR(20),
	MultipleLines VARCHAR(20),
	InternetService VARCHAR(20),
	OnlineSecurity VARCHAR(20),
	OnlineBackup VARCHAR(20),
	DeviceProtection VARCHAR(20),
	TechSupport VARCHAR(20),
	StreamingTV VARCHAR(20),
	StreamingMovies VARCHAR(20),
	Contract VARCHAR(20),
	PaperlessBilling VARCHAR(20),
	PaymentMethod VARCHAR(20),
	MonthlyCharges DECIMAL(10,2),
	TotalCharges VARCHAR(20), --DECIMAL(10,2), -- 
	Churn VARCHAR(10)
	);

-- Import the CSV
-- Update this path to the local location of the dataset.
LOAD DATA LOCAL INFILE
	'path/Telco_Customer_Churn.csv'
	INTO TABLE churn_data
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;

-- Check imported data
SELECT * 
  FROM churn_data 
  LIMIT 10;

DESCRIBE churn_data;

-- Check for blank TotalCharges values
SELECT COUNT(*) AS blank_total_charges
FROM churn_data
WHERE TRIM(TotalCharges) = '';

-- Blank to NULL
UPDATE churn_data
SET TotalCharges = NULL
WHERE TRIM(TotalCharges) = '';

-- Convert the datatype
ALTER TABLE churn_data
MODIFY TotalCharges DECIMAL(10,2);

-- Verify:
DESCRIBE churn_data;

SELECT MIN(TotalCharges), MAX(TotalCharges), AVG(TotalCharges)
  FROM churn_data
  GROUP BY Churn;

-- Count customers
SELECT COUNT(*) AS total_customers
  FROM churn_data;

-- Check churn distribution
SELECT Churn,
       COUNT(*) AS customers
  FROM churn_data
  GROUP BY Churn;

-- Q1: Does churn rate differ by contract type?
SELECT Contract,
       COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
	     ROUND(100*SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END)/COUNT(*), 2) AS churn_rate
  FROM churn_data
  GROUP BY Contract;

-- Q2: Does churn rate differ by tenure?
SELECT tenure,
       COUNT(*) AS total_customers,
	     SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
	     ROUND(100*SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END)/COUNT(*), 2) AS churn_rate
  FROM churn_data
  GROUP BY tenure;

-- Q3: Does churn rate differ by tenure bin? 
SELECT 
   CASE
	  WHEN tenure <= 12 THEN '0-12 months'
	  WHEN tenure <= 24 THEN '13-24 months'
	  WHEN tenure <= 48 THEN '25-48 months'
	  ELSE '49+ months' END AS tenure_group,
	  COUNT(*) AS customers,
	  SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
	  ROUND(100*(SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END))/COUNT(*),2) AS churn_rate
  FROM churn_data
  GROUP BY tenure_group
  ORDER BY churn_rate DESC; --ORDER BY tenure_group;

-- Q4: Does churn differ by average monthly charges?
SELECT Churn,
       AVG(MonthlyCharges),
       MIN(MonthlyCharges),
       MAX(MonthlyCharges)
 FROM churn_data
 GROUP BY Churn;

-- Q5: Does churn differ across monthly-charge segments?
 SELECT 
    CASE
       WHEN MonthlyCharges <= 30 THEN '0-30'
	     WHEN MonthlyCharges <=60 THEN '31-60'
	     WHEN MonthlyCharges <=90 THEN '61-90'
	     WHEN MonthlyCharges <=120 THEN '91-120'
	     ELSE '120+' END AS MonthlyCharges_group,
       COUNT(*) AS customers,
	  SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
	  ROUND(100*(SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END))/COUNT(*),2) AS churn_rate
  FROM churn_data
  GROUP BY MonthlyCharges_group
  ORDER BY churn_rate DESC;

-- Q6: Does churn rate differ by payment methods?
SELECT PaymentMethod,
       COUNT(*) AS customers,
       SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customer,
	   ROUND(100*SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
  FROM churn_data
  GROUP BY PaymentMethod
  ORDER BY churn_rate DESC;

-- Q7: Does churn differ across total-charge segments?
SELECT 
    CASE
       WHEN TotalCharges IS NULL THEN 'Unknown'
       WHEN TotalCharges <= 2000 THEN '0-2000'
	     WHEN TotalCharges <= 4000 THEN '2001-4000'
	     WHEN TotalCharges <= 6000 THEN '4001-6000'
	     WHEN TotalCharges <= 8000 THEN '6001-8000'
	     ELSE '8000+' END AS TotalCharges_group,
       COUNT(*) AS customers,
	  SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
	  ROUND(100*(SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END))/COUNT(*),2) AS churn_rate
  FROM churn_data
  GROUP BY TotalCharges_group
  ORDER BY churn_rate DESC;

-- Q8: Does churn rate differ by internet service?
SELECT InternetService,
       COUNT(*) AS customers,
	     SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
	     ROUND(100*(SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END))/COUNT(*),2) AS churn_rate
  FROM churn_data
  GROUP BY InternetService
  ORDER BY churn_rate DESC;


-- Q9: Which combinations of contract type, payment method, 
-- and internet service have the highest churn rates?
SELECT Contract,
       PaymentMethod,
       InternetService,
       COUNT(*) AS customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
       ROUND(100*SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate
FROM churn_data
GROUP BY Contract, PaymentMethod, InternetService
HAVING COUNT(*) >= 20
ORDER BY churn_rate DESC;

-- 
-- Q10: Rank customer segments by churn rate
WITH segment_churn AS (
    SELECT Contract,
           PaymentMethod,
           InternetService,
           COUNT(*) AS customers,
           ROUND(100* AVG(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),2) AS churn_rate
    FROM churn_data
    GROUP BY Contract, PaymentMethod, InternetService
    HAVING COUNT(*) >= 20
)

SELECT *,
       RANK() OVER (ORDER BY churn_rate DESC) AS churn_risk_rank
FROM segment_churn
ORDER BY churn_risk_rank
LIMIT 10;


----
-- Month-to-month customers showed substantially higher churn than 
-- customers on longer-term contracts.

-- Churn was concentrated among customers with shorter tenure.