# BIS 15L Project Execution Plan
## DOC (Dissolved Organic Carbon) Freshwater Fish Dataset

## 1. Project title
**How does lake browning relate to fish diet and food-chain position across lakes?**

---

## 2. One-sentence project story
This project asks whether fish from lakes with higher dissolved organic carbon (DOC, meaning browner water) show different feeding patterns and different positions in the food chain.

---

## 3. Why this dataset is a strong fit for BIS 15L
This dataset is a good fit because it has:
- a **peer-reviewed article** behind it
- a mix of **categorical variables** and **continuous variables**
- a clear biological story
- enough structure for **wrangling, visualization, mapping, and a Shiny app**
- a format similar in spirit to the GOBY example: many locations, many numeric measurements, one central environmental question

### Requirement matching
- **Peer-reviewed source article** → yes
- **Clear story** → yes: does lake browning change fish feeding ecology?
- **Continuous + categorical variables** → yes
- **Wrangling + visualization + interpretation** → yes
- **Mapping block if geo data exists** → yes, if latitude/longitude are present
- **Shiny app** → yes
- **Presentation** → yes

---

## 4. Dumbed-down dataset meaning
Think of the dataset like this:

- each **lake** has a brownness score = **DOC**
- each **fish** has:
  - a species
  - a size
  - chemistry measurements
  - an estimated diet type
  - an estimated food-chain level

Main idea:
**Do fish from browner lakes eat differently?**

---

## 5. Main variables to use

## A) Main explanatory variable
- `doc_mg_l`
  - dissolved organic carbon in the lake
  - dumbed down: how brown / organic-rich the lake water is

## B) Main response variables
- `pelagic_diet_proportion`
  - how much the fish depends on open-water food
- `trophic_position`
  - where the fish sits in the food chain
- `length_mm`
  - fish size

## C) Supporting chemistry variables
- `d13c`
- `d15n`
- `c_n`
- optional corrected carbon variable if present

These are useful for EDA and backup plots, but they do not need to be the main story.

## D) Categorical grouping variables
- `fish_species`
- `lake`
- `region`
- maybe `country` or similar location grouping if present

## E) Date columns
- `year`
- `month`
- `day`

Dates can be cleaned and included, but **time does not need to be the main analysis axis**.

---

## 6. Final research questions

Use 3 main questions.

### Q1
**Do fish from lakes with higher DOC have different trophic positions?**

Plain English:
Do fish in browner lakes sit higher or lower in the food chain?

### Q2
**Do fish from lakes with higher DOC have different pelagic diet proportions?**

Plain English:
Do fish in browner lakes rely more or less on open-water food?

### Q3
**Do these DOC relationships differ across fish species or across regions?**

Plain English:
Does the pattern look the same for every kind of fish, or do some species respond differently?

---

## 7. Final project claim you are trying to test
A simple central claim:

**Lake browning (higher DOC) is associated with changes in fish diet and food-chain structure.**

Your analysis does **not** need to prove causation.
It only needs to show clear descriptive patterns from the dataset.

---

## 8. High-level workflow for the whole project

## Phase 1: Repo and file setup
Create a project repo that looks like this:

```text
project_repo/
  README.md
  data/
    fish_data.csv
    baseline_data.csv
    source_article.pdf
  analysis/
    01_data_cleaning.Rmd
    02_eda.Rmd
    03_core_analysis.Rmd
    04_mapping.Rmd
  shiny_app/
    app.R
  figures/
  presentation/
```

### Goal of this phase
Set up a clean structure so your project looks complete and organized.

---

## Phase 2: Import and inspect data
### High-level goal
Read the files into R and understand what is in them.

### Course syntax to use
```r
library(tidyverse)
library(janitor)

fish <- read_csv("data/fish_data.csv", na = c("", "NA", "-999")) %>%
  clean_names()

baseline <- read_csv("data/baseline_data.csv", na = c("", "NA", "-999")) %>%
  clean_names()

names(fish)
dim(fish)
glimpse(fish)
summary(fish)

names(baseline)
dim(baseline)
glimpse(baseline)
summary(baseline)
```

### What you are checking here
- how many rows and columns
- what the column names are
- which columns are numeric vs character
- whether missing values exist
- whether the variable names match what you expect

---

## Phase 3: Clean the data
### High-level goal
Make the dataset easier to analyze and plotting-ready.

