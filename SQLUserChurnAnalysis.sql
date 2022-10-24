-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

-- A subscription service segments customers into two segments(coded 87 and 30) of customers acquired through two different channels. 

--Getting familiar with tables

SELECT * FROM subscriptions LIMIT 10;

SELECT MAX(subscription_start), MAX(subscription_end), MIN(subscription_start), MIN(subscription_end) FROM subscriptions;

--Determining chrun rate for each month of first quarter for segment '87' and segment '30'
-- Result: month	pct_churn_87	pct_churn_30
--2017-01-01	0.251798561151079	0.0756013745704467
--2017-02-01	0.471861471861472	0.115830115830116
--2017-03-01	0.896421845574388	0.201117318435754

-- Segment '30' has significantly less user churn.

WITH months AS
(SELECT '2017-01-01' AS first_day, '2017-01-31' AS last_day
UNION
SELECT '2017-02-01' as first_day, '2017-02-28' as last_day
UNION 
SELECT '2017-03-01' as first_day, '2017-03-31' as last_day),

cross_join AS 
(SELECT * FROM subscriptions
CROSS JOIN months),

status AS
(SELECT id, first_day AS month, 
CASE 
  WHEN subscription_start < first_day
    AND segment = 87
    AND (subscription_end > first_day OR subscription_end IS NULL)
  THEN 1
  ELSE 0 
  END AS is_active_87,
CASE
  WHEN subscription_start < first_day
    AND segment = 30
    AND (subscription_end > first_day OR subscription_end IS NULL)
  THEN 1
  ELSE 0
  END AS is_active_30,
CASE 
  WHEN (subscription_end < first_day
    OR (subscription_end BETWEEN first_day AND last_day))
    AND segment = 87
  THEN 1 
  ELSE 0
  END AS is_canceled_87,
CASE
  WHEN (subscription_end < first_day
    OR (subscription_end BETWEEN first_day AND last_day))
    AND segment = 30
  THEN 1 
  ELSE 0
  END AS is_canceled_30
 FROM cross_join),

 status_aggregate AS
 (SELECT month, SUM(is_active_87) as sum_active_87, SUM(is_active_30) as sum_active_30, SUM(is_canceled_87) as sum_canceled_87, SUM(is_canceled_30) as sum_canceled_30 FROM status GROUP BY month)

 SELECT month, 1.0 * sum_canceled_87 / sum_active_87 as pct_churn_87, 1.0 * sum_canceled_30 / sum_active_30 as pct_churn_30 FROM status_aggregate;
