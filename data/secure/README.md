# Secure datasets to be used in VNSO trade statistics RAP

## Suggested naming convention

**TYPE_STATUS_SOURCE_DESC_DATE.suffix**

- **TYPE**: [OPN|SEC] to show whether this is an open (OPN) or secure (SEC) dataset
- **STATUS**: [RAW|PROC|FINAL] to show whether this is a raw (RAW), processed (PROC) or final (FINAL) dataset
- **SOURCE**: where the data came from (ASY for Asycuda, for example)
- **DESC**: brief [`camelCase`](https://en.wikipedia.org/wiki/Camel_case) description of dataset
- **DATE**: [dd-mm-YY] formatted date of when dataset last updated
- **suffix**: [csv|xlsx|tsv|txt|etc.] file format abbreviation

## Dataset dictionary

Datasets currently present in secure folder:

- `exports_HS-Year_summaryStats_02-10-20.csv` - Summary statistics for *exports* for each HS code and year
- `exports_HS_summaryStats_02-10-20.csv` - Summary statistics for *exports* for each HS code
- `imports_HS-Year_summaryStats_02-10-20.csv` - Summary statistics for *imports* for each HS code and year
- `imports_HS_summaryStats_02-10-20.csv` - Summary statistics for *imports* for each HS code
- `SEC_PROC_ASY_RawDataAndReferenceTables_31-01-20.xlsx` - processed version of January's monthly statistics data. Additional sheets provide reference tables to intepret custom codes.
- `tradeStats_historic_EXPORTS_14-09-20.csv` - Historic trade statistics for exports (1999-2019)
- `tradeStats_historic_IMPORTS_14-09-20.csv` - Historic trade statistics for exports (1999-2019)
- `tradeStats_historic_IMPORTS_14-09-20.csv` - trade statistics data for all **IMPORTS** into Vanuatu from 1999 to 2019
- `tradeStats_historic_EXPORTS_14-09-20.csv` - trade statistics data for all **EXPORTS** into Vanuatu from 1999 to 2019
- `country_export.csv` - SQL dump for dashboard
- `country_year_export.csv` - SQL dump for dashboard
- `country_year_import.csv` - SQL dump for dashboard
- `curtrade.csv` - SQL dump for dashboard
- `tab.csv` - SQL dump for dashboard
- `tblservices.csv` - SQL dump for dashboard
- `trades.csv` - SQL dump for dashboard
- `gadm36_levels_shp/` - GADM shape files for world country boundaries (source: https://gadm.org/download_world.html)
