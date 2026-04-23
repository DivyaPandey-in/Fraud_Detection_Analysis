CREATE DATABASE fraud_detection;
USE fraud_detection;
DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    step INT,
    type VARCHAR(20),   
    amount DOUBLE,
    nameOrig VARCHAR(50),
    oldbalanceOrg DOUBLE,
    newbalanceOrig DOUBLE,
    nameDest VARCHAR(50),
    oldbalanceDest DOUBLE,
    newbalanceDest DOUBLE,
    isFraud INT,
    isFlaggedFraud INT
);

select * from transactions;

/* data cleaning*/
SELECT 0000
COALESCE(SUM(CASE WHEN step is null THEN 1 END),0)AS step_nulls,
COALESCE(SUM(CASE WHEN type is NULL THEN 1 END),0)AS type_nulls,
COALESCE(SUM(CASE WHEN amount IS NULL THEN 1 END),0)AS amount_nulls,
COALESCE(SUM(CASE WHEN nameOrig IS NULL THEN 1 END),0)AS nameOrig_nulls,
COALESCE(SUM(CASE WHEN oldbalanceOrg IS NULL THEN 1 END),0)AS oldbalanceOrg_nulls,
COALESCE(SUM(CASE WHEN newbalanceOrig IS NULL THEN 1 END),0)AS newbalanceOrig_nulls,
COALESCE(SUM(CASE WHEN nameDest IS NULL THEN 1 END),0)AS nameDest_nulls,
 COALESCE(SUM(CASE WHEN oldbalanceDest IS NULL THEN 1 END),0)AS oldbalanceDest_nulls
FROM transactions;

/*Duplicate check*/  
SELECT COUNT(*), step,type,amount, nameOrig,  nameDest, oldbalanceOrg,newbalanceOrig,  oldbalanceDest,    newbalanceDest ,isFraud,  isFlaggedFraud
FROM transactions
group by step,type,amount, nameOrig,  nameDest, oldbalanceOrg,newbalanceOrig,  oldbalanceDest,    newbalanceDest ,isFraud,  isFlaggedFraud
HAVING COUNT(*)>1;

/*Negative or  Invalid Values*/
SELECT *
FROM transactions 
WHERE amount<0;

/*Outliers Check */
SELECT max(amount),min(amount)
FROM transactions;

/*Balance mismatch */
SELECT *
from transactions
WHERE ABS((oldbalanceOrg-amount) - newbalanceOrig)>1
AND isFraud=0;
/*Fraud vs Flag comparison*/
select isFraud ,
isFlaggedFraud, COUNT(*)
FROM transactions
GROUP BY isFraud ,isFlaggedFraud;

/*EDA */
/*total number of records */
SELECT COUNT(*) FROM transactions;

/*fraud percentage */
SELECT SUM(isFraud)AS total_fraud,
(SUM(isfraud)*100.0)/count(*)AS fraud_percentage
FROM transactions;

/*fraud by type */
SELECT type,COUNT(*)AS total_txn,
SUM(isFraud)as fraud_cases
from transactions 
group by type;

/*Top fraud users*/
select nameOrig,
COUNT(*) AS fraud_users
FROM transactions
WHERE isFraud = 1
group by  nameOrig
order by fraud_users DESC
LIMIT 10;

/*Amount behavior*/
SELECT isFraud,
AVG(amount)AS avg_amt
,MAX(amount)AS max_amt
from transactions
GROUP BY isFraud;

/*Time pattern */
select step,count(*) as Total_txn,
SUM(isFraud)AS fraud_cases
from transactions 
group by step
order by step;

/* Fraud % by type */
SELECT 
    type,
    COUNT(*) AS total_txn,
    SUM(isFraud) AS fraud_cases,
    (SUM(isFraud)*100.0/COUNT(*)) AS fraud_percentage
FROM transactions
GROUP BY type;

/*High value fraud check*/
SELECT 
    CASE 
        WHEN amount < 10000 THEN 'Low'
        WHEN amount BETWEEN 10000 AND 100000 THEN 'Medium'
        ELSE 'High'
    END AS amount_category,
    COUNT(*) AS total,
    SUM(isFraud) AS fraud_cases
FROM transactions
GROUP BY amount_category;