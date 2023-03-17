# Paper plots

library(tidyverse)
library(patchwork)
library(gt)
library(boot)
library(ggplot2)
library(ggpubr)
library(here)
library(broom)
library(genio)

experiments_info_latency <- list()

args <- commandArgs(trailingOnly = TRUE)

all_gcs <- strsplit(args[1], " ")[[1]]
all_heap_sizes <- strsplit(args[2], " ")[[1]]
all_functions <- strsplit(args[3], " ")[[1]]
day <- args[4]
n_repetitions <- args[5]
file_name <- "processed-alloc.csv"

add_batch_number <- function(df) {
  batch_size <- max(df$req_id) + 1
  return(
    df %>%
      mutate(batch_number = floor(input_line / batch_size))
  )
}

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
    file_path <- here("experiment-scripts/output/", paste(sep = "", dir_name, x, "/", file))
      
    if (count_lines(file_path, verbose = FALSE) <= 1) {
      print(paste("file ", file_path, " is empty."))
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
        cores = ifelse(heap %in% c("256m1c", "512m1c", "1g1c", "20g1c"), "1", "2")
      ) %>%
      mutate(
        gc = c(as.character(gc)),
        run = c(as.character(i)),
        day = c(as.character(day)),
        heap = factor(heap, levels = c("256m1c", "512m1c", "1g1c", "2g2c", "4g2c", "20g1c", "20g2c"))
      ) 
  })
  
  df_binded <- do.call(rbind, df_list)
  df_binded %>% mutate(gc = as.factor(gc))
  
  return(df_binded)
}

for (gc in all_gcs) {
  for (hs in all_heap_sizes) {
    for (fu in all_functions) {
      index <- length(experiments_info_latency) + 1
      
      line_latency <- c(gc, fu, n_repetitions, paste("results/", fu, ".csv", sep = ""), day, hs)
      experiments_info_latency[[index]] <- line_latency
    }
  }
}

df_latency <- map_df(experiments_info_latency, function(x) { 
  read_inputs(x[[1]], x[[2]], x[[3]], x[[4]], x[[5]], x[[6]]) %>% 
    add_batch_number() %>%
    mutate(cores = case_when(cores == 1 ~ "single-core", cores == 2 ~ "dual-core")) %>%
    mutate(cores = factor(cores, levels = c("single-core", "dual-core"))) %>%
    mutate(heap = as.character(heap)) %>%
    mutate(heap = substr(heap, 1, nchar(heap)-2)) %>%
    mutate(
      heap = case_when(
        heap == "256m" ~ "256Mb",
        heap == "512m" ~ "512Mb",
        heap == "1g" ~ "1Gb",
        heap == "2g" ~ "2Gb",
        heap == "4g" ~ "4Gb"
      )) %>%
    mutate(heap = factor(heap, levels = c("256Mb", "512Mb", "1Gb", "2Gb", "4Gb")))
  })

df_heavyslow <- df_latency %>%
  filter(
    batch_number != 0,
    benchmark %in% c("graph-bfs"),
    heap %in% c("256Mb")
  ) %>%
  mutate(
    duration = duration / 1e9
  ) %>%
  group_by(heap, gc) %>%
  mutate(
    p99_lat = quantile(duration, .99),
    # max_lat = max(duration),
    median_lat = quantile(duration, .5)
  ) %>% 
  ungroup() %>%
  mutate(
    rel_median_lat = median_lat / min(median_lat),
    rel_p99_lat = p99_lat / min(p99_lat)
  )

ecdf_heavyslow_256m <- df_heavyslow %>%
  ggecdf(x = "duration", linetype = "gc") %>%
  set_palette("grey") %>%
  ggpar(
    xlab = "Response time (s)",
    ylab = "ECDF",
    title = "Latency ECDF for Heavy ARA functions",
    xticks.by = 1
  ) +
  grids(linetype = "dashed") +
  geom_vline(data = df_heavyslow, size = 0.5, show.legend = FALSE, aes(linetype = gc, xintercept = p99_lat)) +
  geom_vline(data = df_heavyslow, size = 0.5, show.legend = FALSE, aes(linetype = gc, xintercept = median_lat)) +
  geom_text(
    data = df_heavyslow, 
    nudge_x = 0.198, 
    size = 5,
    show_guide = FALSE,
    aes(x = p99_lat, y = 0.3, label = "99th-percentile", angle = -90)
  ) +
  geom_text(
    data = df_heavyslow, 
    nudge_x = -0.140,
    size = 5,
    show_guide = FALSE,
    aes(x = median_lat, y = 0.8, label = "Median", angle = -90)
  ) + 
  theme(text=element_text(size=14))

