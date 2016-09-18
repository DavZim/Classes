#' Get Stock Data for a single ticker
#'
#' @param ticker the Yahoo tikcer for a stock
#' @param from the starting data (provided as a character)
#' @param long a boolean indicating the format, defaults to TRUE
#'
#' @return a data_frame containing the adjusted stock prices
#' @export
#'
#' @examples
#' getData("MSFT", from = "2010-01-01", long = TRUE)
#' 
getData <- function(ticker, from = "2000-01-01", long = T) {
  tmp <- getSymbols(ticker, from = from, auto.assign = F)
  
  if (long) {
    df <- data_frame(date = index(tmp), ticker = ticker, price = as.numeric(Ad(tmp)))
  } else {
    df <- data_frame(date = index(tmp), price = as.numeric(Ad(tmp)))
    names(df) <- c("date", ticker)
  }
  return(df)
}

#' Get Stock Data for multiple tickers
#'
#' @param tickers a vector of tickers
#' @param from the starting data (provided as a character)
#' @param long a boolean indicating the format, defaults to TRUE
#'
#' @return a data_frame containing the adjusted stock prices
#' @export
#'
#' @examples
#' getDataMult(c("AAPL", "GOOGL", "MSFT"), from = "2010-01-01", long = TRUE)
#' 
getDataMult <- function(tickers, from = "2010-01-01", long = T) {
  res <- lapply(tickers, getData, long = long, from = from)
  
  if (long) {
    res <- bind_rows(res)
  } else {
    res <- do.call(left_join, res)
  }
  return(res)
}
