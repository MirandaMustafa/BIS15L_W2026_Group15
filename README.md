# DOC, Lake Browning, and Fish Feeding Ecology (BIS15L Project)

## Project question
How does lake browning (higher dissolved organic carbon, DOC) relate to fish diet and trophic position across lakes?

## Dataset and source
- Fish dataset: `data/Charetteetal2024_CJFAS_Fish.csv`
- Baseline dataset: `data/Charetteetal2024_CJFAS_Baselines_DOC.csv`
- Metadata and study paper:
  - `papers/DOC_datainfo.pdf`
  - `papers/DOC_paper.pdf`

The data include continuous variables (e.g., DOC, fish length, stable isotopes, trophic position) and categorical variables (e.g., lake, region, species), which matches BIS15L project expectations.

## Repository structure
- `analysis/`
  - `00_build_project_outputs.R`: full pipeline script that builds cleaned data, figures, and summary tables
  - `01_data_cleaning.Rmd`
  - `02_eda.Rmd`
  - `03_core_analysis.Rmd`
  - `04_mapping.Rmd`
- `shiny_app/app.R`: interactive app (filters by species, region, metric)
- `figures/`: saved EDA/core/mapping plots
- `output_tables/`: CSV summaries for QA and interpretation
- `presentation/DOC_project_slides_outline.md`: slide-by-slide presentation draft

## Research questions
1. Do fish from lakes with higher DOC have different trophic positions?
2. Do fish from lakes with higher DOC have different pelagic diet proportions?
3. Do these DOC relationships differ across species and regions?