CREATE DATABASE CREDIT_CARD_ANALYSIS;
USE CREDIT_CARD_ANALYSIS;


 DROP TABLE IF EXISTS credit_card;

DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
    client_num BIGINT PRIMARY KEY,
    customer_age INT,
    gender CHAR(1),
    dependent_count INT,
    education_level VARCHAR(50),
    marital_status VARCHAR(20),
    state_cd CHAR(2),
    zipcode INT,
    car_owner VARCHAR(3),
    house_owner VARCHAR(3),
    personal_loan VARCHAR(3),
    contact VARCHAR(20),
    customer_job VARCHAR(50),
    income BIGINT,
    cust_satisfaction_score INT
);

DROP TABLE IF EXISTS cc_detail;
DROP TABLE IF EXISTS credit_card;


CREATE TABLE credit_card (
    Client_Num INT,
    Card_Category VARCHAR(20),
    Annual_Fees INT,
    Activation_30_Days INT,
    Customer_Acq_Cost INT,
    Week_Start_Date DATE,
    Week_Num VARCHAR(20),
    Qtr VARCHAR(10),
    current_year INT,
    Credit_Limit DECIMAL(10,2),
    Total_Revolving_Bal INT,
    Total_Trans_Amt INT,
    Total_Trans_Ct INT,
    Avg_Utilization_Ratio DECIMAL(10,3),
    Use_Chip VARCHAR(10),
    Exp_Type VARCHAR(50),
    Interest_Earned DECIMAL(10,3),
    Delinquent_Acc VARCHAR(5)
);

SELECT * FROM customer;
SELECT * FROM credit_card;


# KPI Calculation

-- 1. Total Revenue

SELECT 
    SUM(annual_fees + total_trans_amt + interest_earned) AS total_revenue
FROM credit_card;

--  2. Total Interest Earned

SELECT 
    SUM(interest_earned) AS total_interest
FROM credit_card;

-- 3. Total Transaction Amount

SELECT 
    SUM(total_trans_amt) AS total_transaction_amount
FROM credit_card;

-- 4. Total Transaction Count

SELECT 
    SUM(total_trans_ct) AS total_transaction_count
FROM credit_card;

-- 5.CSS (Customer Satisfaction Score)

SELECT 
    ROUND(AVG(cust_satisfaction_score), 2) AS avg_satisfaction_score
FROM customer;

-- 6. Revenue by Gender

SELECT 
  c.Gender,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY c.Gender
ORDER BY Revenue DESC;

-- 7. Revenue by Card Category

-- Revenue by each card category
SELECT 
  cc.Card_Category,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Total_Revenue,
  ROUND(SUM(cc.interest_earned), 2) AS Total_Interest_Earned,
  ROUND(SUM(cc.annual_fees), 2) AS Total_Annual_Fees
FROM credit_card cc
GROUP BY cc.Card_Category

UNION ALL

-- Grand total row
SELECT 
  'Total' AS Card_Category,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Total_Revenue,
  ROUND(SUM(cc.interest_earned), 2) AS Total_Interest_Earned,
  ROUND(SUM(cc.annual_fees), 2) AS Total_Annual_Fees
FROM credit_card cc;

-- 8. Revenue by Quarter + Total

-- Revenue by each quarter
SELECT 
  CONCAT('Q', quarter_num) AS Quarter,
  ROUND(SUM(Revenue), 2) AS Total_Revenue,
  ROUND(SUM(Interest_Earned), 2) AS Total_Interest_Earned,
  ROUND(SUM(Annual_Fees), 2) AS Total_Annual_Fees
FROM (
    SELECT 
      QUARTER(week_start_date) AS quarter_num,
      annual_fees + total_trans_amt + interest_earned AS Revenue,
      interest_earned AS Interest_Earned,
      annual_fees AS Annual_Fees
    FROM credit_card
) AS sub
GROUP BY quarter_num

UNION ALL

-- Grand total row
SELECT 
  'Total' AS Quarter,
  ROUND(SUM(annual_fees + total_trans_amt + interest_earned), 2),
  ROUND(SUM(interest_earned), 2),
  ROUND(SUM(annual_fees), 2)
FROM credit_card;

-- 9. Transaction Count & Revenue by Quarter

-- Quarter-wise transaction count and revenue
SELECT 
  CONCAT('Q', quarter_num) AS Quarter,
  SUM(total_trans_ct) AS Transaction_Count,
  ROUND(SUM(annual_fees + total_trans_amt + interest_earned), 2) AS Total_Revenue
FROM (
    SELECT 
      QUARTER(week_start_date) AS quarter_num,
      total_trans_ct,
      annual_fees,
      total_trans_amt,
      interest_earned
    FROM credit_card
) AS sub
GROUP BY quarter_num

