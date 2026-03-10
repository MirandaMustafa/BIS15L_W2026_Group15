# BIS 15L Labs 1-16: High-Level Concepts and Core Syntax Guide

This guide summarizes the main ideas and coding patterns across Labs 1-16.
It is designed to be deeper than a quick cheat sheet while staying focused on the most reusable syntax.

## 1) Big Picture: What You Learned Across the Sequence

The course builds a full analysis workflow:

1. Set up reproducible projects in R/RMarkdown and GitHub.
2. Import and inspect data.
3. Clean names, types, and missing values.
4. Wrangle data with tidyverse verbs (`select`, `filter`, `mutate`, `group_by`, `summarize`, joins).
5. Reshape untidy data (`pivot_longer`, `pivot_wider`, `separate`, `unite`).
6. Visualize with `ggplot2` (basic to advanced).
7. Build interactive apps (`shiny`, dashboards, reactive inputs/outputs).
8. Work with geospatial data (`ggmap`, `leaflet`).
9. Extend into command line and bioinformatics workflows (Lab 16).

The repeated pattern in most labs/homeworks is:

```r
read_csv(...) %>%
  clean_names() %>%
  mutate(...) %>%
  filter(...) %>%
  group_by(...) %>%
  summarize(...) %>%
  ggplot(...)
```

## 2) Lab-by-Lab Map (Concept + Representative Syntax)

## Lab 1: Setup, workflow, and reproducibility
- Concept: RStudio + RMarkdown + GitHub workflow; package/session setup.
- Syntax patterns:
```r
install.packages("tidyverse")
library(tidyverse)
sessionInfo()
```

## Lab 2: Objects, types, missing data, directories
- Concept: Class/type awareness, NA detection, working directory management.
- Syntax patterns:
```r
getwd()
setwd("path/to/folder")
class(x)
is.na(x)
anyNA(df)
```

## Lab 3: Importing and inspecting tabular data
- Concept: CSV import and structural data audit.
- Syntax patterns:
```r
df <- read_csv("data/file.csv")
names(df); dim(df); nrow(df); ncol(df)
head(df); tail(df); glimpse(df); summary(df); str(df)
df <- df %>% mutate(category = as.factor(category))
write.csv(df, "data/clean.csv", row.names = FALSE)
```

## Lab 4: ggplot fundamentals
- Concept: Mapping variables to aesthetics and choosing geoms by variable type.
- Syntax patterns:
```r
ggplot(df, aes(x = xvar, y = yvar)) +
  geom_point() +
  labs(title = "Title", x = "X Label", y = "Y Label")
```

## Lab 5: Selecting/filtering/sorting
- Concept: Column and row subsetting to isolate relevant observations.
- Syntax patterns:
```r
df %>% select(col1, col2, starts_with("bill"), where(is.numeric))
df %>% filter(species == "Adelie", between(body_mass_g, 4000, 5500))
df %>% arrange(desc(body_mass_g))
```

## Lab 6: Cleaning + feature engineering
- Concept: Standardized names and creating biologically meaningful derived variables.
- Syntax patterns:
```r
library(janitor)
df <- df %>% clean_names()
df <- df %>% mutate(new_var = a / b)
df <- df %>% mutate(flag = if_else(score > 10, "high", "low"))
df <- df %>% mutate(across(where(is.character), as.factor))
```

## Lab 7: Grouped summaries
- Concept: Aggregation by category for descriptive inference.
- Syntax patterns:
```r
df %>%
  group_by(group_var) %>%
  summarize(
    n = n(),
    mean_x = mean(x, na.rm = TRUE),
    sd_x = sd(x, na.rm = TRUE)
  )
```

## Lab 8: Efficient grouped pipelines on larger data
- Concept: Combine cleaning + grouping + summarization at scale.
- Syntax patterns:
```r
df %>%
  group_by(group1, group2) %>%
  summarize(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))
```

## Lab 9: Tidy data reshaping
- Concept: Convert between wide/long forms so each variable has a column and each observation has a row.
- Syntax patterns:
```r
long_df <- wide_df %>%
  pivot_longer(cols = starts_with("wk"),
               names_to = "week",
               values_to = "value")

wide_df <- long_df %>%
  pivot_wider(names_from = metric, values_from = value)

df %>% separate(patient, into = c("id", "sex"), sep = "_")
df %>% unite("sample_id", patient, day, sep = "_")
```

## Lab 10: Intermediate plotting and encoding categories
- Concept: Improve interpretability via scales, grouping, and explicit factor control.
- Syntax patterns:
```r
df <- df %>% mutate(class = factor(class, levels = c("aves", "mammalia")))
ggplot(df, aes(x = class, y = log10_mass, fill = trophic_guild)) +
  geom_boxplot() +
  scale_y_log10()
```

## Lab 11: Advanced visualization and faceting
- Concept: Distribution comparison, palettes/themes, multi-panel plots.
- Syntax patterns:
```r
ggplot(df, aes(x = value, fill = group)) +
  geom_histogram(alpha = 0.7) +
  facet_wrap(~ group) +
  theme_minimal()

df %>%
  mutate(income_category = case_when(
    gdp < 2000 ~ "Low",
    gdp < 15000 ~ "Middle",
    TRUE ~ "High"
  ))
```

## Lab 12: Analysis planning and AI-assisted workflow
- Concept: Good analysis starts with clear questions, reproducible structure, and explicit assumptions before coding.
- Syntax emphasis: reuse earlier core verbs with better planning and communication.

