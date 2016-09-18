# 1 greetings function
greetings <- function(name) {
	print(paste0("Hello ", name, ", welcome aboard this class!"))
}

greetings("David")

# 2 rescale_fun 
rescale_fun <- function(inp_vec, min_val = 0, max_val = 1){
	scaled_down <- inp_vec - min(inp_vec) 
	scaled_up <- scaled_down / diff(range(inp_vec)) * (max_val - min_val) + min_val
  
	return(scaled_up)
}


# 3 fact_fun
# for loop
fact_fun <- function(n = 3) {
  if (n > 100) stop("Are you kidding me, thats way too big! Try a number below 100")
  
  ret_val <- 1
  for (i in 1:n) {
    ret_val <- ret_val * i
  }
  return(ret_val)
}

# cumprod
fact_fun2 <- function(n = 3) {
  if (n > 100) stop("Are you kidding me, thats way too big! Try a number below 100")
  
  vec <- 1:n
  return(max(cumprod(vec)))
}

# recursive
fact_fun3 <- function(n = 3) {
  if (n > 100) stop("Are you kidding me, thats way too big! Try a number below 100")
  
  if (n == 1) {
    return(1)
  } else {
    return(fact_fun(n - 1) * n)
  }
}

identical(fact_fun(12), fact_fun2(12), fact_fun3(12))
