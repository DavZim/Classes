## ---- message=FALSE, warning=FALSE---------------------------------------
library(tidyverse) # for most of the data and visualisation functions
library(scales)    # scales for plotting
library(lubridate) # easy date handling
############
# Alternatively, load the libraries individually
# library(dplyr)     # for data manipulation
# library(ggplot2)   # for plotting
# library(lubridate) # for dates
# library(readr)     # for data loading
# library(scales)    # for plotting
# library(tidyr)     # for tidy data

# used for visualisation
theme_set(theme_light())


## ---- message=FALSE, warning=FALSE---------------------------------------
mar_wide <- read_csv("data/market.csv")
ret_wide <- read_csv("data/returns.csv")
events <- read_csv("data/events.csv")

# reshape returns and market to long format
returns <- ret_wide %>% 
  pivot_longer(-date, names_to = "company", values_to = "ret")

market <- mar_wide %>% 
  pivot_longer(-date, names_to = "country", values_to = "mret")
                  
# date formatting
returns <- returns %>% mutate(date = dmy(date))
market <- market %>% mutate(date = dmy(date))
events <- events %>% mutate(event = dmy(event))


## ------------------------------------------------------------------------
returns
market
events


## ------------------------------------------------------------------------
countries <- tibble(
  company = c("Chrysler", "BellSouth", "Engelhard", "Norsk Hydro", "Pilkington", "INA"), 
  country = c("us", "us", "us", "norway", "uk", "italy")
)

# merge into one dataset
merged <- left_join(returns, countries, by = "company")
merged <- left_join(merged, market, by = c("date", "country"))
merged <- left_join(merged, events, by = "company")
merged


## ------------------------------------------------------------------------
# calculate the event-time as the difference in days to the event
merged <- merged %>% 
  group_by(company) %>% 
  mutate(
    date_index = 1:n(),
    event_index = max(ifelse(event == date, date_index, 0)),
    event_time = date_index - event_index
  )

merged


## ------------------------------------------------------------------------
# windows
estimation_window <- c(-230, -31)
event_window <- c(-30, 30)

# filter returns
estimation <- merged %>% 
  filter(event_time >= estimation_window[1],
         event_time <= estimation_window[2])

event <- merged %>% 
  filter(event_time >= event_window[1],
         event_time <= event_window[2])

# have a look at the data
estimation
event

# Graph data
ggplot(estimation %>% filter(ret != 0), aes(x = mret, y = ret, color = company)) + 
  geom_point() + 
  facet_wrap(~company) +
  scale_x_continuous(labels = percent) +
  scale_y_continuous(labels = percent) +
   theme(legend.position = "none") +
  labs(title = "Correlations to Market Returns", 
       subtitle = "The respective markets are USA, UK, Norway, and Italy", 
       x = "Market Return", y = "Company Return")


## ------------------------------------------------------------------------
cmrm <- estimation %>% group_by(company) %>% summarise(cmrm = mean(ret))
cmrm


## ------------------------------------------------------------------------
capm <- estimation %>%
  group_by(company) %>%
  # "do" a regression using do() from the broom-package (tidyverse)
  # see https://github.com/tidyverse/broom
  do(fit = lm(ret ~ mret, data = .)) %>% 
  # get the coefficients: intercept and slope (alpha and beta) 
  # and discard the model itself (fit)
  mutate(alpha = coefficients(fit)[1],
         beta = coefficients(fit)[2],
         fit = NULL)
capm

event_capm <- left_join(event, capm, by = "company") %>% 
  # compute the expected return
  mutate(capm = alpha + mret * beta,
         alpha = NULL,
         beta = NULL)
event_capm


## ------------------------------------------------------------------------
# select only necessary variables 
event <- event %>% select(company, ret, event_time)
event <- left_join(event, cmrm, by = "company")
event


## ------------------------------------------------------------------------
event <- event %>% mutate(ar = ret - cmrm)
event