### Main tasks
- standardize column names
- make factors where needed
- parse dates if needed
- convert sentinel missing values to `NA`
- create any simplified grouping variables

### Course syntax to use
```r
fish_clean <- fish %>%
  mutate(
    fish_species = as.factor(fish_species),
    lake = as.factor(lake),
    region = as.factor(region)
  )
```

If date columns are separate:
```r
fish_clean <- fish_clean %>%
  mutate(sample_date = make_date(year, month, day))
```

If you want a DOC category for easier plots:
```r
fish_clean <- fish_clean %>%
  mutate(doc_level = case_when(
    doc_mg_l < 5 ~ "low_doc",
    doc_mg_l < 10 ~ "medium_doc",
    TRUE ~ "high_doc"
  ))
```

Then optionally:
```r
fish_clean <- fish_clean %>%
  mutate(doc_level = factor(doc_level, levels = c("low_doc", "medium_doc", "high_doc")))
```

### Why make `doc_level`
Because some plots are easier to understand when DOC is grouped into low / medium / high instead of always treated as a raw number.

---

## Phase 4: Missingness check / QA block
### High-level goal
Show that you checked for missing values before analyzing.

### Course syntax to use
Basic version:
```r
colSums(is.na(fish_clean))
```

Or for key analysis variables:
```r
fish_clean %>%
  select(doc_mg_l, fish_species, length_mm, pelagic_diet_proportion, trophic_position) %>%
  summary()
```

If you want a simple table of complete rows:
```r
fish_clean %>%
  filter(
    !is.na(doc_mg_l),
    !is.na(fish_species),
    !is.na(pelagic_diet_proportion),
    !is.na(trophic_position)
  )
```

### What to write in words
“We removed rows with missing values only when those values were required for a particular plot or summary, rather than dropping all rows at once.”

---

## Phase 5: Join the tables if needed
### High-level goal
Combine fish-level data with lake-level baseline data if the two tables are separate.

### Course syntax to use
```r
fish_joined <- left_join(fish_clean, baseline, by = c("lake", "region"))
```

If the join keys are different:
```r
fish_joined <- left_join(fish_clean, baseline, by = c("lake_id" = "lake_id"))
```

### What to verify after joining
```r
dim(fish_clean)
dim(fish_joined)
glimpse(fish_joined)
```

### Main caution
Do not blindly join until you know which columns match between the two files.

---

## Phase 6: Build a compact analysis dataset
### High-level goal
Create one clean dataset that only contains the columns you will actually use.

### Course syntax to use
```r
analysis_df <- fish_joined %>%
  select(
    lake, region, fish_species, year, month, day,
    latitude, longitude,
    doc_mg_l, length_mm,
    d13c, d15n, c_n,
    pelagic_diet_proportion, trophic_position,
    doc_level
  )
```

### Why this helps
It makes your later code much cleaner and easier to debug.

---

## Phase 7: EDA block
### High-level goal
Understand the dataset before making claims.

## EDA Question 1
How many lakes, species, and regions are represented?

### Syntax
```r
analysis_df %>% count(lake)
analysis_df %>% count(fish_species)
analysis_df %>% count(region)
analysis_df %>% summarize(
  n_lakes = n_distinct(lake),
  n_species = n_distinct(fish_species),
  n_regions = n_distinct(region)
)
```

## EDA Question 2
What do the key numeric variables look like?

### Syntax
```r
analysis_df %>%
  summarize(
    mean_doc = mean(doc_mg_l, na.rm = TRUE),
    mean_length = mean(length_mm, na.rm = TRUE),
    mean_pelagic = mean(pelagic_diet_proportion, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE)
  )
```

## EDA Plot 1: DOC distribution
```r
ggplot(analysis_df, aes(x = doc_mg_l)) +
  geom_histogram() +
  labs(
    title = "Distribution of DOC across fish samples",
    x = "DOC (mg/L)",
    y = "Count"
  )
```

## EDA Plot 2: Fish size distribution by species
```r
ggplot(analysis_df, aes(x = fish_species, y = length_mm, fill = fish_species)) +
  geom_boxplot() +
  labs(
    title = "Fish length by species",
    x = "Species",
    y = "Length (mm)"
  ) +
  theme_minimal()
```

### What this EDA section does
- shows dataset coverage
- shows whether some species are much more common than others
- shows whether variables are spread out enough to analyze

