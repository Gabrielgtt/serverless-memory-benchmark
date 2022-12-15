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
