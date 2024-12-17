# NYSE Market Dashboard

## Overview

As a data analyst and software developer, I created an interactive web-based dashboard to visualize and analyze New York Stock Exchange (NYSE) market data. This R Shiny application transforms complex stock market data into intuitive, interactive visualizations, making financial analysis accessible without requiring expensive specialized software.

The dashboard leverages modern R programming techniques to process CSV stock market data, generating dynamic insights into stock performance, volatility, and market trends. It provides investors, traders, and financial analysts with a powerful tool for quick and comprehensive market analysis.

Key features include:
- Interactive stock symbol selection
- Dynamic date range filtering
- Real-time performance metrics
- Detailed stock price and volatility visualizations

[Software Demo Video](https://youtu.be/wEeLom-5zVA)

## Development Environment

**Tools Used:**
- RStudio for development
- Git for version control
- R (^4.0.0) runtime environment
- CRAN for dependency management

**Programming Language and Libraries:**
- R as the primary programming language

**Backend Libraries:**
- Shiny for server implementation
- dplyr for data manipulation
- ggplot2 for data visualization
- plotly for interactive graphics
- readr for CSV file processing

**Frontend Libraries:**
- Shinydashboard for UI components
- AdminLTE for responsive design
- DT for interactive data tables

## Key Technical Achievements

- Implemented dynamic stock symbol toggling
- Created interactive visualizations using plotly
- Developed reactive filtering for date ranges
- Calculated advanced stock metrics like volatility and returns
- Designed a responsive, user-friendly dashboard interface

## Useful Websites and References

- [Shiny Documentation](https://shiny.rstudio.com/)
- [dplyr Documentation](https://dplyr.tidyverse.org/)
- [ggplot2 Documentation](https://ggplot2.tidyverse.org/)
- [Plotly for R](https://plotly.com/r/)
- [Shinydashboard Documentation](https://rstudio.github.io/shinydashboard/)

## Future Enhancements

- Implement advanced stock screening capabilities
- Add machine learning-based trend prediction
- Create custom stock portfolio tracking
- Develop more sophisticated risk analysis metrics
- Implement user authentication for personalized dashboards
- Add real-time data integration with stock market APIs
- Create exportable report generation
- Enhance mobile responsiveness

## Installation and Setup

### Prerequisites
- R (version 4.0.0 or higher)
- RStudio (recommended)

### Dependencies
Install required R packages:
```r
install.packages(c(
  "shiny", 
  "shinydashboard", 
  "dplyr", 
  "ggplot2", 
  "plotly", 
  "readr", 
  "DT"
))
```

### Running the Application
1. Clone the repository
2. Open the project in RStudio
3. Ensure the CSV data file is in the correct directory
4. Run the application using `shiny::runApp()`

## Licensing
MIT

## Contact
[Linkedin](https://www.linkedin.com/in/jennifer-c-gonzalez-p/)