---

## Phase 8: Core analysis block
This is the most important section.

You should make **4-6 main plots** tied directly to your questions.

## Core Plot 1
### DOC vs trophic position
### Question answered
Do fish in browner lakes sit at different food-chain positions?

```r
ggplot(
  analysis_df %>% filter(!is.na(doc_mg_l), !is.na(trophic_position)),
  aes(x = doc_mg_l, y = trophic_position)
) +
  geom_point(alpha = 0.7) +
  labs(
    title = "DOC vs trophic position",
    x = "DOC (mg/L)",
    y = "Trophic position"
  ) +
  theme_minimal()
```

## Core Plot 2
### DOC vs pelagic diet proportion
### Question answered
Do fish in browner lakes depend more or less on open-water food?

```r
ggplot(
  analysis_df %>% filter(!is.na(doc_mg_l), !is.na(pelagic_diet_proportion)),
  aes(x = doc_mg_l, y = pelagic_diet_proportion)
) +
  geom_point(alpha = 0.7) +
  labs(
    title = "DOC vs pelagic diet proportion",
    x = "DOC (mg/L)",
    y = "Pelagic diet proportion"
  ) +
  theme_minimal()
```

## Core Plot 3
### Trophic position by species
### Question answered
Do different fish species sit at different parts of the food chain?

```r
ggplot(
  analysis_df %>% filter(!is.na(fish_species), !is.na(trophic_position)),
  aes(x = fish_species, y = trophic_position, fill = fish_species)
) +
  geom_boxplot() +
  labs(
    title = "Trophic position by fish species",
    x = "Fish species",
    y = "Trophic position"
  ) +
  theme_minimal()
```

## Core Plot 4
### Pelagic diet proportion by species
### Question answered
Do some species rely more on open-water feeding than others?

```r
ggplot(
  analysis_df %>% filter(!is.na(fish_species), !is.na(pelagic_diet_proportion)),
  aes(x = fish_species, y = pelagic_diet_proportion, fill = fish_species)
) +
  geom_boxplot() +
  labs(
    title = "Pelagic diet proportion by fish species",
    x = "Fish species",
    y = "Pelagic diet proportion"
  ) +
  theme_minimal()
```

## Core Plot 5
### Mean trophic position by DOC category
### Question answered
Does average food-chain position differ across low / medium / high DOC lakes?

```r
doc_summary <- analysis_df %>%
  group_by(doc_level) %>%
  summarize(
    n = n(),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    sd_trophic = sd(trophic_position, na.rm = TRUE),
    .groups = "drop"
  )

ggplot(doc_summary, aes(x = doc_level, y = mean_trophic, fill = doc_level)) +
  geom_col() +
  labs(
    title = "Mean trophic position by DOC category",
    x = "DOC category",
    y = "Mean trophic position"
  ) +
  theme_minimal()
```

## Core Plot 6
### Species-specific DOC pattern
### Question answered
Do DOC patterns differ by species?

```r
ggplot(
  analysis_df %>% filter(!is.na(doc_mg_l), !is.na(trophic_position), !is.na(fish_species)),
  aes(x = doc_mg_l, y = trophic_position, color = fish_species)
) +
  geom_point(alpha = 0.7) +
  facet_wrap(~ fish_species) +
  labs(
    title = "DOC vs trophic position by species",
    x = "DOC (mg/L)",
    y = "Trophic position"
  ) +
  theme_minimal()
```

---

## Phase 9: Summary tables
### High-level goal
Back up the plots with clear grouped summaries.

## Table 1: species summary
```r
species_summary <- analysis_df %>%
  group_by(fish_species) %>%
  summarize(
    n = n(),
    mean_doc = mean(doc_mg_l, na.rm = TRUE),
    mean_length = mean(length_mm, na.rm = TRUE),
    mean_pelagic = mean(pelagic_diet_proportion, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    .groups = "drop"
  )
```

## Table 2: lake summary
```r
lake_summary <- analysis_df %>%
  group_by(lake, region) %>%
  summarize(
    n = n(),
    mean_doc = mean(doc_mg_l, na.rm = TRUE),
    mean_pelagic = mean(pelagic_diet_proportion, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    .groups = "drop"
  )
```

