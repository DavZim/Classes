library(dplyr)
library(nycflights13)

flights 

names(flights)
str(flights)

# 1 Find the operator with the most flights

flights %>% group_by(carrier) %>% summarise(n = n()) %>% arrange(desc(n))

# 2 Find the most frequently used origin airport

flights %>% group_by(origin) %>% summarise(n = n()) %>% arrange(desc(n))

# 3 Find the destination with the longest arrival delay

flights %>% group_by(dest) %>% 
  summarise(max_arr_delay = max(arr_delay, na.rm = T)) %>%
  arrange(desc(max_arr_delay))
  
# 4 Find the day with the least arrival delay

flights %>% mutate(date = paste0(year, "-", month, "-", day)) %>%
  group_by(date) %>% summarise(mean_arr_delay = mean(arr_delay, na.rm = T)) %>%
  arrange(mean_arr_delay)

# 5 ....