UNION ALL

-- Grand total row
SELECT 
  'Total' AS Quarter,
  SUM(total_trans_ct),
  ROUND(SUM(annual_fees + total_trans_amt + interest_earned), 2)
FROM credit_card;

-- 10. Revenue by Expenditure Type

SELECT 
  exp_type,
  ROUND(SUM(annual_fees + total_trans_amt + interest_earned), 2) AS Revenue
FROM credit_card
GROUP BY exp_type
ORDER BY Revenue DESC;

-- 11.Revenue by Education Level

SELECT 
  c.Education_Level,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY c.Education_Level
ORDER BY Revenue DESC;

-- 12.  Revenue by Customer Job

SELECT 
  c.Customer_Job,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY c.Customer_Job
ORDER BY Revenue DESC;

-- 13. Revenue by Use of Chip

SELECT 
  use_chip,
  ROUND(SUM(annual_fees + total_trans_amt + interest_earned), 2) AS Revenue
FROM credit_card
GROUP BY use_chip
ORDER BY Revenue DESC;

-- 14. Acquisition Cost by Card Category

SELECT 
  Card_Category,
  ROUND(SUM(Customer_Acq_Cost), 2) AS Total_Acquisition_Cost
FROM credit_card
GROUP BY Card_Category
ORDER BY Total_Acquisition_Cost DESC;

select * FROM credit_card;
select * FROM customer;

-- 15. Revenue by Income Group

SELECT 
  CASE
    WHEN c.Income < 35000 THEN 'Low'
    WHEN c.Income >= 35000 AND c.Income < 70000 THEN 'Mid'
    ELSE 'High'
  END AS Income_Group,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY Income_Group
ORDER BY FIELD(Income_Group, 'Low', 'Mid', 'High');

-- 16. Revenue by Gender per Month

SELECT 
  DATE_FORMAT(cc.week_start_date, '%Y-%m') AS Month,
  c.Gender,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY Month, c.Gender
ORDER BY Month, c.Gender;


-- 15. Age Group

SELECT 
  CASE 
    WHEN c.Customer_Age < 30 THEN '20-30'
    WHEN c.Customer_Age >= 30 AND c.Customer_Age < 40 THEN '30-40'
    WHEN c.Customer_Age >= 40 AND c.Customer_Age < 50 THEN '40-50'
    WHEN c.Customer_Age >= 50 AND c.Customer_Age < 60 THEN '50-60'
    ELSE '60+'
  END AS Age_Group,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY Age_Group
ORDER BY Age_Group;

-- 16. Revenue by Gender in Top 5 States

-- Step 1: CTE to get Top 5 states by total revenue
WITH top_states AS (
  SELECT 
    c.state_cd,
    SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned) AS Revenue
  FROM credit_card cc
  JOIN customer c ON cc.Client_Num = c.Client_Num
  GROUP BY c.state_cd
  ORDER BY Revenue DESC
  LIMIT 5
)

-- Step 2: Revenue by gender for those top 5 states
SELECT 
  c.state_cd,
  c.Gender,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c ON cc.Client_Num = c.Client_Num
WHERE c.state_cd IN (SELECT state_cd FROM top_states)
GROUP BY c.state_cd, c.Gender
ORDER BY c.state_cd, c.Gender;

-- 17. Revenue by Salary Group + Gender

SELECT 
  CASE
    WHEN c.Income < 35000 THEN 'Low'
    WHEN c.Income >= 35000 AND c.Income < 70000 THEN 'Mid'
    ELSE 'High'
  END AS Salary_Group,
  c.Gender,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY Salary_Group, c.Gender
ORDER BY FIELD(Salary_Group, 'Low', 'Mid', 'High'), c.Gender;

-- 18. Revenue by Dependent Count & Gender

SELECT 
  c.Dependent_Count,
  c.Gender,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY c.Dependent_Count, c.Gender
ORDER BY c.Dependent_Count, c.Gender;

-- 19. Revenue by Marital Status & Gender

SELECT 
  c.Marital_Status,
  c.Gender,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY c.Marital_Status, c.Gender
ORDER BY c.Marital_Status, c.Gender;

-- 20. Revenue by Education Level & Gender

SELECT 
  c.Education_Level,
  c.Gender,
  ROUND(SUM(cc.annual_fees + cc.total_trans_amt + cc.interest_earned), 2) AS Revenue
FROM credit_card cc
JOIN customer c
  ON cc.Client_Num = c.Client_Num
GROUP BY c.Education_Level, c.Gender
ORDER BY c.Education_Level, c.Gender;

