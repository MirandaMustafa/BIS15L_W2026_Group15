library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)

clean_names_simple <- function(x) {
  x <- gsub("[^A-Za-z0-9]+", "_", x)
  x <- gsub("_+", "_", x)
  x <- gsub("^_|_$", "", x)
  tolower(x)
}

fish_path <- "../data/Charetteetal2024_CJFAS_Fish.csv"
baseline_path <- "../data/Charetteetal2024_CJFAS_Baselines_DOC.csv"

fish <- read_csv(fish_path, na = c("", "NA", "-999"), show_col_types = FALSE)
baseline <- read_csv(baseline_path, na = c("", "NA", "-999"), show_col_types = FALSE)

names(fish) <- clean_names_simple(names(fish))
names(baseline) <- clean_names_simple(names(baseline))

fish_clean <- fish %>%
  mutate(
    fish_species = as.factor(fish_species),
    lake = as.factor(lake),
    region = as.factor(region),
    sample_date = make_date(year, month, day),
    doc_level = case_when(
      doc_mgl < 5 ~ "low_doc",
      doc_mgl < 10 ~ "medium_doc",
      TRUE ~ "high_doc"
    ),
    doc_level = factor(doc_level, levels = c("low_doc", "medium_doc", "high_doc"))
  )

# Baseline table has one row per lake in this dataset.
fish_joined <- fish_clean %>%
  left_join(
    baseline %>%
      select(
        lake,
        baseline_av_pelagic_d13c = av_pelagic_d13c,
        baseline_av_pelagic_d15n = av_pelagic_d15n,
        baseline_av_benthic_d13c = av_benthic_d13c,
        baseline_av_benthic_d15n = av_benthic_d15n,
        d13c_baselinedifference
      ),
    by = "lake"
  )

analysis_df <- fish_joined %>%
  select(
    datasource, lake, region, fish_species, sampleid,
    year, month, day, sample_date,
    latitude, longitude,
    doc_mgl, doc_level,
    length_mm, d13c, d15n, c_n,
    av_pelagic_d13c, av_pelagic_d15n,
    av_benthic_d13c, av_benthic_d15n,
    d13ccorr_lipids,
    pelagic_diet_proportion, trophic_position,
    baseline_av_pelagic_d13c, baseline_av_pelagic_d15n,
    baseline_av_benthic_d13c, baseline_av_benthic_d15n,
    d13c_baselinedifference
  )

write_csv(analysis_df, "../data/analysis_df.csv")

missingness_summary <- analysis_df %>%
  summarize(
    across(
      c(doc_mgl, length_mm, pelagic_diet_proportion, trophic_position, d13c, d15n, c_n),
      ~ sum(is.na(.x))
    )
  ) %>%
  tidyr::pivot_longer(everything(), names_to = "variable", values_to = "missing_n")
write_csv(missingness_summary, "../output_tables/missingness_summary.csv")

coverage_summary <- analysis_df %>%
  summarize(
    n_rows = n(),
    n_lakes = n_distinct(lake),
    n_species = n_distinct(fish_species),
    n_regions = n_distinct(region),
    year_min = min(year, na.rm = TRUE),
    year_max = max(year, na.rm = TRUE)
  )
write_csv(coverage_summary, "../output_tables/coverage_summary.csv")

numeric_summary <- analysis_df %>%
  summarize(
    mean_doc = mean(doc_mgl, na.rm = TRUE),
    mean_length = mean(length_mm, na.rm = TRUE),
    mean_pelagic = mean(pelagic_diet_proportion, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE)
  )
write_csv(numeric_summary, "../output_tables/numeric_summary.csv")

