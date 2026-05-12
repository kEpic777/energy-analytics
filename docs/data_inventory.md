# Slovenia Energy Data Inventory

## Source: ENTSO-E Transparency Platform

| Dataset | MTU | Unit | Coverage | File | Type |
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

## DuckDB analytics objects

| Object | Type | Source tables | Coverage | Description |
|---|---|---|---|---|
| `calendar` | Table | `da_prices_all` | 2025-01-01 to 2026-04-01 | Calendar dimension rebuilt dynamically from the full DA price date range. Contains date, day of week, day type, month, and season. |
| `da_analytics` | View | `da_prices_all`, `calendar` | 2025-01-01 to 2026-04-01 | Adds time/calendar dimensions to DA prices: delivery date, hour, day type, month, season, and peak/offpeak flag. |
| `daily_summary` | View | `da_analytics` | 2025-01-01 to 2026-04-01 | Aggregates DA prices to one row per day. Includes interval count, expected intervals, completeness flag, completeness reason, average/min/max price, volatility, and MTU. |
| `da_imbalance_joined` | View | `da_prices_all`, `imbalance_prices` | 2025-11-01 00:15 to 2026-03-01 00:00 | Joins DA prices with Borzen imbalance prices on exact timestamp. Includes positive and negative imbalance spread versus DA price. |

## Notes

- ENTSO-E 2025 DA prices reflect the Slovenian day-ahead Market Time Unit (MTU) change:
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
- The DuckDB `calendar` table was rebuilt dynamically because the previous version only covered 2025, while `da_prices_all` currently covers 2025-01-01 to 2026-04-01.
- The `daily_summary` view is resolution-aware and DST-aware:
  - normal hourly day: 24 intervals
  - normal 15-minute day: 96 intervals
  - spring DST hourly day: 23 intervals
  - spring DST 15-minute day: 92 intervals
  - autumn DST hourly day: 25 intervals
  - autumn DST 15-minute day: 100 intervals
- Remaining incomplete DA days after DST handling:
  - 2025-12-31: missing one 15-minute interval, likely 00:00
  - 2026-04-01: partial boundary day with only one interval
- `da_imbalance_joined` matched 11,519 DA rows with imbalance rows.
- In the DA + imbalance overlap period, there are 11,519 DA rows, 11,520 imbalance rows, and 11,519 joined rows.
- The one unmatched imbalance row is caused by a missing DA timestamp.
- Day 19 exercise calculated average short imbalance cost by hour as `Cpoz - DA price`.
- Initial Day 19 result showed the highest average short cost around hours 8–13, especially hour 9. Some extreme values are present, so outlier/median analysis should be handled separately later.