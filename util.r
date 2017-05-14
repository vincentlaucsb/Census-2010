get_label <- function(data, n, output='', transform=c()) {
  # n:      Number of bins data was separated into
  # output:
  #  * "":          Don't change output
  #  * "percent":   Output percentage values
  # transform:      A list of transformations to apply to the labels
  
  # Get the breaks that colorQuantile uses
  # quantile(geog_demo_data$black_percent,
  #          probs = seq(0, 1, length.out = 9), na.rm=TRUE)  
  breaks <- quantile(data, probs = seq(0, 1, length.out = n + 1),
                     na.rm=TRUE)
  
  labels <- c()
  
  for (i in 1:n) {
    for (func in transform) {
      lower_bound <- do.call(what=func, args=list(breaks[i]))
      upper_bound <- do.call(what=func, args=list(breaks[i + 1]))
    }
    
    if (output == 'percent') {
      labels <- append(labels,
                       paste0(round(lower_bound, 3) * 100, "%",
                              " - ",
                              round(upper_bound, 3) * 100, "%"))
    } else {
      labels <- append(labels, paste0(lower_bound, " - ", upper_bound))
    }
  }
  
  return(labels)
}

# as.money <- function(num, round=TRUE) {
#   # 123000 --> "$123,000"
#   # round:    Round number before converting to money?
#   
#   ret_str = ""
#   add_comma = FALSE
#   
#   # Attempt to type-cast strings
#   if (!is.numeric(num)) {
#     num = as.numeric(num)
#   }
#   
#   if (round) {
#     num = round(num)
#   }
#   
#   while (as.integer(num) > 0) {
#     if (num%%1000 > 100) {
#       last_three_digits = num%%1000
#     } else {
#       # Add some leading zeroes
#       last_three_digits = paste0(rep('0', 3 - nchar(num%%1000)),
#                                  num%%1000, collapse="")
#     }
#     
#     if (add_comma) {
#       ret_str = paste0(last_three_digits, ret_str)
#     } else {
#       ret_str = paste0(last_three_digits, ',', ret_str)
#       add_comma = TRUE
#     }
#     
#     num = as.integer(num/1000)
#   }
#   
#   return(paste0("$", ret_str))
# }

as.money <- function(value, currency.sym="$", digits=2, sep=",", decimal=".") {
  # Credits: http://stackoverflow.com/questions/14028995/money-representation-in-r
  paste(
    currency.sym,
    formatC(value, format = "f", big.mark = sep, digits=digits, decimal.mark=decimal),
    sep=""
  )
}