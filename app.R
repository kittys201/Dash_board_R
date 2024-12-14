# NYSE Market Dashboard
# This Shiny application provides an interactive dashboard for stock market analysis

# Import required libraries for data manipulation, visualization, and dashboard creation
library(shinydashboard)  # For creating dashboard layout
library(shiny)           # Web application framework for R
library(dplyr)           # Data manipulation
library(ggplot2)         # Data visualization
library(readr)           # Reading CSV files
library(tidyr)           # Data tidying
library(DT)              # Interactive data tables
library(plotly)          # Interactive graphics

# Load stock data from CSV
# Assumes a CSV file with columns: Símbolo (Stock Symbol), Fecha (Date), Cierre (Closing Price), Volumen (Volume)
acciones <- read_csv("./data/nyse_varied_data.csv")
acciones$Fecha <- as.Date(acciones$Fecha)  # Convert date column to Date type

# Calculate derived metrics for each stock
# This includes:
# - Rendimiento (Return): Percentage change in stock price
# - Volatilidad (Volatility): Standard deviation of returns
# - Valor_Total (Total Value): Average market capitalization
acciones <- acciones %>%
  group_by(Símbolo) %>%
  mutate(
    Rendimiento = (Cierre - lag(Cierre)) / lag(Cierre) * 100,  # Calculate percentage return
    Volatilidad = sd(Rendimiento, na.rm = TRUE),               # Calculate return volatility
    Valor_Total = mean(Cierre * Volumen, na.rm = TRUE)         # Calculate average market cap
  ) %>%
  ungroup()

# Identify top 5 most valuable stocks based on average market capitalization
# These stocks will be initially active when the dashboard loads
top_5_simbolos <- acciones %>%
  group_by(Símbolo) %>%
  summarise(Valor_Total = mean(Valor_Total, na.rm = TRUE)) %>%
  top_n(5, Valor_Total) %>%  # Select top 5 stocks
  pull(Símbolo)              # Extract stock symbols

