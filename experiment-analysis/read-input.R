library(tidyverse)
library(ggplot2)
library(ggpubr)
library(here)
library(genio)


read_input <- function(file_path, x) {
  df <- read_csv(file_path, col_types = cols())
  df$input_line <- 0:(NROW(df)-1)
  
  return(df)
}

read_inputs <- function(gc, benchmark, n, file, day, heap) {
  dir_name <- paste(sep = "", "exp-", gc, "-", benchmark, "-", heap, "-")
  
  file_paths = c()
  for (x in 1:n) {
    # CHANGE DIR HERE
    file_path <- here(paste(sep = "", "results/exp-", day), paste(sep = "", dir_name, x, "/", file))
    if (count_lines(file_path, verbose = FALSE) <= 1) {
      print(paste("File ", file_path, " is empty."))
    } else {
      file_paths = c(file_paths, file_path)
    }
  }
  
  df_list <- map(file_paths, read_input, c(1:n))
  
  df_list  <- imap(df_list, function(d, i) {
    d %>% 
      mutate(
        benchmark = c(as.character(benchmark)),
        heap = as.character(heap)
      ) %>%
      mutate(
        cores = ifelse(heap %in% c("256m", "512m", "1g", "20g1c"), "1", "2"),
        heap = ifelse(heap %in% c("20g1c", "20g2c"), "20g", heap)
      ) %>%
      mutate(
        gc = c(as.character(gc)),
        run = c(as.character(i)),
        day = c(as.character(day)),
        heap = factor(heap, levels = c("256m", "512m", "1g", "2g", "4g", "20g"))
      ) 
  })
  
  df_binded <- do.call(rbind, df_list)
  df_binded %>% mutate(gc = as.factor(gc))
  
  return(df_binded)
}

add_batch_number <- function(df) {
  batch_size <- max(df$req_id) + 1
  return(
    df %>%
      mutate(batch_number = floor(input_line / batch_size))
  )
}
