read_data <- function(path, sheet){
  read_excel(path, sheet)
}

prep_prescreen_data <- function(data){
  data |> 
    mutate(positives = case_when(
      (caja > 0.85 & aona > 0.85 & sabo > 0.85) ~ "yes",
      .default = "no"
    ),
    id = 1:nrow(data))
}

plot_pre_subclone_data <- function(data){
  ggplot(data, aes(color = positives)) +
    geom_point(aes(id, caja), size = 2) +
    geom_text_repel(data=subset(data, positives == "yes"), 
                    aes(id, caja, label=clone), 
                    size = 3.5, color = "black", min.segment.length = 0) +
    scale_color_manual(values = c("grey", "#E64B35FF")) +
    theme_classic(base_size = 15) +
    scale_x_continuous(n.breaks = 9, 
                       limits = c(0, 100), 
                       expand = expansion(add = c(0, 0.5))) +
    scale_y_continuous(n.breaks = 8, 
                       limits = c(0, 1.4), 
                       expand = expansion(add = c(0, 0.001))) +
    labs(x = "anti-marmoset hybridoma minipools",
         y = expression("OD"["450"])) +
    theme(legend.position = "none")
}

plot_single_clone_screen <- function(data){
  ggplot(data, aes(fct_reorder(single_clone, od450), od450)) +
    geom_col(fill = "grey", color = "black") +
    geom_text(aes(label = od450), vjust = 0.5, hjust = -0.1) +
    theme_classic(base_size = 13) +
    scale_y_continuous(n.breaks = 9, 
                       limits = c(0, 2.0), 
                       expand = expansion(0)) +
    labs(x = NULL, y = expression("OD"["450"])) +
    coord_flip() +
    theme(panel.grid.major.y = element_line())
}

prep_spiked_data <- function(data){
  blank_data <- data |>
    dplyr::filter(primary_name == "blank")
  mean_blank <- mean(blank_data[["od450"]], na.rm = TRUE)
  data |>
    dplyr::filter(primary_name != "blank") |>
    dplyr::mutate(blanked_od = od450 - mean_blank) |>
    dplyr::group_by(primary_name, primary_conc_ug_ml) |>
    dplyr::summarise(
      mean_od = mean(blanked_od, na.rm = TRUE),
      mean_sd = sd(blanked_od, na.rm = TRUE),
      .groups = 'drop'
    )
}

plot_spiked_data <- function(data){
  ggplot(data, aes(x = primary_conc_ug_ml, 
                      y = mean_od, 
                      group = primary_name, 
                      color = primary_name,
                      shape = primary_name)) +
    geom_errorbar(aes(ymin = mean_od - mean_sd,
                      ymax = mean_od + mean_sd),
                  width = 0.1, show.legend = FALSE) +
    geom_point(size = 3, stroke = 1) +
    geom_smooth(linewidth = 1, 
                method = drm, 
                method.args = list(fct = L.4()), 
                se = F, show.legend = FALSE) +
    theme_classic(base_size = 15) +
    #labs(tag = "A") +
    scale_x_log10(name = "anti-Marmoset antibody dilutions (Log)",
                  limits = c(NA, 12),
                  labels = scales::label_log(),
                  expand = expansion(add = c(0, 0.0))) +
    scale_y_continuous(name = expression("OD"["450"]),
                       limits = c(NA, 1.5), 
                       expand = expansion(add = c(0.1, 0.00)),
                       n.breaks = 8) +
    scale_color_npg(name = NULL) +
    scale_shape_manual(name = NULL, values=c(0,1,2,5,6)) +
    theme(legend.position= "inside",
          legend.position.inside = c(0.3, 0.7),
          panel.grid.major.y = element_line())
}