## Table 3: DOC category summary
```r
doc_level_summary <- analysis_df %>%
  group_by(doc_level) %>%
  summarize(
    n = n(),
    mean_pelagic = mean(pelagic_diet_proportion, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    .groups = "drop"
  )
```

### Why these tables matter
They let you say concrete things like:
- which species tend to be higher in the food chain
- which lakes are browner
- whether high DOC groups differ on average

---

## Phase 10: Mapping block
Do this only if the final data includes latitude and longitude.

### High-level goal
Show where the lakes are and whether spatial patterns exist.

### Course syntax to use
```r
library(leaflet)

leaflet(analysis_df %>% distinct(lake, latitude, longitude, doc_mg_l)) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~longitude,
    lat = ~latitude,
    popup = ~lake
  )
```

### Better version if you want lake-level means first
```r
lake_map_df <- analysis_df %>%
  group_by(lake, latitude, longitude) %>%
  summarize(
    mean_doc = mean(doc_mg_l, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    .groups = "drop"
  )

leaflet(lake_map_df) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~longitude,
    lat = ~latitude,
    popup = ~lake
  )
```

### What map figures to save
- map of all lakes
- maybe one map colored or labeled by DOC summary if you learn that syntax
- if not, a plain site-location map is enough for the course scope

---

## Phase 11: Shiny app design
Your app should be simple and directly tied to your questions.

## Recommended app idea
A fish ecology explorer app.

### User inputs
- species selector
- metric selector
- optional region selector

### Reactive outputs
- 1 plot
- 1 summary table

## High-level app behavior
The user chooses a species and a metric.
The app filters the data and then shows:
- a plot involving DOC and the chosen metric
- a summary table with the mean of the chosen metric

## Simple Shiny structure
```r
library(shiny)
library(tidyverse)

ui <- fluidPage(
  titlePanel("DOC and Fish Ecology"),
  sidebarLayout(
    sidebarPanel(
      selectInput("species_choice", "Choose species", choices = unique(analysis_df$fish_species)),
      selectInput("metric_choice", "Choose metric",
                  choices = c("trophic_position", "pelagic_diet_proportion", "length_mm"))
    ),
    mainPanel(
      plotOutput("scatter_plot"),
      tableOutput("summary_table")
    )
  )
)

server <- function(input, output) {
  filtered_df <- reactive({
    analysis_df %>%
      filter(fish_species == input$species_choice) %>%
      filter(!is.na(doc_mg_l), !is.na(.data[[input$metric_choice]]))
  })

  output$scatter_plot <- renderPlot({
    ggplot(filtered_df(), aes(x = doc_mg_l, y = .data[[input$metric_choice]])) +
      geom_point() +
      labs(
        title = "DOC vs selected metric",
        x = "DOC (mg/L)",
        y = input$metric_choice
      ) +
      theme_minimal()
  })

  output$summary_table <- renderTable({
    filtered_df() %>%
      summarize(
        n = n(),
        mean_metric = mean(.data[[input$metric_choice]], na.rm = TRUE)
      )
  })
}

shinyApp(ui = ui, server = server)
```

### Why this app works for BIS 15L
It satisfies:
- at least one input
- reactive filtering
- reactive plot
- reactive table
- direct connection to your main biological story

---

## Phase 12: Interpretation block
### High-level goal
Explain what the patterns mean in plain English.

For each main plot, write 2-4 sentences:
1. what the plot shows
2. whether the pattern looks strong/weak/mixed
3. what that might biologically mean
4. one limitation

### Example interpretation sentence
“If trophic position tends to decrease as DOC increases, that suggests fish in browner lakes may occupy a different part of the food web than fish in clearer lakes.”

### Limitation examples
- this is observational data, not an experiment
- species are not evenly represented across all lakes
- some lakes may have more samples than others
- chemistry-based derived variables have assumptions behind them

---

## Phase 13: Presentation plan
Make the presentation follow one simple arc.

## Slide 1: Title
Project title + group names

## Slide 2: Background
What is DOC?
Why does lake browning matter biologically?

## Slide 3: Dataset
Where the data came from
What kinds of variables it includes
How many lakes / species / regions

## Slide 4: Questions
List your 3 main research questions

## Slide 5: Cleaning + workflow
Very short:
- imported files
- cleaned names
- handled missing values
- joined data
- grouped and visualized

## Slides 6-8: Main results
Put your strongest 3-4 plots here

## Slide 9: Map
Show where the lakes are

