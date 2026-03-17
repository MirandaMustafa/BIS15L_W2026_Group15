# DOC, Lake Browning, and Fish Feeding Ecology (BIS15L Project)

## Project question
How does lake browning (higher dissolved organic carbon, DOC) relate to fish diet and trophic position across lakes?

## Dataset and source
- Fish dataset: `data/Charetteetal2024_CJFAS_Fish.csv`
- Baseline dataset: `data/Charetteetal2024_CJFAS_Baselines_DOC.csv`
- Metadata and study paper:
  - `papers/DOC_datainfo.pdf`
  - `papers/DOC_paper.pdf`

The data include continuous variables (e.g., DOC, fish length, stable isotopes, trophic position) and categorical variables (e.g., lake, region, species)

## Repository structure
- `analysis/`
  - `01_data_cleaning.Rmd`
  - `02_eda.Rmd`
  - `03_core_analysis.Rmd`
  - `04_mapping.Rmd`
- `shiny_app/app.R`: interactive app
- `figures/`: saved EDA and mapping plots generated from analysis scripts
- `output_tables/`: csv summaries from analysis 
- `presentation/`: contains presentation .pptx and .pdf versions

### *** PLEASE READ ***
- There are 4 analysis scripts as shown in the repo structure above
- In order to run them smoothly, first run `01_data_cleaning.Rmd` which joins and cleans the data, and saves the new csv file in /data.
- This is because the other three analysis scripts that follow (and the shiny app) uses this new csv.