species_summary <- analysis_df %>%
  group_by(fish_species) %>%
  summarize(
    n = n(),
    mean_doc = mean(doc_mgl, na.rm = TRUE),
    mean_length = mean(length_mm, na.rm = TRUE),
    mean_pelagic = mean(pelagic_diet_proportion, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(species_summary, "../output_tables/species_summary.csv")

lake_summary <- analysis_df %>%
  group_by(lake, region) %>%
  summarize(
    n = n(),
    mean_doc = mean(doc_mgl, na.rm = TRUE),
    mean_pelagic = mean(pelagic_diet_proportion, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(lake_summary, "../output_tables/lake_summary.csv")

doc_level_summary <- analysis_df %>%
  group_by(doc_level) %>%
  summarize(
    n = n(),
    mean_pelagic = mean(pelagic_diet_proportion, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(doc_level_summary, "../output_tables/doc_level_summary.csv")

plot_theme <- theme_minimal(base_size = 12)

p1 <- ggplot(analysis_df, aes(x = doc_mgl)) +
  geom_histogram(bins = 30, fill = "#4B8BBE", color = "white") +
  labs(
    title = "Distribution of DOC across fish samples",
    x = "DOC (mg/L)",
    y = "Count"
  ) +
  plot_theme

ggsave("../figures/eda_01_doc_distribution.png", p1, width = 8, height = 5, dpi = 300)

p2 <- ggplot(analysis_df, aes(x = fish_species, y = length_mm, fill = fish_species)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.4) +
  labs(
    title = "Fish length by species",
    x = "Fish species",
    y = "Length (mm)"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave("../figures/eda_02_length_by_species.png", p2, width = 8, height = 5, dpi = 300)

p3 <- ggplot(analysis_df, aes(x = doc_mgl, y = trophic_position)) +
  geom_point(alpha = 0.45, color = "#1f78b4") +
  geom_smooth(method = "lm", se = FALSE, color = "#d95f02", linewidth = 1) +
  labs(
    title = "DOC vs trophic position",
    x = "DOC (mg/L)",
    y = "Trophic position"
  ) +
  plot_theme

ggsave("../figures/core_01_doc_vs_trophic.png", p3, width = 8, height = 5, dpi = 300)

p4 <- ggplot(analysis_df, aes(x = doc_mgl, y = pelagic_diet_proportion)) +
  geom_point(alpha = 0.45, color = "#33a02c") +
  geom_smooth(method = "lm", se = FALSE, color = "#e31a1c", linewidth = 1) +
  labs(
    title = "DOC vs pelagic diet proportion",
    x = "DOC (mg/L)",
    y = "Pelagic diet proportion"
  ) +
  plot_theme

ggsave("../figures/core_02_doc_vs_pelagic.png", p4, width = 8, height = 5, dpi = 300)

p5 <- ggplot(analysis_df, aes(x = fish_species, y = trophic_position, fill = fish_species)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.4) +
  labs(
    title = "Trophic position by fish species",
    x = "Fish species",
    y = "Trophic position"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave("../figures/core_03_trophic_by_species.png", p5, width = 8, height = 5, dpi = 300)

p6 <- ggplot(analysis_df, aes(x = fish_species, y = pelagic_diet_proportion, fill = fish_species)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.4) +
  labs(
    title = "Pelagic diet proportion by fish species",
    x = "Fish species",
    y = "Pelagic diet proportion"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave("../figures/core_04_pelagic_by_species.png", p6, width = 8, height = 5, dpi = 300)

p7 <- ggplot(doc_level_summary, aes(x = doc_level, y = mean_trophic, fill = doc_level)) +
  geom_col(alpha = 0.9) +
  labs(
    title = "Mean trophic position by DOC category",
    x = "DOC category",
    y = "Mean trophic position"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave("../figures/core_05_mean_trophic_by_doc_level.png", p7, width = 8, height = 5, dpi = 300)

p8 <- ggplot(analysis_df, aes(x = doc_mgl, y = trophic_position, color = fish_species)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  facet_wrap(~ fish_species) +
  labs(
    title = "DOC vs trophic position by species",
    x = "DOC (mg/L)",
    y = "Trophic position",
    color = "Species"
  ) +
  plot_theme

ggsave("../figures/core_06_doc_vs_trophic_by_species.png", p8, width = 10, height = 7, dpi = 300)

lake_map_df <- analysis_df %>%
  group_by(lake, latitude, longitude) %>%
  summarize(
    mean_doc = mean(doc_mgl, na.rm = TRUE),
    mean_trophic = mean(trophic_position, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(latitude), !is.na(longitude))

write_csv(lake_map_df, "../output_tables/lake_map_df.csv")

p9 <- ggplot(lake_map_df, aes(x = longitude, y = latitude, color = mean_doc)) +
  geom_point(size = 2.8, alpha = 0.9) +
  scale_color_viridis_c(option = "magma") +
  coord_quickmap() +
  labs(
    title = "Lake locations colored by mean DOC",
    x = "Longitude",
    y = "Latitude",
    color = "Mean DOC"
  ) +
  plot_theme

ggsave("../figures/map_01_lake_locations_doc.png", p9, width = 8, height = 5, dpi = 300)

top_doc <- lake_map_df %>%
  arrange(desc(mean_doc)) %>%
  slice_head(n = 12)

p10 <- ggplot(top_doc, aes(x = longitude, y = latitude, label = lake, size = mean_trophic)) +
  geom_point(color = "#2c7fb8", alpha = 0.8) +
  geom_text(check_overlap = TRUE, hjust = 0, nudge_x = 0.15, size = 3) +
  coord_quickmap() +
  labs(
    title = "Top DOC lakes with mean trophic position",
    x = "Longitude",
    y = "Latitude",
    size = "Mean trophic"
  ) +
  plot_theme

ggsave("../figures/map_02_top_doc_lakes.png", p10, width = 9, height = 5, dpi = 300)

cat("Project outputs generated in data/, figures/, and output_tables/.\n")