## Slide 10: Shiny app
Show a screenshot and say what the user can explore

## Slide 11: Limitations
Observational data, sample imbalance, etc.

## Slide 12: Conclusion
What you found overall

---

## 14. Exact deliverables checklist
You should aim to finish these items:

- [ ] approved dataset in `data/`
- [ ] source article in `data/`
- [ ] one main integrated analysis `.Rmd`
- [ ] optional extra EDA `.Rmd`
- [ ] saved figures in `figures/`
- [ ] one Shiny app in `shiny_app/`
- [ ] `README.md`
- [ ] final presentation slides

---

## 15. What each Rmd should contain

## A) 01_data_cleaning.Rmd
Include:
- load packages
- read files
- clean names
- inspect dimensions
- inspect missingness
- join tables if needed
- save cleaned data

Useful syntax:
```r
write_csv(analysis_df, "data/analysis_df.csv")
```

## B) 02_eda.Rmd
Include:
- counts of lakes/species/regions
- summary statistics
- 2-3 exploratory plots

## C) 03_core_analysis.Rmd
Include:
- all primary research-question plots
- grouped summary tables
- written interpretation

## D) 04_mapping.Rmd
Include:
- lake location map
- optional lake-level summary map

---

## 16. Recommended order to actually execute the work
Follow this order exactly.

### Step 1
Download the dataset and article.
Put them in `data/`.

### Step 2
Import both CSV files.
Use `read_csv()` and `clean_names()`.

### Step 3
Inspect the data with:
```r
names()
dim()
glimpse()
summary()
```

### Step 4
Decide the exact join key between the two tables.

### Step 5
Create `fish_clean`, then `fish_joined`, then `analysis_df`.

### Step 6
Check missingness in the key variables.

### Step 7
Make 2 EDA plots.

### Step 8
Make the 6 core analysis plots.

### Step 9
Build grouped summary tables.

### Step 10
Make the map if coordinates are available.

### Step 11
Build the Shiny app.

### Step 12
Save final figures.

### Step 13
Write the README.

### Step 14
Build the presentation.

---

## 17. Minimum version vs strong version

## Minimum version
If time gets tight, you still need:
- 1 cleaned dataset
- 3 strong plots
- 1 summary table
- 1 Shiny app
- 1 presentation
- interpretation

## Strong version
If you want a GOBY-like stronger version:
- 2 source tables joined cleanly
- 5-6 polished plots
- 2-3 grouped summary tables
- 1 map
- 1 polished Shiny app with filters
- strong README and clear repo structure

---

## 18. Main code patterns you will reuse the most
These are the patterns you will probably use over and over.

## Import + clean
```r
df <- read_csv("data/file.csv", na = c("", "NA", "-999")) %>%
  clean_names()
```

## Select columns
```r
df %>% select(col1, col2, col3)
```

## Filter rows
```r
df %>% filter(!is.na(x), group == "value")
```

## Create new variable
```r
df %>% mutate(new_var = a / b)
```

## Grouped summary
```r
df %>%
  group_by(group_var) %>%
  summarize(mean_x = mean(x, na.rm = TRUE), n = n())
```

## Join two tables
```r
left_join(df1, df2, by = "id")
```

## Scatterplot
```r
ggplot(df, aes(x = x, y = y)) + geom_point()
```

## Boxplot
```r
ggplot(df, aes(x = group, y = value, fill = group)) + geom_boxplot()
```

## Faceting
```r
ggplot(df, aes(x = x, y = y, color = group)) +
  geom_point() +
  facet_wrap(~ group)
```

## Shiny reactive filter
```r
filtered_df <- reactive({
  df %>% filter(group == input$group_choice)
})
```

---

## 19. Final recommended wording for your project
Use this wording in your proposal or README:

**We used a freshwater fish stable-isotope dataset spanning multiple lakes to test whether dissolved organic carbon (DOC), a measure of lake browning, is associated with differences in fish diet and trophic position. We combined data cleaning, grouped summaries, visualization, mapping, and a Shiny app to explore how these ecological patterns vary across fish species and lakes.**

---

## 20. Bottom line
If you follow this plan, your project will include:
- the required dataset/article structure
- a clear biological story
- categorical + continuous variables
- wrangling
- EDA
- core analysis
- map
- Shiny app
- presentation

That is exactly the kind of complete, course-aligned project you want.