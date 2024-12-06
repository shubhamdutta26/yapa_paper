library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("readxl", "dplyr", "ggplot2", "ggrepel", "ggsci", "ggtext",
               "drc")
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("04-scripts/functions.R")

# Replace the target list below with your own:
list(
  tar_target(file, "03-processed-data/final_data.xlsx", format = "file"),
  tar_target(pre_subclone_data, read_data(file, 2)),
  tar_target(prepped_subclone_data, prep_prescreen_data(pre_subclone_data)),
  tar_target(pre_subclone_plot, plot_pre_subclone_data(prepped_subclone_data)),
  tar_target(single_clone_screen_data, read_data(file, 3)),
  tar_target(single_clone_plot, plot_single_clone_screen(single_clone_screen_data)),
  tar_target(spiked_data, read_data(file, 4)),
  tar_target(spiked_data_prepped, prep_spiked_data(spiked_data)),
  tar_target(spiked_data_plot, plot_spiked_data(spiked_data_prepped))
)
