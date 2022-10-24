-- !preview conn=DBI::dbConnect(RSQLite::SQLite())
-- Codecademy does not provide a database to connect to and reproduce results

--Warby Parker sells glasses. Customers can take a quiz to determine what style, fit, shape, and color might suit them. Then they have the opportunity to receive a few pairs in the mail to try before they buy. Finally they may make a purchase.
--Within this funnel there are two variations customers may experience of the try-before-you-buy step: they receive either 3 pairs or 5 pairs.

--Getting familiar with the tables

SELECT * FROM survey LIMIT 10;
SELECT question, COUNT(DISTINCT user_id) FROM survey GROUP BY question;
SELECT * FROM quiz LIMIT 5;
SELECT * FROM home_try_on LIMIT 5;
SELECT * FROM purchase LIMIT 5;

--Combining quiz. home_try_on and purchase into one table representing the entire funnel

SELECT quiz.user_id, home_try_on.user_id IS NOT NULL AS 'is_home_try_on', home_try_on.number_of_pairs, purchase.user_id IS NOT NULL AS 'is_purchase' FROM quiz LEFT JOIN home_try_on ON quiz.user_id=home_try_on.user_id LEFT JOIN purchase ON quiz.user_id=purchase.user_id LIMIT 10;

--Determining the percentage of customers advancing to the next stage of the funnel at each step. 
--Result: 75% receive pairs to try on after taking the quiz, and 49.5% make a purchase after trying a few pairs at home

WITH funnel AS (SELECT quiz.user_id, home_try_on.user_id IS NOT NULL AS 'is_home_try_on', home_try_on.number_of_pairs, purchase.user_id IS NOT NULL AS 'is_purchase' FROM quiz LEFT JOIN home_try_on ON quiz.user_id=home_try_on.user_id LEFT JOIN purchase ON quiz.user_id=purchase.user_id) SELECT number_of_pairs, 1.0*SUM(is_purchase)/SUM(is_home_try_on) AS 'pct_conversion' FROM funnel WHERE number_of_pairs IS NOT NULL GROUP BY number_of_pairs;

--Determining the conversion from home try-on to purchase for customers receiving 3 pairs and 5 pairs. 
--Result: 53% of customers who receive 3 pairs make a purchase, and 79% of customers who receive 5 pairs make a purchase

WITH funnel AS (SELECT quiz.user_id, home_try_on.user_id IS NOT NULL AS 'is_home_try_on', home_try_on.number_of_pairs, purchase.user_id IS NOT NULL AS 'is_purchase' FROM quiz LEFT JOIN home_try_on ON quiz.user_id=home_try_on.user_id LEFT JOIN purchase ON quiz.user_id=purchase.user_id) SELECT 1.0*COUNT(user_id)/COUNT(user_id) AS 'quizzes', 1.0*SUM(is_home_try_on)/COUNT(user_id) AS 'quiz_to_home_try_on_pct', 1.0*SUM(is_purchase)/COUNT(user_id) AS 'home_try_on_to_puschase_pct' FROM funnel;

--Determining the most popular style, model and color purchased. 
--Result: Women's 'Eugene Narrow' Tortoise glasses

SELECT style AS 'most_popular_style', COUNT(*) AS 'total_purchases' FROM purchase GROUP BY style ORDER BY COUNT(*) DESC LIMIT 1;

SELECT model_name as 'most_popular_model', COUNT(*) as 'total_purchases' FROM purchase GROUP BY model_name ORDER BY COUNT(*) DESC LIMIT 1;

SELECT color as 'most_popular_color', COUNT(*) as 'total_purchases' FROM purchase GROUP BY model_name ORDER BY COUNT(*) DESC LIMIT 1;

--Determining the most common style, fit, shape and color recommended by the quiz. 
--Result: Women's Narrow Rectangular Tortoise glasses
--Side note: Quiz recommendations match the most popular purchases perfectly. The quiz evidently influences the entire buying process greatly.

SELECT style as 'most_common_style_result', COUNT(*) as 'total_quiz_results' FROM quiz GROUP BY style ORDER BY 2 DESC LIMIT 1;

SELECT fit as 'most_common_fit_result', COUNT(*) as 'total_quiz_results' FROM quiz GROUP BY 1 ORDER BY 2 DESC LIMIT 1;

SELECT shape as 'most_common_shape_result', COUNT(*) as 'total_quiz_results' FROM quiz GROUP BY 1 ORDER BY 2 DESC LIMIT 1;

SELECT color as 'most_common_color_result', COUNT(*) as 'total_quiz_results' FROM quiz GROUP BY 1 ORDER BY 2 DESC LIMIT 1;