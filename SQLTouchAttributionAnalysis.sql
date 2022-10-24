-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

--Creating table of first touches

WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id)
SELECT ft.user_id,
    ft.first_touch_at,
    pv.utm_source,
		pv.utm_campaign
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp LIMIT 10;

--Getting familiar with data

SELECT COUNT(DISTINCT utm_source) FROM page_visits;
SELECT COUNT(DISTINCT utm_campaign) FROM page_visits;
SELECT DISTINCT utm_source, utm_campaign FROM page_visits;

SELECT DISTINCT page_name FROM page_visits;

--Determining the number of first touches attributed to each marketing campaign
-- Result: utm_campaign	first_touches
--cool-tshirts-search	169
--getting-to-know-cool-tshirts	612
--interview-with-cool-tshirts-founder	622
--ten-crazy-cool-tshirts-facts	576

WITH first_touch AS 
(SELECT user_id, MIN(timestamp) as first_touch_at FROM page_visits GROUP BY user_id) 
SELECT utm_campaign, COUNT(*) as 'first_touches' FROM first_touch 
JOIN page_visits 
ON first_touch.user_id=page_visits.user_id
AND first_touch.first_touch_at=page_visits.timestamp
GROUP BY utm_campaign;

--Determining the number of last touches attributed to each marketing campaign
-- Result: utm_campaign	last_touches
--cool-tshirts-search	60
--getting-to-know-cool-tshirts	232
--interview-with-cool-tshirts-founder	184
--paid-search	178
--retargetting-ad	443
--retargetting-campaign	245
--ten-crazy-cool-tshirts-facts	190
--weekly-newsletter	447

WITH last_touch AS 
(SELECT user_id, MAX(timestamp) as last_touch_at FROM page_visits GROUP BY user_id) 
SELECT utm_campaign, COUNT(*) as 'last_touches' FROM last_touch 
JOIN page_visits 
ON last_touch.user_id=page_visits.user_id
AND last_touch.last_touch_at=page_visits.timestamp
GROUP BY utm_campaign;

--Determining the number of visitors who reach each step of website funnel
--  Result: page_name	COUNT(DISTINCT user_id)
--1 - landing_page	1979
--2 - shopping_cart	1881
--3 - checkout	1431
--4 - purchase	361

SELECT page_name, COUNT(DISTINCT user_id) as FROM page_visits GROUP BY page_name;

--Determining the number of last touches on the purchase page attributed to each marketing campaign
-- Result: utm_campaign	purchase_page_last_touches
--cool-tshirts-search	2
--getting-to-know-cool-tshirts	9
--interview-with-cool-tshirts-founder	7
--paid-search	52
--retargetting-ad	113
--retargetting-campaign	54
--ten-crazy-cool-tshirts-facts	9
--weekly-newsletter	115

WITH last_touch AS 
(SELECT user_id, MAX(timestamp) as last_touch_at FROM page_visits WHERE page_name = '4 - purchase' GROUP BY user_id) 
SELECT utm_campaign, COUNT(*) as 'purchase_page_last_touches' FROM last_touch 
JOIN page_visits 
ON last_touch.user_id=page_visits.user_id
AND last_touch.last_touch_at=page_visits.timestamp
GROUP BY utm_campaign;

