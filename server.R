library(shiny)


shinyServer(function(input, output) {
  # while running coded for first time, if function doesn't work, please remove '#' from below two lines, then run it again. R will install those packages.
  
  install.packages("TTR")    
  install.packages("forecast")
  
  library(forecast)
  
  library(TTR)
  
  data <- read.csv("sale.csv")  ## Loading data
  
  
  
  select.product <- reactive({                                  # function that will filter that product based on the user's input
    product_data <- data[data$PRODUCT_ID == input$product_id,] 
    return(product_data = product_data)
  }) 
  
  
  select.product.name <- reactive({                     #function that is giving product name title and other outputs in top left box as lead time, safety stock, reorder point 
    p_data = select.product()
    p_name <- p_data[1,4]
    lead_time <- p_data[1,5]
    
    if(input$method == 'naive'){
      x = forecast.naive()$naive_forecast$fitted;
      d = forecast.naive()$naive_forecast$mean;
    }else if(input$method == 'ma'){
      x = forecast.sma()$sma_fitted;
      d = forecast.sma()$sma_forecast$mean;
    }else if(input$method == 'es'){
      x = forecast.es()$es_forecast$fitted;
      d = forecast.es()$es_forecast$mean;
    }
    
    sd_per_year <- sd(x, na.rm = TRUE)
    sd_per_day <- sd_per_year/ sqrt(365)
    
    service_level <- 0.95
    Z_a <-  qnorm(service_level)
    
    safety_stock <- round(Z_a*sd_per_day*sqrt(lead_time))
    
    daily_avg <- d/30
    
    reorder_point <-round((lead_time* daily_avg) + safety_stock)
    
    return(list(p_name = p_name, lead_time = lead_time,  safety_stock = safety_stock, reorder_point = reorder_point))
  })
  
  output$product_text <- renderText(                                  #to pass output values to user interface, $name will be recognized as output variable in user interface
    paste("Product Name: ", select.product.name()$p_name )
  )
  
  output$lead_time <- renderText(
    paste("Lead Time: ", select.product.name()$lead_time )
  )
  
  output$safety_stock <- renderText(
    paste("Safety Stock: ", select.product.name()$safety_stock )
  )
  
  output$reorder_point <- renderText(
    paste("Reorder Point: ", select.product.name()$reorder_point )
  )
  
  forecast.naive <- reactive({          # forecast calculation for naive method
    p_data = select.product()
    x = p_data$UNIT_SALES
    
    naive_forecast <- naive(x, h=1, level=c(80,95), fan=FALSE, lambda=NULL)   # using naive method from 'forecast' package from R
    naive_accuracy <- accuracy(naive_forecast)                             # accuracu is R's function that calculate training and test error rates of forecast
    
    return(list(naive_forecast = naive_forecast, naive_accuracy = naive_accuracy) )
  })
  
  
  forecast.sma <- reactive({         # forecast calculation for simple moving average
    p_data = select.product()
    x = p_data$UNIT_SALES
    ts.x <-ts(x)
    sma <- SMA(ts.x, 3)              # using sma() function from 'forecast' package in R
    
    sma_forecast <- forecast(sma, 1)
    sma_fitted <- sma
    sma_accuracy <- accuracy(sma_forecast)
    
    return(list(sma_fitted = sma_fitted, sma_forecast = sma_forecast, sma_accuracy = sma_accuracy) )
  })
  
  forecast.es <- reactive({                      ### forecast calculation using exponential smoothing method
    p_data = select.product()
    x = p_data$UNIT_SALES
    
    es_forecast <- ses(x, h = 1, level = c(80, 95), alpha=0.3)   
    es_accuracy <- accuracy(es_forecast)
    es_plot <- plot(es_forecast)
    
    return(list(es_forecast = es_forecast, es_plot = es_plot, es_accuracy = es_accuracy) )
  })
  
  
  output$forecast_naive_output <- renderPrint({
    forecast_mean <- forecast.naive()
    return(forecast_mean$naive_forecast )
  })
  
  output$forecast_naive_accuracy <- renderPrint({
    forecast_mean <- forecast.naive()
    return(forecast_mean$naive_accuracy )
  })
  
  output$naive_plot <- renderPlot({
    forecast <- forecast.naive()
    plot(forecast$naive_forecast)
  })
  
  output$forecast_sma_output <- renderPrint({
    forecast_mean <- forecast.sma()
    return(forecast_mean$sma_forecast)
  })
  
  output$forecast_sma_accuracy <- renderPrint({
    forecast_mean <- forecast.sma()
    return(forecast_mean$sma_accuracy)
  })
  
  output$sma_plot <- renderPlot({
    forecast <- forecast.sma()
    plot(forecast.sma()$sma_forecast, main = "Forecasts from Moving Average")
  })
  
  output$forecast_es_output <- renderPrint({
    forecast_mean <- forecast.es()
    return(forecast_mean$es_forecast )
  })
  
  output$forecast_es_accuracy <- renderPrint({
    forecast_mean <- forecast.es()
    return(forecast_mean$es_accuracy )
  })
  
  output$es_plot <- renderPlot({
    forecast <- forecast.es()
    plot(forecast$es_forecast)
  })

  
  output$product_plot <- renderPlot({
    p_data = select.product()
    barplot(p_data$UNIT_SALES , col = "blue", ylab = " Unit Sales")
  })
  
  output$product_dataHead <- renderDataTable(select.product())
  
})

