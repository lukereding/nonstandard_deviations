library(tidyverse) # for ggplot2
library(magrittr) # for pipes and %<>%
library(ggpubr) # for theme_pubr()

# to install:
# devtools::install_github("wilkelab/cowplot")
library(cowplot)

df <- read_csv("http://datadryad.org/bitstream/handle/10255/dryad.112898/traitdata.csv?sequence=1")

df %<>% mutate(melano = factor(melano), melano = forcats::fct_recode(melano, "derived" = "1", "rod-\nshaped" = "0"))

original_plot <- df %>% 
  ggplot(aes(x = male.meanB, y = fema.meanB)) + 
  geom_point(aes(color = melano)) +
  theme_pubr() +
  scale_color_manual(values = c("#37454B", "#ffc300")) +
  labs(x = "mean male brightness", y = "mean female brightness", title = "relationship between male\nand female brightness", subtitle = "DOI: http://dx.doi.org/10.5061/dryad.jf0r0")
ggsave("~/Documents/nonstandard_deviations/images/post6/1.jpg", original_plot, width = 4, height = 4.4)
  
library(cowplot)

# create the histgram for the x-axis with axis_canvas()
xhist <- axis_canvas(original_plot, axis = "x") +
  geom_histogram(data = df, aes(x = male.meanB, fill = melano)) +
  scale_fill_manual(values = c("#37454B", "#ffc300"))

# create the combined plot
combined_plot <- insert_xaxis_grob(original_plot, xhist, position = "bottom")

# plot the resulting combined plot
ggdraw(combined_plot)

ggsave("~/Documents/nonstandard_deviations/images/post6/2.jpg", width = 4, height = 4.4)


# create the marginal boxplot for the y-axis
y_box <- axis_canvas(original_plot, axis = "y") +
  geom_boxplot(data = df, aes(x = 0, y = fema.meanB, fill = melano)) +
  scale_fill_manual(values = c("#37454B", "#ffc300"))
# create the combined plot
combined_plot %<>% insert_yaxis_grob(., y_box, position = "right")

# show the result
ggdraw(combined_plot)
ggsave("~/Documents/nonstandard_deviations/images/post6/3.jpg", width = 4, height = 4.4)

# create density plot
# note use of `coord_flip`!
y_density <- axis_canvas(original_plot, axis = "y", coord_flip = TRUE) +
  geom_density(data = df, aes(x = fema.meanB,fill = melano), color = NA, alpha = 0.5) +
  scale_fill_manual(values = c("#37454B", "#ffc300")) +
  coord_flip()

# create the combined plot, adding on to `combined_plot`
combined_plot %<>% insert_yaxis_grob(., y_density, position = "right")

# show the result
ggdraw(combined_plot)

ggsave("~/Documents/nonstandard_deviations/images/post6/4.jpg", width = 4, height = 4.4)


# add labels to the histogram
xhist <- axis_canvas(original_plot, axis = "x") +
  geom_histogram(data = df, aes(x = male.meanB, fill = melano)) +
  geom_text(data = data.frame(x = c(0.6, -0.95), y = c(5, 4), melano = c("derived", "rod-shaped")), aes(x = x, y = y, label = melano, color = melano), size = 4) +
  scale_color_manual(values = rev(c("#37454B", "#ffc300"))) +
  scale_fill_manual(values = c("#37454B", "#ffc300"))

combined_plot <- insert_xaxis_grob(original_plot + theme(legend.position="none"), xhist, position = "bottom")

ggdraw(combined_plot)

ggsave("~/Documents/nonstandard_deviations/images/post6/5.jpg", width = 4, height = 4.4)



# create a line plot
# for simplicity I do not add in the data points
line_plot <- df %>% 
  ggplot(aes(x = male.meanB, y = fema.meanB)) + 
  geom_smooth(aes(color = melano), se = F) +
  theme_pubr() +
  scale_color_manual(values = c("#37454B", "#ffc300"), guide= F) +
  labs(x = "male mean brightness", y = "female mean brightness", title = "relationship between male\nand female brightness", subtitle = "DOI: http://dx.doi.org/10.5061/dryad.jf0r0")

# add labels
y_labels <- axis_canvas(line_plot, axis = "y") +
  geom_text(data = df %>% group_by(melano) %>% summarise(max_female = max(fema.meanB, na.rm = T)), aes(x = 0, y = max_female, color = melano, label = melano)) +
  scale_color_manual(values = c("#37454B", "#ffc300"))

# make combined plot
combined_plot <- insert_yaxis_grob(line_plot, y_labels, position = "right")
ggdraw(combined_plot)
ggsave("~/Documents/nonstandard_deviations/images/post6/6.jpg", width = 4, height = 4.4)

sessionInfo()
# R version 3.4.1 (2017-06-30)
# Platform: x86_64-apple-darwin15.6.0 (64-bit)
# Running under: macOS Sierra 10.12.6
# 
# Matrix products: default
# BLAS: /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
# LAPACK: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRlapack.dylib
# 
# locale:
#   [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
# 
# attached base packages:
#   [1] stats     graphics  grDevices utils     datasets 
# [6] methods   base     
# 
# other attached packages:
#   [1] bindrcpp_0.2       cowplot_0.8.0.9000
# [3] ggpubr_0.1.5       magrittr_1.5      
# [5] dplyr_0.7.2        purrr_0.3.0       
# [7] readr_1.1.1        tidyr_0.6.3       
# [9] tibble_1.3.3       ggplot2_2.2.1     
# [11] tidyverse_1.1.1   
# 
# loaded via a namespace (and not attached):
#   [1] Rcpp_0.12.12     cellranger_1.1.0 compiler_3.4.1  
# [4] plyr_1.8.4       bindr_0.1        forcats_0.2.0   
# [7] tools_3.4.1      digest_0.6.12    jsonlite_1.5    
# [10] lubridate_1.6.0  nlme_3.1-131     gtable_0.2.0    
# [13] lattice_0.20-35  pkgconfig_2.0.1  rlang_0.1.2     
# [16] psych_1.7.5      curl_2.8.1       parallel_3.4.1  
# [19] haven_1.1.0      xml2_1.1.1       stringr_1.2.0   
# [22] httr_1.2.1       hms_0.3          grid_3.4.1      
# [25] glue_1.1.1       R6_2.2.2         readxl_1.0.0    
# [28] foreign_0.8-69   modelr_0.1.1     reshape2_1.4.2  
# [31] scales_0.4.1     rvest_0.3.2      assertthat_0.2.0
# [34] mnormt_1.5-5     colorspace_1.3-2 labeling_0.3    
# [37] stringi_1.1.5    lazyeval_0.2.0   munsell_0.4.3   
# [40] broom_0.4.2  