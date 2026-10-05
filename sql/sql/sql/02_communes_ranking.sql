-- =====================================================================
-- 02 - Commune ranking (Gironde, 2021-2025)
-- Neighborhood is approximated by commune, because DVF has no neighborhood field.
-- Only communes with enough sales are ranked, so a few sales cannot decide a rank.
-- =====================================================================

-- Query 4: Rank communes by median price/m2 over 2021-2025 (CTE + RANK window function).
-- Why: shows the most and least expensive places. Minimum 200 sales for a reliable median.
-- Note: each commune's median mixes houses and apartments.
WITH communes AS (
    SELECT
        nom_commune,
        COUNT(*) AS sales,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_m2
    FROM sales_clean
    GROUP BY nom_commune
    HAVING COUNT(*) >= 200
)
SELECT
    RANK() OVER (ORDER BY median_price_m2 DESC) AS rank_expensive,
    nom_commune,
    sales,
    ROUND(median_price_m2::numeric) AS median_price_m2
FROM communes
ORDER BY rank_expensive;

-- RESULT Query 4: 87 communes with 200+ sales. Most expensive: Lege-Cap-Ferret (8,100), Arcachon (7,748),
-- Andernos (5,318), La Teste (5,096), Lacanau (5,000). Bordeaux is 8th (4,600).
-- Cheapest: Castillon-la-Bataille (1,284), Pineuilh (1,342), La Reole (1,462), Saint-Seurin-sur-l'Isle (1,563), Blaye (1,600).
-- About 6x spread between top and bottom. Coastal communes are above the city; rural east and south are lowest.
-- Caveat: each median mixes houses and apartments.

-- Query 5: Change of the median between 2021 and 2025, by commune.
-- Why: shows where the fall is strongest. Minimum 100 sales in both years.
WITH by_year AS (
    SELECT
        nom_commune,
        COUNT(*) FILTER (WHERE year = 2021) AS sales_2021,
        COUNT(*) FILTER (WHERE year = 2025) AS sales_2025,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) FILTER (WHERE year = 2021) AS median_2021,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) FILTER (WHERE year = 2025) AS median_2025
    FROM sales_clean
    GROUP BY nom_commune
)
SELECT
    nom_commune,
    sales_2021,
    sales_2025,
    ROUND(median_2021::numeric) AS median_2021,
    ROUND(median_2025::numeric) AS median_2025,
    ROUND(((median_2025 / median_2021 - 1) * 100)::numeric, 1) AS change_pct
FROM by_year
WHERE sales_2021 >= 100 AND sales_2025 >= 100
ORDER BY change_pct;

-- RESULT Query 5: 2021 -> 2025 change of the median (communes with 100+ sales in both years).
-- Biggest falls: Cenon -11.0%, Carbon-Blanc -10.5%, Bordeaux -10.3%, Begles -9.9%, Blanquefort -9.3%.
-- Rises: Soulac +29.4%, Lacanau +28.0%, Langon +10.8%, Arcachon +6.3%, Lege-Cap-Ferret +3.8%.
-- Pattern (hypothesis): the metropole corrected most, the coast held. Rises in Lacanau/Soulac may reflect a type mix
-- change; check by type before concluding.