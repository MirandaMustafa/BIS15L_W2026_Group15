library(shiny)
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

build_analysis_df <- function() {
  fish <- read_csv("../data/Charetteetal2024_CJFAS_Fish.csv", na = c("", "NA", "-999"), show_col_types = FALSE)
  baseline <- read_csv("../data/Charetteetal2024_CJFAS_Baselines_DOC.csv", na = c("", "NA", "-999"), show_col_types = FALSE)

  names(fish) <- clean_names_simple(names(fish))
  names(baseline) <- clean_names_simple(names(baseline))

  fish %>%
    mutate(
      fish_species = as.factor(fish_species),
      lake = as.factor(lake),
      region = as.factor(region),
      sample_date = make_date(year, month, day),
      doc_level = case_when(
        doc_mgl < 5 ~ "low_doc",
        doc_mgl < 10 ~ "medium_doc",
        TRUE ~ "high_doc"
      )
    ) %>%
    left_join(
      baseline %>%
        select(
          lake,
          baseline_av_pelagic_d13c = av_pelagic_d13c,
          baseline_av_pelagic_d15n = av_pelagic_d15n,
          baseline_av_benthic_d13c = av_benthic_d13c,
          baseline_av_benthic_d15n = av_benthic_d15n
        ),
      by = "lake"
    )
}

analysis_df <- if (file.exists("../data/analysis_df.csv")) {
  read_csv("../data/analysis_df.csv", show_col_types = FALSE)
} else {
  build_analysis_df()
}

metric_choices <- c(
  trophic_position = "trophic_position",
  pelagic_diet_proportion = "pelagic_diet_proportion",
  length_mm = "length_mm",
  d15n = "d15n",
  d13c = "d13c"
)

ui <- fluidPage(
  titlePanel("DOC and Fish Ecology Explorer"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "species_choice",
        "Choose species",
        choices = sort(unique(analysis_df$fish_species)),
        selected = sort(unique(analysis_df$fish_species))[1]
      ),
      selectInput(
        "region_choice",
        "Choose region",
        choices = c("All", sort(unique(analysis_df$region))),
        selected = "All"
      ),
      selectInput(
        "metric_choice",
        "Choose metric",
        choices = metric_choices,
        selected = "trophic_position"
      )
    ),
    mainPanel(
      plotOutput("scatter_plot", height = "420px"),
      tableOutput("summary_table")
    )
  )
)

server <- function(input, output) {
  filtered_df <- reactive({
    dat <- analysis_df %>% filter(fish_species == input$species_choice)

    if (input$region_choice != "All") {
      dat <- dat %>% filter(region == input$region_choice)
    }

    dat %>%
      filter(!is.na(doc_mgl), !is.na(.data[[input$metric_choice]]))
  })

  output$scatter_plot <- renderPlot({
    ggplot(filtered_df(), aes(x = doc_mgl, y = .data[[input$metric_choice]])) +
      geom_point(alpha = 0.6, color = "#2b8cbe") +
      geom_smooth(method = "lm", se = FALSE, color = "#e34a33") +
      labs(
        title = "DOC vs selected metric",
        subtitle = paste("Species:", input$species_choice, "| Region:", input$region_choice),
        x = "DOC (mg/L)",
        y = input$metric_choice
      ) +
      theme_minimal(base_size = 12)
  })

  output$summary_table <- renderTable({
    filtered_df() %>%
      summarize(
        n = n(),
        mean_metric = mean(.data[[input$metric_choice]], na.rm = TRUE),
        sd_metric = sd(.data[[input$metric_choice]], na.rm = TRUE),
        mean_doc = mean(doc_mgl, na.rm = TRUE)
      )
  }, digits = 3)
}

shinyApp(ui = ui, server = server)
