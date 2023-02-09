library(tidyverse)
library(ggplot2)
library(ggpubr)

plot_latency <- function(df, bn, b) {
  d <- df %>% 
    filter(batch_number == bn & benchmark == b) %>%
    mutate(gc = as.factor(gc))
  
  ecdf_latency <- d %>%
    ggecdf(x = "duration", color = "gc") %>%
    ggpar(
      xlab = "Response time (ms)",
      ylab = "ECDF"
    )
  
  boxplot_latency <- d %>%
    ggboxplot(x = "gc", y = "duration", fill = "gc") %>%
    ggpar( 
      ylab = "Response time (ms)",
      xlab = "GC", x.text.angle = 20
    ) 
  
  ggarrange(
    ecdf_latency, 
    boxplot_latency
  )
}

plot_ecdf_latency <- function(df, b, color_by = "heap", heaps = c("20g1c", "20g2c"), gcs = c("Epsilon"), nticks = 10) {
  df <- df_latency %>%
    filter(
      batch_number != 0, benchmark %in% c(b), gc %in% gcs, heap %in% heaps
    ) %>%
    mutate(
      duration = duration / 1e6
    ) %>%
    group_by(heap, gc) %>%
    mutate(
      p95_lat = quantile(duration, .95), 
      p99_lat = quantile(duration, .99), 
      p999_lat = quantile(duration, .999), 
      median_lat = quantile(duration, .5)
    ) %>% 
    ungroup() %>%
    mutate(
      rel_median_lat = median_lat / min(median_lat), 
      rel_p95_lat = p95_lat / min(p95_lat),
      rel_p99_lat = p99_lat / min(p99_lat), 
      rel_p999_lat = p999_lat / min(p999_lat)
    )
   
  ecdf_plot <- df %>%
    ggecdf(x = "duration", color = color_by) %>%
    ggpar(
      xlab = "Response time (ms)",
      ylab = "ECDF",
      xticks.by = nticks
    ) +
    grids(linetype = "dashed")
  
  table_df <- df %>%
        distinct(heap, rel_median_lat, rel_p95_lat, rel_p99_lat, rel_p999_lat, gc) %>%
        arrange(gc) %>%
        select(heap, gc, rel_median_lat, rel_p95_lat, rel_p99_lat, rel_p999_lat) 
  
  table <- table_df %>%
        mutate(
          rel_median_lat = paste(format(round(rel_median_lat, 2), nsmall = 2), "x", sep = ""),
          rel_p95_lat = paste(format(round(rel_p95_lat, 2), nsmall = 2), "x", sep = ""),
          rel_p99_lat = paste(format(round(rel_p99_lat, 2), nsmall = 2), "x", sep = ""),
          rel_p999_lat = paste(format(round(rel_p999_lat, 2), nsmall = 2), "x", sep = "")
        ) %>%
        ggtexttable(
          rows = NULL, 
          theme = ttheme(tbody.style = tbody_style(hjust=1, x=0.9)),
          cols = c("Heap/#Cores", "GC", "Median", "95th", "99th", "999th")
        ) %>% 
        table_cell_bg(row = which.min(table_df$rel_median_lat)[[1]] + 1, column = 3, fill="darkolivegreen1", color = "darkolivegreen4") %>%
        table_cell_bg(row = which.min(table_df$rel_p95_lat)[[1]] + 1, column = 4, fill="darkolivegreen1", color = "darkolivegreen4") %>%
        table_cell_bg(row = which.min(table_df$rel_p99_lat)[[1]] + 1, column = 5, fill="darkolivegreen1", color = "darkolivegreen4") %>%
        table_cell_bg(row = which.min(table_df$rel_p999_lat)[[1]] + 1, column = 6, fill="darkolivegreen1", color = "darkolivegreen4") %>%
        table_cell_bg(row = which.max(table_df$rel_median_lat)[[1]] + 1, column = 3, fill="coral1", color = "coral4") %>%
        table_cell_bg(row = which.max(table_df$rel_p95_lat)[[1]] + 1, column = 4, fill="coral1", color = "coral4") %>%
        table_cell_bg(row = which.max(table_df$rel_p99_lat)[[1]] + 1, column = 5, fill="coral1", color = "coral4") %>%
        table_cell_bg(row = which.max(table_df$rel_p999_lat)[[1]] + 1, column = 6, fill="coral1", color = "coral4")
  
  
  ggarrange(ecdf_plot, table, ncol = 1, heights = c(3, 1))
}

plot_alloc <- function(df, b) {
  df <- df %>% ungroup()
  df_size = NROW(df)
  
  df_heap_from_before <- df %>% 
    select(ts_s, gc, heap, heap_before_mb, benchmark, run) %>% 
    mutate(heap_mb = heap_before_mb) %>%
    select(-c(heap_before_mb))
  
  df_heap_from_after <- df %>% 
    select(ts_s, gc, heap, heap_after_mb, benchmark, run) %>% 
    mutate(heap_mb = heap_after_mb) %>%
    select(-c(heap_after_mb))
  
  df_precise_alloc <- rbind(df_heap_from_before, df_heap_from_after) 
  
  df_precise_alloc %>%
    filter(benchmark == b & run == 5) %>%
    ggline(x = "ts_s", y = "heap_mb", color = "gc", numeric.x.axis = TRUE, size = 0.8, point.size = 0.1) %>%
    ggpar(
      xlab = "Uptime (s)",
      ylab = "Heap usage (mb)",
      title = "Heap usage through time"
    ) +
    facet_wrap(~ heap)
}