## ------------------------------------------------------------------------
indiv_event <-  event %>% group_by(company) %>% mutate(car = cumsum(ar))
indiv_event

ggplot(indiv_event, aes(x = event_time, y = car, color = company)) + 
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") + 
  geom_step() + 
  scale_y_continuous(labels = percent) +
  labs(title = "Individual Cumulative Abnormal Returns", subtitle = "In the Event-Horizon", 
       x = "Event Time", y = "CAR", color = "Company")


## ------------------------------------------------------------------------
# aggregated
agg_event <- event %>% group_by(event_time) %>% summarise(aar = mean(ar))
agg_event <- agg_event %>% mutate(car = cumsum(aar))
agg_event

ggplot(agg_event, aes(x = event_time, y = car)) + 
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  geom_step() + 
  scale_y_continuous(labels = percent) +
  labs(title = "Aggregated Cumulative Abnormal Returns", subtitle = "In the Event-Horizon", 
       x = "Event Time", y = "CAR")


## ------------------------------------------------------------------------
test1 <- indiv_event %>% 
  group_by(event_time) %>% 
  summarise(mean_ar = mean(ar),
         var_ar = 1/(n()*(n() - 1)) * sum((ar - mean_ar)^2),
         t_value = mean_ar / sqrt(var_ar),
         p_value = pt(abs(t_value), df = n(), lower.tail = F)*2)

test1


## ------------------------------------------------------------------------
# test2 with CARs
stars <- function(p) {
  ifelse(p < 0.001, "***",
         ifelse(p < 0.01, "**",
                ifelse(p < 0.05, "*", " ")))
}

test2 <- indiv_event %>% 
  group_by(event_time) %>% 
  summarise(mean_car = mean(car),
         var_car = 1/(n()*(n() - 1)) * sum((car - mean_car)^2),
         t_value = mean_car / sqrt(var_car),
         p_value = pt(abs(t_value), df = n(), lower.tail = F)*2)

test2 %>% mutate(sign = stars(p_value),
                 car = cumsum(mean_car)) %>%
  select(event_time, car, t_value, sign) %>%
  filter(event_time %in% -3:6) # look only at the frame [-3, 6], to have less output


## ------------------------------------------------------------------------
time_window <- c(-3, 3)
test3 <- indiv_event %>% filter(event_time >= time_window[1] & 
                                  event_time <= time_window[2]) %>%
  select(company, ar) %>%
  group_by(company) %>% summarise(car = sum(ar)) 

# using the same logic as before
test3 %>% summarise(mean_car = mean(car),
                    var_car = 1/(n()*(n() - 1)) * sum((car - mean_car)^2),
                    t_value = mean_car / sqrt(var_car),
                    p_value = pt(abs(t_value), df = n(), lower.tail = F)*2,
                    sign = stars(p_value))



## ------------------------------------------------------------------------
time_windows <- tibble(min = c(-1, 0, -1, -3),
                       max = c(0, 1, 1, 3))

# map_dfr maps inputs to a function and returns a tibble with bind_rows
mult_events <- map_dfr(1:nrow(time_windows), function(i) {
  tmp <- indiv_event %>% filter(event_time >= time_windows$min[i] & 
                           event_time <= time_windows$max[i]) %>%
    select(company, ar) %>%
    group_by(company) %>% 
    summarise(car = sum(ar)) %>%
    summarise(mean_car = mean(car),
              var_car = 1/(n()*(n() - 1)) * sum((car - mean_car)^2),
              t_value = mean_car / sqrt(var_car),
              p_value = pt(abs(t_value), df = n(), lower.tail = F)*2,
              sign = stars(p_value)) %>% 
    mutate(range = paste0("[", time_windows$min[i], ", ", 
                          time_windows$max[i], "]"))
  return(tmp %>% select(range, car = mean_car, t_value, p_value, sign))
})

mult_events

