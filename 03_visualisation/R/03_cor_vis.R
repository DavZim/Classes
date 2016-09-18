library(dplyr)
library(ggplot2)
library(readr)
library(RColorBrewer)
library(scales) # for percent axis

# setwd() if necessary

df <- read_csv("data/tidyStockData.csv")
df <- df %>% mutate(date = as.Date(date))

# 1 Compute returns
df <- df %>% group_by(ticker) %>% mutate(ret = price / lag(price) - 1)

df_selection <- df %>% filter(ticker %in% c("GS", "JPM"))

df_selection_wide <- spread(df_selection %>% select(date, ticker, ret), 
                            key = ticker, value = ret)

# 2 Compute Correlations
cor(df_selection_wide %>% na.omit %>% select(GS, JPM))

# 3 Visualise Correlations
plot_cor <- ggplot(df_selection_wide, aes(x = GS, y = JPM)) + 
  geom_abline(slope = 1, intercept = 0, color = "#67001f", size = 0.1) +
  geom_point(shape = 3, alpha = 0.3) + 
  geom_rug(alpha = 0.2) + 
  scale_x_continuous(labels = percent) + 
  scale_y_continuous(labels = percent) + 
  labs(x = "Goldman Sachs", y = "JPMorgan Chase", 
       title = "Correlations of Returns") + 
  theme_minimal()
 
ggsave("plot_correlation.pdf", plot_cor)
