# Bordeaux Real Estate Market Analysis (DVF, 2021-2025)

**Question:** What drives price per m² in Bordeaux, and how has the market evolved over the last 5 years?

**Status:** in progress (data cleaning done, SQL analysis next)

## Data
- Source: DVF géolocalisées (Etalab), data.gouv.fr, department 33 (Gironde), 2021-2025.
- Raw size: about 525,000 rows over 5 years. One sale can span several rows (apartment + cellar + parking), with the total price repeated on each row.

## Tools
Python (pandas, matplotlib, seaborn), PostgreSQL, Power BI, Jupyter, Git.

## Method
1. **Cleaning** (`notebooks/01_explore.ipynb`, `02_clean_all_years.ipynb`): one filter at a time, with the row count recorded after each.
2. **Database** (`03_load_postgres.ipynb`): TODO
3. **SQL analysis** (`sql/`): TODO
4. **Python analysis**: TODO
5. **Dashboard**: TODO

## Cleaning funnel (2024 example)
| Step | Rows |
|---|---|
| Raw rows | 82,927 |
| Nature = Vente | 76,020 |
| No commercial premises | 69,872 |
| Houses/apartments only | 22,897 |
| After dropping duplicates | 20,126 |
| One property per sale | 18,238 |
| Price and surface present | 18,228 |
| After outlier removal | 17,935 |

Final clean table, all years: **115,656 residential sales** (2021: 28,097, 2022: 27,047, 2023: 20,545, 2024: 17,935, 2025: 22,032).

## Key cleaning decisions
- Only ordinary sales (`Vente`); new builds (VEFA), exchanges and auctions excluded.
- Only sales with exactly one house or apartment, because the total price cannot be split fairly between several units.
- Outliers removed: price < 10,000 €, surface outside 9-500 m², price/m² outside 500-15,000 €.
- 2025 loses many rows at the commercial-premises step because of a few very large multi-lot sales; checked and confirmed as correct.

## Findings in progress (SQL trends and commune ranking done, "what drives price" analysis next)
- Bordeaux median price/m² peaked in 2022 (4,816 €) and fell about 11% by 2025 (4,269 €), mostly in 2024 (-7.5%).
- Bordeaux is about 13% above Gironde for apartments and 55% above for houses (2025 medians).
- In Bordeaux houses cost more per m² than apartments, the reverse of Gironde overall.
- Clean sales in Bordeaux fell about 32% between 2021 and 2024, then partly recovered in 2025.
- Prices are nominal (not inflation-adjusted).
- Location is a major driver: communes range from about 1,300 €/m² (Castillon-la-Bataille) to 8,100 (Lège-Cap-Ferret). Bordeaux ranks 8th at 4,600; the top 7 are coastal communes of the Bassin d'Arcachon, Médoc and Lacanau.
- 2021 to 2025: the metropole fell most (Bordeaux -10.3%, Cenon -11.0%, Bègles -9.9%), while Arcachon (+6.3%) and Lège-Cap-Ferret (+3.8%) held up. Lacanau and Soulac rose strongly, to be verified by property type.
- In Bordeaux, small units cost more per m²: apartments go from 5,325 €/m² (<25 m²) to 3,961 (60-80 m²), then rise again for large units.
- Location inside Bordeaux matters: postal code 33000 (centre) has a median of 5,000 €/m², about 21% above 33300 (4,117).
- What drives price/m² in Bordeaux (regression, R² = 0.18): property type (houses about +30% vs apartments, land included) and location (postal codes 14-16% below the centre, 33000) matter most; surface has a small negative effect; rooms add nothing once surface is controlled.
- The 2021-2025 decline (about -10%) remains after controlling for type, surface and location, so it is not caused by a change in what was sold.
- Most of the price variation (about 80%) is not explained by the data available in DVF (floor, condition, view, exact street).
- Distance to the centre improves the model: held-out R² rises from 0.177 to 0.252 when added to surface, type, postal code and year. Location is the strongest driver found, though about 75% of price variation stays unexplained by DVF fields.
- Each extra km from the centre lowers price/m² by about 10% on average (mostly apartments: median 5,098 €/m² within 1 km vs 3,435 beyond 4 km, about -33%). For houses the distance effect is weak, possibly because plot size grows with distance (hypothesis).

## Limitations
- Neighborhood is approximated by commune/postal code; DVF has no neighborhood field.
- Outlier thresholds are fixed for all communes, so a few real luxury sales are cut.
- House prices include the land.
- Large multi-lot sales are excluded by design.

## How to reproduce
1. Download the DVF files for department 33 into `data/raw/` (`dvf_YEAR_33.csv.gz`).
2. Create the environment: `conda create -n dvf python=3.11 pandas numpy matplotlib seaborn ipykernel sqlalchemy psycopg2 scikit-learn`
3. Run the notebooks in order.