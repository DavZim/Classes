library(dplyr)
library(quantmod)
library(readr)
library(tibble)
library(tidyr)

setwd("exercise") # set your working directory

source("R/functions.R") # loads the functions

tickers = c("PG", "CAT", "DIS", "V", "MSFT", "MRK", "VZ", "TRV", "GE", "AXP", 
            "JNJ", "DD", "KO", "NKE", "AAPL", "PFE", "WMT", "HD", "MCD", "BA", 
            "MMM", "IBM", "JPM", "XOM", "GS", "CSCO", "CVX", "UNH", "UTX", 
            "INTC")

df <- getDataMult(tickers, from = "2000-01-01", long = T)


df_wide <- spread(df, ticker, price)

write_csv(df_wide, "data/stockData.csv")