## Lab 13: Missing data, joins, and date parsing
- Concept: Diagnose/standardize missingness, merge related tables, manage date formats.
- Syntax patterns:
```r
df <- read_csv("data/file.csv", na = c("", "NA", "-999")) %>% clean_names()
df <- df %>% mutate(max_life = na_if(max_life, 0))

joined <- left_join(table_a, table_b, by = "customer_id")
inner <- inner_join(table_a, table_b, by = "customer_id")

library(lubridate)
dates1 <- ymd("2025-01-31")
dates2 <- mdy("01/31/2025")
```

## Lab 14: Geospatial + intro Shiny
- Concept: Static maps, interactive map layers, and first reactive app architecture.
- Syntax patterns:
```r
library(leaflet)
leaflet(df) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~longitude, lat = ~latitude)
```

```r
library(shiny)
ui <- fluidPage(selectInput("x", "X variable", choices = names(df)),
                plotOutput("p"))
server <- function(input, output) {
  output$p <- renderPlot({
    ggplot(df, aes_string(x = input$x)) + geom_bar()
  })
}
shinyApp(ui, server)
```

## Lab 15: Shiny dashboards and reactive analysis products
- Concept: Build complete apps where user inputs drive filtered data, plots, and tables.
- Syntax patterns:
```r
ui <- dashboardPage(
  dashboardHeader(title = "App"),
  dashboardSidebar(selectInput("metric", "Metric", choices = c("a", "b"))),
  dashboardBody(plotOutput("plot1"), tableOutput("table1"))
)

server <- function(input, output) {
  filtered <- reactive({
    df %>% filter(!is.na(.data[[input$metric]]))
  })
  output$plot1 <- renderPlot({
    ggplot(filtered(), aes(x = .data[[input$metric]])) + geom_histogram()
  })
  output$table1 <- renderTable({
    filtered() %>% summarize(mean_val = mean(.data[[input$metric]], na.rm = TRUE))
  })
}
```

## Lab 16: Command line + NCBI/BLAST + sequence handling
- Concept:
1. Use shell commands to navigate and organize project files reproducibly.
2. Use NCBI BLAST to identify unknown sequences.
3. Read and inspect FASTA/sequence outputs in R.
- Shell syntax patterns:
```bash
pwd            # print working directory
ls -lh         # list files (long, human readable)
cd lab16       # move between directories
mkdir data     # create directory
mv *.fasta data/   # move files by wildcard
head file.txt
tail file.txt
grep "pattern" file.txt
```
- R sequence-analysis setup pattern:
```r
library(tidyverse)
library(janitor)
library(readr)
library(Biostrings)
```

## 3) Core Syntax by Function Family (Most Reusable)

## A) Import, inspect, and clean
```r
df <- read_csv("data/file.csv", na = c("", "NA", "-999")) %>% clean_names()
glimpse(df)
summary(df)
```

## B) Core dplyr grammar
```r
df %>% select(...)
df %>% filter(...)
df %>% mutate(...)
df %>% arrange(...)
df %>% distinct(...)
df %>% count(group_var)
```

## C) Grouped summaries
```r
df %>%
  group_by(group_var) %>%
  summarize(
    n = n(),
    mean_x = mean(x, na.rm = TRUE),
    med_x = median(x, na.rm = TRUE)
  )
```

## D) Reshaping
```r
pivot_longer(...)
pivot_wider(...)
separate(...)
unite(...)
```

## E) Joining datasets
```r
left_join(x, y, by = "id")   # keep all rows in x
inner_join(x, y, by = "id")  # keep matched rows only
```

## F) Visualization grammar
```r
ggplot(df, aes(x = x, y = y, color = group)) +
  geom_point() +
  facet_wrap(~ group) +
  labs(title = "Plot title") +
  theme_minimal()
```

## G) Reactivity (Shiny)
```r
filtered <- reactive({ df %>% filter(group == input$group_choice) })
output$plot <- renderPlot({ ggplot(filtered(), aes(x = x, y = y)) + geom_point() })
```

## 4) High-Level Conceptual Skills to Carry Forward

1. Treat analysis as a pipeline, not isolated commands.
2. Make data tidy before plotting/modeling.
3. Be explicit about missing data and type conversion.
4. Summarize by groups before making claims.
5. Match plot type to question and variable type.
6. Build reproducible projects: clear file structure, script history, and documented outputs.
7. Use command line tools for scalable data/file handling.
8. In bioinformatics contexts, combine sequence search tools (BLAST) with tidy analysis in R.

## 5) A Practical Template for Exams/Homework

```r
library(tidyverse)
library(janitor)

df <- read_csv("data/input.csv", na = c("", "NA", "-999")) %>%
  clean_names()

df_clean <- df %>%
  mutate(
    category = as.factor(category),
    new_metric = value1 / value2
  ) %>%
  filter(!is.na(new_metric))

summary_tbl <- df_clean %>%
  group_by(category) %>%
  summarize(
    n = n(),
    mean_metric = mean(new_metric, na.rm = TRUE),
    .groups = "drop"
  )

ggplot(df_clean, aes(x = category, y = new_metric, fill = category)) +
  geom_boxplot() +
  labs(title = "New Metric by Category", x = "Category", y = "New Metric")
```

If you can run this pattern cleanly and adapt it to the prompt, you are applying the core skills from Labs 1-16.
