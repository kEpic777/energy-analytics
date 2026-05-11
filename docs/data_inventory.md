# Slovenia Energy Data Inventory

## Source: ENTSO-E Transparency Platform

| Dataset | MTU
 | Unit | Coverage | File | Type |
|---|---:|---:|---|---|---|
| DA Prices SI | 60min until 2025-09-30 23:00; 15-min from 2025-10-01 00:00 | EUR/MWh | 2025-01-01 to 2025-12-31 | da_prices_si_2025_clean.csv | Base clean |
| DA Prices SI | 15-min | EUR/MWh | 2026-01-01 to approx. 2026-04-01 | da_prices_si_clean.csv | Base clean |
| DA Prices SI daily average | 1 day | EUR/MWh | 2025-01-01 to 2025-12-31 | da_prices_si_2025_daily_avg.csv | Derived |
| DA price vs ARSO temperature | 1 day | EUR/MWh, °C | 2025-01-01 to 2025-12-31 | da_price_vs_arso_temp_2025.csv | Derived |

## Source: ARSO

| Dataset | MTU
 | Unit | Coverage | File | Type |
|---|---:|---:|---|---|---|
| Ljubljana Bežigrad mean temperature | 1 day | °C | 2025-01-01 to 2025-12-31 | arso_temp_ljubljana_bezigrad_2025_clean.csv | Base clean |

## Source: Borzen

| Dataset | MTU
 | Unit | Coverage | File | Type |
|---|---:|---:|---|---|---|
| Imbalance prices | 15-min | EUR/MWh | 2025-11-01 to 2026-03-01 | imbalance_si_clean.csv | Base clean |
| Balancing volumes and costs | 15-min | MWh/EUR | 2025-11-01 to 2026-03-01 | balancing_volumes_si_clean.csv | Base clean |

## Notes

- - ENTSO-E 2025 DA prices reflect the Slovenian day-ahead Market Time Unit (MTU) change:
  - before 2025-10-01: 60-minute MTU
  - from 2025-10-01 onward: 15-minute MTU
- ENTSO-E 2026 DA prices are 15-minute.
- The mixed 2025 DA MTU
 is a market/product-rule transition, not a data-quality problem.
- ARSO weather series contains daily mean temperature.
- For the weather exercise, DA prices were aggregated to daily average before merging with ARSO weather.
- Borzen CSV files use European decimal format: comma decimal separator.
- Borzen imbalance data contains two settlement types: First and Second imbalance settlement.
- The switch from Second to First imbalance settlement occurred on 2026-02-01.
- Raw and curated files are stored in the top-level `data/` folder only.
- Duplicate `notebooks/data/raw` folder was deleted.
- Unused ARSO observation XML test file was removed.