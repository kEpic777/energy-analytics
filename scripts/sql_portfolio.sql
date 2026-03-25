-- Day 13: Build your 12-query portfolio

-- 1. Basic aggregation: monthly average DA price

SELECT
    MONTH(timestamp) as month,
    ROUND(AVG(price_eur_mwh), 2) as avg_price
FROM da_prices
GROUP BY MONTH(timestamp)
ORDER BY month

-- 2. Filtered aggregation: peak-only monthly average

SELECT
    MONTH(timestamp) as month,
    ROUND(AVG(price_eur_mwh), 2) as avg_price
FROM da_prices
WHERE HOUR(timestamp) BETWEEN 8 AND 19
GROUP BY MONTH(timestamp)
ORDER BY month

-- 3. JOIN: DA prices with calendar for seasonal analysis

SELECT
    c.season,
    c.day_type,
    ROUND(AVG(p.price_eur_mwh), 2) as avg_price
FROM da_prices p
JOIN calendar c ON CAST(p.timestamp AS DATE) = c.date
GROUP BY c.season, c.day_type
ORDER BY c.season, c.day_type

-- 4. CTE: days where price exceeded 2x monthly average

WITH monthly_avg AS (
    SELECT MONTH(timestamp) as month, AVG(price_eur_mwh) as avg_price
    FROM da_prices GROUP BY MONTH(timestamp)
),
daily_avg AS (
    SELECT CAST(timestamp AS DATE) as date, MONTH(timestamp) as month, AVG(price_eur_mwh) as daily_price
    FROM da_prices GROUP BY CAST(timestamp AS DATE), MONTH(timestamp)
)
SELECT d.date, ROUND(d.daily_price,2) as daily, ROUND(m.avg_price,2) as monthly
FROM daily_avg d JOIN monthly_avg m ON d.month = m.month
WHERE d.daily_price > m.avg_price * 2

-- 5. Window: hourly price with 24h rolling average

SELECT timestamp, price_eur_mwh,
    ROUND(AVG(price_eur_mwh) OVER (ORDER BY timestamp ROWS BETWEEN 23 PRECEDING AND CURRENT ROW), 2) as rolling_24h
FROM da_prices

-- 6. Window: rank hours within each day by price

SELECT timestamp, price_eur_mwh,
    RANK() OVER (PARTITION BY CAST(timestamp AS DATE) ORDER BY price_eur_mwh DESC) as rank_in_day
FROM da_prices

-- 7. LAG: hour-over-hour price change

SELECT timestamp, price_eur_mwh,
    LAG(price_eur_mwh) OVER (ORDER BY timestamp) as prev_hour,
    ROUND(price_eur_mwh - LAG(price_eur_mwh) OVER (ORDER BY timestamp), 2) as change
FROM da_prices

-- 8. Subquery: months where max price > 150

SELECT month, max_price FROM (
    SELECT MONTH(timestamp) as month, MAX(price_eur_mwh) as max_price
    FROM da_prices GROUP BY MONTH(timestamp)
) WHERE max_price > 150

-- 9. CASE: classify hours as spike/high/normal/low

SELECT timestamp, price_eur_mwh,
    CASE
        WHEN price_eur_mwh > 150 THEN 'spike'
        WHEN price_eur_mwh > 90 THEN 'high'
        WHEN price_eur_mwh > 50 THEN 'normal'
        ELSE 'low'
    END as price_category
FROM da_prices

-- 10. GROUP BY multiple: season + day_type + peak/offpeak average

SELECT c.season, c.day_type,
    ROUND(AVG(CASE WHEN HOUR(p.timestamp) BETWEEN 8 AND 19 THEN p.price_eur_mwh END), 2) as peak_avg,
    ROUND(AVG(CASE WHEN HOUR(p.timestamp) NOT BETWEEN 8 AND 19 THEN p.price_eur_mwh END), 2) as offpeak_avg
FROM da_prices p
JOIN calendar c ON CAST(p.timestamp AS DATE) = c.date
GROUP BY c.season, c.day_type

-- 11. Window + CTE: 7-day rolling average with trend flag

WITH daily AS (
    SELECT CAST(timestamp AS DATE) as date, AVG(price_eur_mwh) as avg_price
    FROM da_prices GROUP BY CAST(timestamp AS DATE)
)
SELECT date, ROUND(avg_price,2) as avg_price,
    ROUND(AVG(avg_price) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) as rolling_7d,
    CASE WHEN avg_price > AVG(avg_price) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
        THEN 'above' ELSE 'below' END as trend
FROM daily

-- 12. Daily peak-offpeak spread ranked by month

SELECT month, ROUND(avg_spread, 2) as avg_spread,
    RANK() OVER (ORDER BY avg_spread DESC) as rank
FROM (
    SELECT MONTH(timestamp) as month,
        AVG(CASE WHEN HOUR(timestamp) BETWEEN 8 AND 19 THEN price_eur_mwh END) -
        AVG(CASE WHEN HOUR(timestamp) NOT BETWEEN 8 AND 19 THEN price_eur_mwh END) as avg_spread
    FROM da_prices GROUP BY MONTH(timestamp)
)