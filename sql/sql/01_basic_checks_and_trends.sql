-- =====================================================================
-- 01 - Basic checks and market trends (Gironde, 2021-2025)
-- Table: sales_clean (one row = one residential sale, price_per_m2 computed)
-- =====================================================================

-- Query 1: Median and average price/m2 per year, by property type.
-- Why: the median resists outliers; the average shows how much they pull it up.
SELECT
    year,
    type_local,
    COUNT(*)                                                    AS sales,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric) AS median_price_m2,
    ROUND(AVG(price_per_m2)::numeric)                           AS avg_price_m2
FROM sales_clean
GROUP BY year, type_local
ORDER BY type_local, year;

-- RESULT Query 1 (Gironde): median price/m2 peaked in 2022 for both types
-- (apartments 3,939; houses 3,462) and fell by 2025 (3,634; 3,125), i.e. about -8% and -10%.
-- The average is above the median every year (outliers pull it up), so the median is the reference.
-- In Gironde apartments are more expensive per m2 than houses.

-- Query 2: Same, for Bordeaux only (the focus of the project).
-- Why: Gironde-wide figures mix very different markets (Bordeaux, Cap Ferret, rural areas).
SELECT
    year,
    type_local,
    COUNT(*)                                                    AS sales,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric) AS median_price_m2
FROM sales_clean
WHERE nom_commune = 'Bordeaux'
GROUP BY year, type_local
ORDER BY type_local, year;

-- RESULT Query 2 (Bordeaux): apartments 4,595 (2021) -> 4,621 (2022) -> 4,124 (2025);
-- houses 5,211 -> 5,378 -> 4,843. Bordeaux is about 13% above Gironde for apartments and 55% for houses.
-- Here houses are more expensive per m2 than apartments (the reverse of Gironde). Cause not tested yet.
-- Caveat: Bordeaux houses have small samples (861 sales in 2024).

-- Query 3: Year-over-year change of the Bordeaux median (CTE + window function LAG).
-- Why: shows whether the market rose or fell each year, in % and not only in euros.
WITH yearly AS (
    SELECT
        year,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_m2
    FROM sales_clean
    WHERE nom_commune = 'Bordeaux'
    GROUP BY year
)
SELECT
    year,
    ROUND(median_price_m2::numeric)                                   AS median_price_m2,
    ROUND(((median_price_m2 / LAG(median_price_m2) OVER (ORDER BY year) - 1) * 100)::numeric, 1) AS yoy_pct
FROM yearly
ORDER BY year;

-- RESULT Query 3 (Bordeaux, all types): YoY +1.2% (2022), -2.4% (2023), -7.5% (2024), -1.8% (2025).
-- Cumulative 2022 -> 2025: -11.4%. Prices are nominal (not adjusted for inflation), so the real fall is larger.
-- Caveat: the all-types median also depends on the apartment/house mix each year.