library(readr)
library(tidyr)

# setwd() if necessary

df <- read_csv("data/stockData.csv")

names(df)
dim(df)
summary(df)

# leave out V
df <- df %>% select(-V)

# have a look at the data again
df %>% head

df_long <- gather(df, key = ticker, value = price, -date)
head(df_long)

# save the tidy data
write_csv(df_long, "data/tidyStockData.csv")
