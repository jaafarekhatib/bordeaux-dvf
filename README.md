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

## Findings
TODO (after the analysis)

## Limitations
- Neighborhood is approximated by commune/postal code; DVF has no neighborhood field.
- Outlier thresholds are fixed for all communes, so a few real luxury sales are cut.
- House prices include the land.
- Large multi-lot sales are excluded by design.

## How to reproduce
1. Download the DVF files for department 33 into `data/raw/` (`dvf_YEAR_33.csv.gz`).
2. Create the environment: `conda create -n dvf python=3.11 pandas numpy matplotlib seaborn ipykernel sqlalchemy psycopg2 scikit-learn`
3. Run the notebooks in order.