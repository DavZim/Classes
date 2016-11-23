# Exercises

## 01_funcion exercises:
Write a function

1. `greetings`, that takes the user's name `name` and prints a greeting.
2. `rescale_fun`, that takes a vector (`inp_vec`), which is rescaled between two other inputs (`min_val` and `max_val`, default 0 and 1), and returns that vector
3. `fact_fun`, that computes the factorial of an input `n` (`for`-loops or recursive...)


## 02_data exercises:
Get familiar with the dataset (`library(nycflights13)`, use `flights`) and find:

1. the operator with the most flights
2. which origin airport was used most frequently (by what magnitude)
2. the destination with the longest arrival delay
3. the day with the least arrival delay
4. find your own interesting insights from the data



## 03_stockData exercises:

Use `stockData.csv` and:

1. Load and get familiar with the data, tidy the data and save it in a clean format.
2. Visualise prices for selected stocks (level and indexed) and save the output as pdfs.
3. Compute returns for all stocks, visualise correlations between different selected stocks.

Link to `stockData.csv`: https://raw.githubusercontent.com/DavZim/Classes/master/Advanced%20Corporate%20Finance/R%20intro/03_stockData/data/stockData.csv

# Solutions
The solutions are posted in the respective folders. 

The last exercise is split-up into multiple scripts to follow the reproducible research-cycle we talked about in class. That includes: a seperate folder for R-files (`R`) and data-files (`data`). The three solutions to the three questions are in the numbered files. The files `functions.R` and `createStockData.R` are only needed to create the dataset in the first place.

Additionally, there is a pdf-version of the solution (or a html-version, which you have to download and then open it in order to work). The plots that were created in the script are also saved in the `03_stockData`-folder as pdf-files.

If you have any questions, please feel free to contact me: david.zimmermann at zu.de

