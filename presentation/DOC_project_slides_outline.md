# DOC Project Presentation Outline

## Slide 1: Title
- Lake browning (DOC) and fish feeding ecology
- Course: BIS15L
- Team members

## Slide 2: Background
- What DOC is and why it matters
- Why lake browning can alter food-web structure

## Slide 3: Data Source
- Charette et al. 2024 freshwater fish dataset
- 3,430 fish records, 78 lakes, 6 species, 6 regions
- Variables: DOC, isotopes, trophic position, pelagic diet proportion, fish length

## Slide 4: Research Questions
- Q1: DOC vs trophic position
- Q2: DOC vs pelagic diet proportion
- Q3: Species/region differences in DOC relationships

## Slide 5: Workflow
- Import and clean two CSV files
- Join fish and baseline data by lake
- Create analysis dataset and DOC categories
- Check missingness and build summaries

## Slide 6: EDA Results
- DOC distribution
- Fish length variation by species

## Slide 7: Core Result 1
- DOC vs trophic position (scatter + trend)
- Interpretation of direction/strength

## Slide 8: Core Result 2
- DOC vs pelagic diet proportion
- Species-level differences in slopes/patterns

## Slide 9: Core Result 3
- Mean trophic position across DOC categories
- Species boxplots for trophic and pelagic metrics

## Slide 10: Mapping
- Lake locations and DOC gradient map
- High-DOC lake focus map

## Slide 11: Shiny App Demo
- Inputs: species, region, metric
- Outputs: reactive DOC scatterplot + summary table

## Slide 12: Limitations and Conclusion
- Observational design (no causal claim)
- Uneven sample coverage by species/lake
- Main takeaway about DOC and fish feeding ecology
