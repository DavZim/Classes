library(dplyr)
library(ggplot2)
library(readr)
library(RColorBrewer)

# setwd() if necessary

df <- read_csv("data/tidyStockData.csv")
df <- df %>% mutate(date = as.Date(date))

# 1 Filter selected Stocks
ticker_selection <- c("GS", "JPM", "AXP")
df_selection <- df %>% filter(ticker %in% ticker_selection)

# 2 Compute indexed prices
df_selection <- df_selection %>% group_by(ticker) %>% 
  mutate(price_index = (price / price[1]) * 100)

# 3 A) Visualise Prices
plot_prices <- ggplot(df_selection, aes(x = date, y = price, color = ticker)) +
  geom_line() + 
  labs(x = "Time", y = "Price in USD", 
       title = "Price Developments for Selected Financial Stocks") + 
  scale_color_manual(name = "Ticker", 
                     values = brewer.pal(length(ticker_selection), "Set1")) + 
  theme_minimal()

ggsave("prices.pdf", plot_prices)

# 3 B) Visualise Indexed Prices
plot_idx_prices <- ggplot(df_selection, aes(x = date, y = price_index, 
                                            color = ticker)) +
  geom_line() + 
  labs(x = "Time", y = "Price Index ( 01-01-2000 = 100", 
       title = "Price Developments for Selected Financial Stocks (Indexed)") + 
  scale_color_manual(name = "Ticker", 
                     values = brewer.pal(length(ticker_selection), "Set1")) + 
  theme_minimal()

ggsave("price_index.pdf", plot_idx_prices)