# Define UI for the dashboard
# Uses AdminLTE dashboard template with custom styling and interactivity
ui <- dashboardPage(
  # Dashboard header with title
  dashboardHeader(title = "NYSE Market Dashboard"),
  
  # Sidebar with navigation menu and date range selector
  dashboardSidebar(
    sidebarMenu(
      # Menu items for different dashboard sections
      menuItem("Summary", icon = icon("chart-line"), tabName = "resumen"),
      menuItem("Details", icon = icon("table"), tabName = "detalles"),
      menuItem("Advanced Analysis", icon = icon("chart-bar"), tabName = "analisis"),
      
      # Date range input to filter stock data
      dateRangeInput("fechas", 
                     "Select Date Range:",
                     start = min(acciones$Fecha),
                     end = max(acciones$Fecha)),
      
      # Dynamic stock symbol toggle buttons
      uiOutput("simbolos_toggle")
    )
  ),
  
  # Dashboard body with content and styling
  dashboardBody(
    # Custom CSS for styling stock symbol toggle buttons
    tags$head(
      tags$style(HTML("
        .small-box { text-align: center; }
        .stock-symbol-btn { 
          margin: 5px; 
          opacity: 0.5; 
          cursor: pointer; 
          transition: opacity 0.3s;
        }
        .stock-symbol-btn.active { 
          opacity: 1; 
        }
      ")),
      # JavaScript to handle button toggle functionality
      tags$script(HTML("
        $(document).on('click', '.stock-symbol-btn', function() {
          $(this).toggleClass('active');
        });
      "))
    ),
    # Tabs for different sections of the dashboard
    tabItems(
      # Summary tab with key metrics and visualizations
      tabItem(tabName = "resumen",
              # Value boxes showing key metrics
              fluidRow(
                valueBoxOutput("total_acciones"),
                valueBoxOutput("volumen_total"),
                valueBoxOutput("rendimiento_promedio")
              ),
              # Stock price evolution chart
              fluidRow(
                box(
                  title = "Closing Prices", 
                  status = "primary", 
                  plotlyOutput("grafico_precios"), 
                  width = 12,
                  div(
                    id = "simbolos_toggle_container",
                    style = "display: flex; justify-content: center; margin-top: 10px;"
                  )
                )
              ),
              # Stock volatility chart
              fluidRow(
                box(title = "Stock Volatility", status = "warning", plotOutput("grafico_volatilidad"), width = 12)
              )
      ),
      # Details tab with comprehensive stock data table
      tabItem(tabName = "detalles",
              fluidRow(
                box(title = "Detailed Stock Table", status = "success", DTOutput("tabla_acciones"), width = 12)
              )
      ),
      # Advanced analysis tab with return vs volatility scatter plot
      tabItem(tabName = "analisis",
              fluidRow(
                box(title = "Return vs Volatility", status = "danger", plotOutput("scatter_rendimiento_volatilidad"), width = 12)
              )
      )
    )
  )
)

# Define server logic for the dashboard
server <- function(input, output, session) {
  # Reactive value to track active stock symbols
  # Initially set to top 5 most valuable stocks
  simbolos_activos <- reactiveVal(top_5_simbolos)
  
  # Generate toggle buttons for stock symbols
  output$simbolos_toggle <- renderUI({
    simbolos <- unique(acciones$Símbolo)
    
    div(
      style = "display: flex; flex-wrap: wrap; justify-content: center;",
      lapply(simbolos, function(simbolo) {
        actionButton(
          inputId = paste0("toggle_", simbolo), 
          label = simbolo, 
          class = paste0("stock-symbol-btn ", 
                         if(simbolo %in% simbolos_activos()) "active" else "")
        )
      })
    )
  })
  
  # Observe and handle clicks on stock symbol toggle buttons
  observe({
    simbolos <- unique(acciones$Símbolo)
    
    lapply(simbolos, function(simbolo) {
      observeEvent(input[[paste0("toggle_", simbolo)]], {
        current_active <- simbolos_activos()
        
        if(simbolo %in% current_active) {
          # Deactivate stock symbol
          new_active <- current_active[current_active != simbolo]
        } else {
          # Activate stock symbol
          new_active <- c(current_active, simbolo)
        }
        
        simbolos_activos(new_active)
      })
    })
  })
  
  # Reactive data filtering based on date range and active stock symbols
  datos_reactivos <- reactive({
    acciones %>%
      filter(
        Fecha >= input$fechas[1], 
        Fecha <= input$fechas[2],
        Símbolo %in% simbolos_activos()
      )
  })
  
  # Render value boxes with key metrics
  output$total_acciones <- renderValueBox({
    valueBox(
      value = length(unique(datos_reactivos()$Símbolo)),
      subtitle = "Total Stocks",
      icon = icon("university"),
      color = "blue"
    )
  })
  
  output$volumen_total <- renderValueBox({
    valueBox(
      value = format(sum(datos_reactivos()$Volumen), big.mark = ","),
      subtitle = "Total Volume",
      icon = icon("exchange-alt"),
      color = "green"
    )
  })
  
  output$rendimiento_promedio <- renderValueBox({
    valueBox(
      value = paste0(round(mean(datos_reactivos()$Rendimiento, na.rm = TRUE), 2), "%"),
      subtitle = "Average Return",
      icon = icon("chart-line"),
      color = "red"
    )
  })
  
  # Interactive plotly chart of stock closing prices
  output$grafico_precios <- renderPlotly({
    req(nrow(datos_reactivos()) > 0)
    
    p <- datos_reactivos() %>%
      ggplot(aes(x = Fecha, y = Cierre, color = Símbolo)) +
      geom_line() +
      labs(title = "Price Evolution", x = "Date", y = "Closing Price") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Bar chart showing stock volatility
  output$grafico_volatilidad <- renderPlot({
    datos_reactivos() %>%
      group_by(Símbolo) %>%
      summarise(Volatilidad = sd(Rendimiento, na.rm = TRUE)) %>%
      ggplot(aes(x = Símbolo, y = Volatilidad, fill = Símbolo)) +
      geom_bar(stat = "identity") +
      labs(title = "Stock Volatility", x = "Symbol", y = "Volatility") +
      theme_minimal()
  })
  
  # Interactive data table with stock details
  output$tabla_acciones <- renderDT({
    datatable(
      datos_reactivos(), 
      options = list(pageLength = 10, scrollX = TRUE),
      filter = 'top'
    )
  })
  
  # Scatter plot of stock returns vs volatility
  output$scatter_rendimiento_volatilidad <- renderPlot({
    datos_agregados <- datos_reactivos() %>%
      group_by(Símbolo) %>%
      summarise(
        Rendimiento_Promedio = mean(Rendimiento, na.rm = TRUE),
        Volatilidad = sd(Rendimiento, na.rm = TRUE)
      )
    
    ggplot(datos_agregados, aes(x = Volatilidad, y = Rendimiento_Promedio, label = Símbolo)) +
      geom_point(aes(color = Símbolo), size = 3) +
      geom_text(nudge_x = 0.1, nudge_y = 0.1) +
      labs(
        title = "Return vs Volatility", 
        x = "Volatility", 
        y = "Average Return"
      ) +
      theme_minimal()
  })
}

# Launch the Shiny application
shinyApp(ui, server)