print("Saving image for Response time ECDF for Heavy ARA functions.")
png("fig3-heavy-ara-256mb-response-time-ecdf")
ecdf_heavyslow_256m
dev.off()


boxplot_heavyslow <- df_latency %>%
  filter(
    batch_number != 0,
    benchmark %in% c("graph-bfs"),
    gc != "Epsilon"
  ) %>%
  mutate(
    duration = duration / 1e9
  ) %>%
  ggboxplot(x = "gc", y = "duration", color = "gc") %>%
  ggpar (
    xlab = "",
    ylab = "Response time (s)", 
    x.text.angle = 40, 
    legend = "none", 
    yticks.by = 2
  ) %>%
  facet(facet.by = "heap") %>%
  set_palette("grey") +
  grids(linetype = "dashed") + 
  theme(text=element_text(size=14))

print("Saving image for Response time Boxplot of Heavy ARA functions.")
png("fig2-heavy-ara-latency-boxplot")
boxplot_heavyslow
dev.off()


calculate_quantile <- function(df, p = .99) {
  squantile <- \(d, i, ...) d[i,] %>% pull(duration) %>% quantile(p)
  bdf <- boot(data = df, statistic = squantile, R = 4000)
  tidy(bdf, conf.level = .95, conf.int = TRUE) %>% mutate(heap = df$heap[1], gc = df$gc[1], cores = df$cores[1])
}

plot_latency_ic <- function(df) {
  p <- df %>%
    ggplot(aes(y = statistic, x = gc)) +
    geom_linerange(aes(ymin = conf.low, ymax = conf.high), position = position_dodge(width = .5)) +
    geom_point(aes(shape = gc), size = 1.5, position = position_dodge(width = .5)) +
    facet_grid(. ~ heap) +
    theme_minimal() + 
    theme(text=element_text(size=13), axis.text.x = element_text(angle = 45, hjust=1)) 
  
  p <- p %>%
    ggpar(xlab = "", ylab = "Response Time (ms)") %>%
    set_palette("grey") 
  
  return(p)
}

grouped_dh_latency <- df_latency %>%
  filter(batch_number != 0, benchmark == "dynamic-html") %>%
  mutate(duration = duration / 1e6) %>%
  group_by(gc, heap) %>%
  group_split()


print("Calculating CIs for the medium ARA functions")
dh_median_ic <- grouped_dh_latency %>% map_df(~calculate_quantile(., p = 0.5))
dh_p95_ic <- grouped_dh_latency %>% map_df(~calculate_quantile(., p = .95))
dh_p99_ic <- grouped_dh_latency %>% map_df(~calculate_quantile(., p = .99))


print("95th-percentile of the response time distribution for Medium ARA functions")
png("fig4-95th-medium-ara-latency-ci")
dh_p95_ic %>% 
  mutate(gc = factor(gc, levels = c("Serial", "G1", "Shenandoah"))) %>% 
  plot_latency_ic() %>% 
  ggpar(legend = "none", ylab = "Response Time (ms)", xlab = "", ylim = c(60, 90)) + 
  theme(text=element_text(size=12))
dev.off()

print("99th-percentile of the response time distribution for Medium ARA functions")
png("fig4-99th-medium-ara-latency-ci")
dh_p99_ic %>% 
  mutate(gc = factor(gc, levels = c("Serial", "G1", "Shenandoah"))) %>% 
  plot_latency_ic() %>% 
  ggpar(legend = "none", ylab = "Response Time (ms)", xlab = "", ylim = c(60, 90)) + 
  theme(text=element_text(size=12))
dev.off()

grouped_fb_latency <- df_latency %>%
  filter(batch_number != 0, benchmark == "fibonacci", duration < 750000000) %>%
  mutate(duration = duration / 1e6) %>%
  group_by(gc, heap) %>%
  group_split()

fb_median_ic <- grouped_fb_latency %>% map_df(~calculate_quantile(., p = 0.5))
fb_p95_ic <- grouped_fb_latency %>% map_df(~calculate_quantile(., p = .95))
fb_p99_ic <- grouped_fb_latency %>% map_df(~calculate_quantile(., p = .99))

print("99th-percentile of the response time distribution for Tiny ARA functions")
png("fig5-99th-tiny-ara-latency-ci")
fb_p99_ic %>% plot_latency_ic() %>% ggpar(legend = "none", ylab = "Response Time (ms)", xlab = "", ylim = c(560, 570)) + theme(text=element_text(size=12))
dev.off()

print("95th-percentile of the response time distribution for Tiny ARA functions")
png("fig5-95th-tiny-ara-latency-ci")
fb_p95_ic %>% plot_latency_ic() %>% ggpar(legend = "none", ylab = "Response Time (ms)", xlab = "", ylim = c(560, 570)) + theme(text=element_text(size=12)) 
dev.off()
