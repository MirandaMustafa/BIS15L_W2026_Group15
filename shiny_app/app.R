library(shiny)
library(readr)
library(dplyr)
library(ggplot2)

# Assume the cleaned analysis dataset has already been created in data/analysis_df.csv.
analysis_df <- read_csv("../data/analysis_df.csv", show_col_types = FALSE)

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
      filter(!is.na(doc_mg_l), !is.na(.data[[input$metric_choice]]))
  })

  output$scatter_plot <- renderPlot({
    ggplot(filtered_df(), aes(x = doc_mg_l, y = .data[[input$metric_choice]])) +
      geom_point(alpha = 0.6, color = "blue") +
      geom_smooth(method = "lm", se = FALSE, color = "red") +
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
        mean_doc = mean(doc_mg_l, na.rm = TRUE)
      )
  }, digits = 3)
}

shinyApp(ui = ui, server = server)
