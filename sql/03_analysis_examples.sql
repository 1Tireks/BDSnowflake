-- Примеры аналитических запросов (шаг 6 задания)

SELECT COUNT(*) AS mock_rows FROM mock_data;

SELECT customer_country, COUNT(*) AS cnt
FROM mock_data
GROUP BY customer_country
ORDER BY cnt DESC
LIMIT 10;

SELECT product_category, ROUND(AVG(product_price), 2) AS avg_price
FROM mock_data
GROUP BY product_category
ORDER BY avg_price DESC;

SELECT
    c.country_name,
    COUNT(fs.sale_id) AS sales_count,
    SUM(fs.total_price) AS revenue
FROM fact_sales fs
JOIN dim_customer dc ON dc.customer_id = fs.customer_id
JOIN dim_country c ON c.country_id = dc.country_id
GROUP BY c.country_name
ORDER BY revenue DESC
LIMIT 15;
