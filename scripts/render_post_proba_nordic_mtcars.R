# render_post_proba_nordic_mtcars.R
# Xera figuras R (paleta B · Nordic Frost) no bundle do post Hugo.
# Cada gráfico: versión -light.png e -dark.png (o HTML escolle con data-scheme).
#
# Uso (dende a raíz de distritoZero):
#   Rscript scripts/render_post_proba_nordic_mtcars.R
#
# Requírese: paquetes de identidade_grafica (ggplot2, dplyr, ragg, ggrepel,
# ggtext, ggridges, ggbump, waffle, scales, glue, tidyr, forcats, tibble, purrr)
# e o cartafol 00_infraestrutura/identidade_grafica xunto a distritoZero.

args_trail <- commandArgs(trailingOnly = TRUE)
ca <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", ca, value = TRUE)
file_arg <- if (length(file_arg)) sub("^--file=", "", file_arg[[1]]) else NA_character_
if (is.na(file_arg) || !nzchar(file_arg)) {
  stop(
    "Executa dende a raíz do repo:\n",
    "  Rscript scripts/render_post_proba_nordic_mtcars.R\n",
    "Opcional: primeiro argumento = ruta absoluta ao root de distritoZero."
  )
}
script_path <- normalizePath(file_arg, mustWork = TRUE)
repo_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
if (length(args_trail) >= 1) {
  repo_root <- normalizePath(args_trail[[1]], mustWork = TRUE)
}
if (!dir.exists(file.path(repo_root, "content", "post"))) {
  stop("Non se atopou content/post en: ", repo_root)
}

out_dir <- file.path(repo_root, "content", "post", "proba-identidade-nordic-mtcars")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

identidade_root <- normalizePath(
  file.path(repo_root, "..", "00_infraestrutura", "identidade_grafica"),
  mustWork = TRUE
)

owd <- setwd(identidade_root)
on.exit(setwd(owd), add = TRUE)

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(forcats)
  library(tibble)
  library(purrr)
  library(scales)
  library(ggrepel)
  library(ggtext)
  library(ggridges)
  library(ggbump)
  library(waffle)
  library(glue)
  library(ragg)
})

source(file.path(identidade_root, "R", "tema_proxecto.R"))
usar_paleta("B")

# Modo escuro: mesmo fondo ca referencia identidade (Opción B · comparar_paletas → barras_dark.png):
# panel e plot = slate-900 unificado (#0F172A), igual que grad_high nos gradientes.
cores$bg_dark   <- .paletas[["B"]]$bg_dark
cores$grad_high <- .paletas[["B"]]$grad_high

# ── Tipografía máis grande e marxes xenerosas (exportación web) ─────────────
# base_size do tema pasou de 12 a BASE_PT; sz() escala etiquetas en geoms (mm).
BASE_PT <- 15L
sz <- function(mm) mm * BASE_PT / 12

th_marxes <- theme(
  plot.margin = margin(36, 48, 36, 48, "pt"),
  plot.title = element_text(size = BASE_PT * 1.55, margin = margin(b = 10, unit = "pt")),
  plot.subtitle = element_text(size = BASE_PT * 1.2, margin = margin(b = 14, unit = "pt")),
  plot.caption = element_text(size = BASE_PT * 0.95, margin = margin(t = 14, unit = "pt")),
  axis.title = element_text(size = BASE_PT * 1.08),
  axis.text = element_text(size = BASE_PT * 1.02),
  legend.text = element_text(size = BASE_PT * 0.98),
  legend.title = element_text(size = BASE_PT * 1.08)
)

tema_pub <- function(dark = FALSE) {
  tema_proxecto(base_size = BASE_PT, dark = dark) + th_marxes
}

theme_set(tema_pub())

# Etiquetas en geoms: un chisco máis grandes + cor con contraste co fondo do panel
LAB_SZ <- function(mm) sz(mm) * 1.18
lab_panel_pri <- function(dark) if (dark) cores$txt_dark else cores$tit_light
lab_segment_col <- function(dark) if (dark) "#CBD5E1" else cores$muted
lab_point_border <- function(dark) if (dark) cores$light else cores$dark
smooth_line_col <- function(dark) if (dark) "#E2E8F0" else cores$dark
lab_heatmap_cell <- function(dark) if (dark) "#F8FAFC" else "#0F172A"

save_plot_pair <- function(plot_light, plot_dark, nome, w = 1350, h = 825, res = 150) {
  path_l <- file.path(out_dir, paste0(nome, "-light.png"))
  agg_png(path_l, width = w, height = h, res = res)
  print(plot_light)
  dev.off()
  message("Gardado: ", path_l)
  path_d <- file.path(out_dir, paste0(nome, "-dark.png"))
  agg_png(path_d, width = w, height = h, res = res)
  print(plot_dark)
  dev.off()
  message("Gardado: ", path_d)
}

save_plot_dual <- function(plot, nome, w = 1350, h = 825, res = 150, dark_theme = NULL) {
  path_l <- file.path(out_dir, paste0(nome, "-light.png"))
  agg_png(path_l, width = w, height = h, res = res)
  print(plot)
  dev.off()
  message("Gardado: ", path_l)
  p_d <- plot + tema_pub(dark = TRUE)
  if (!is.null(dark_theme)) {
    p_d <- p_d + dark_theme
  }
  path_d <- file.path(out_dir, paste0(nome, "-dark.png"))
  agg_png(path_d, width = w, height = h, res = res)
  print(p_d)
  dev.off()
  message("Gardado: ", path_d)
}

# ── Datos ───────────────────────────────────────────────────────────────────
data(mtcars, package = "datasets")
mt <- mtcars |>
  tibble::rownames_to_column("modelo") |>
  mutate(
    cyl  = factor(cyl, levels = c(4, 6, 8), labels = c("4 cil.", "6 cil.", "8 cil.")),
    am   = factor(am, labels = c("Automático", "Manual")),
    vs   = factor(vs, labels = c("Motor en V", "Recto")),
    gear = factor(gear)
  )

# ── 1. Barras ─────────────────────────────────────────────────────────────────
datos_barras <- mt |>
  group_by(cyl) |>
  summarise(mpg_medio = mean(mpg), .groups = "drop")

th_barras <- theme(
  panel.grid.major.y = element_blank(),
  axis.line.y = element_blank(),
  axis.ticks.y = element_blank()
)
mk_barras <- function(dark) {
  mpg_pad <- max(datos_barras$mpg_medio, na.rm = TRUE) * 0.045
  datos_barras |>
    mutate(
      cyl = fct_reorder(cyl, mpg_medio),
      mpg_label_x = mpg_medio + mpg_pad
    ) |>
    ggplot(aes(x = mpg_medio, y = cyl)) +
    geom_col(fill = cores$primary, width = 0.65) +
    geom_text(
      aes(x = mpg_label_x, label = number(mpg_medio, accuracy = 0.1)),
      hjust = 0,
      vjust = 0.5,
      colour = lab_panel_pri(dark),
      size = LAB_SZ(3.5),
      family = "montserrat",
      fontface = "bold"
    ) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.16))) +
    tema_pub(dark = dark) +
    th_barras +
    labs(
      title = "Consumo medio por motorización",
      subtitle = "Millas por galón (mpg) · conxunto mtcars",
      x = "mpg (media)", y = NULL,
      caption = "Proba paleta B · Nordic Frost · distritoZero"
    )
}
save_plot_pair(mk_barras(FALSE), mk_barras(TRUE), "fig-01-barras")

# ── 2. Lollipop ───────────────────────────────────────────────────────────────
datos_lol <- mt |>
  slice_max(order_by = hp, n = 12) |>
  mutate(modelo = fct_reorder(modelo, hp))

th_lol <- theme(
  panel.grid.major.y = element_blank(),
  panel.grid.major.x = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank()
)
mk_lollipop <- function(dark) {
  # Etiquetas á dereita do círculo (non superpoñer ao punto): offset en unidades de hp
  hp_pad <- max(datos_lol$hp, na.rm = TRUE) * 0.058
  datos_lol_lbl <- datos_lol |> mutate(hp_label_x = hp + hp_pad)
  ggplot(datos_lol_lbl, aes(x = hp, y = modelo)) +
    geom_segment(
      aes(x = 0, xend = hp, yend = modelo),
      colour = lab_segment_col(dark),
      linewidth = 0.8,
      lineend = "round"
    ) +
    geom_point(
      colour = lab_point_border(dark),
      fill = cores$secondary,
      shape = 21,
      size = LAB_SZ(4.2),
      stroke = 1.1
    ) +
    geom_text(
      aes(x = hp_label_x, label = hp),
      hjust = 0,
      vjust = 0.5,
      colour = lab_panel_pri(dark),
      size = LAB_SZ(3.35),
      family = "montserrat",
      fontface = "bold"
    ) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.18))) +
    tema_pub(dark = dark) +
    th_lol +
    labs(
      title = "Máis potencia segundo mtcars",
      subtitle = "Doce modelos con maior hp",
      x = "Potencia (hp)", y = NULL,
      caption = "Proba paleta B · Nordic Frost · distritoZero"
    )
}
save_plot_pair(mk_lollipop(FALSE), mk_lollipop(TRUE), "fig-02-lollipop")

# ── 3. Scatter ────────────────────────────────────────────────────────────────
mt_lbl <- mt |>
  mutate(
    destaca = modelo %in% c(
      "Toyota Corolla", "Cadillac Fleetwood", "Lotus Europa",
      "Ferrari Dino", "Merc 240D"
    )
  )

sub_md <- glue::glue(
  "<span style='color:{cores$primary}'>4 cil.</span>, ",
  "<span style='color:{cores$secondary}'>6 cil.</span> e ",
  "<span style='color:{cores$tertiary}'>8 cil.</span> · tendencia global"
)

th_scatter <- theme(plot.subtitle = ggtext::element_markdown())
mk_scatter <- function(dark) {
  ggplot(mt, aes(wt, mpg, colour = cyl)) +
    geom_smooth(
      method = "lm", se = TRUE,
      colour = smooth_line_col(dark),
      fill = cores$secondary,
      alpha = if (dark) 0.22 else 0.14,
      linewidth = 0.85
    ) +
    geom_point(size = sz(2.95), alpha = 0.88) +
    geom_text_repel(
      data = filter(mt_lbl, destaca),
      aes(label = modelo),
      size = LAB_SZ(3.05),
      family = "montserrat",
      fontface = "bold",
      max.overlaps = 20,
      segment.colour = lab_segment_col(dark),
      colour = lab_panel_pri(dark),
      bg.colour = if (dark) cores$bg_dark else cores$bg_light,
      bg.r = 0.12,
      box.padding = 0.55,
      min.segment.length = 0.2
    ) +
    scale_colour_proxecto(name = NULL) +
    labs(
      title = "Peso fronte a rendemento",
      subtitle = as.character(sub_md),
      x = "Peso (miles de libras)", y = "mpg",
      caption = "Proba paleta B · Nordic Frost · distritoZero"
    ) +
    tema_pub(dark = dark) +
    th_scatter
}
save_plot_pair(mk_scatter(FALSE), mk_scatter(TRUE), "fig-03-scatter", h = 900)

# ── 4. Heatmap correlación ────────────────────────────────────────────────────
vars <- c("mpg", "disp", "hp", "drat", "wt", "qsec", "carb")
cor_mat <- cor(mtcars[, vars])
cor_long <- as.data.frame(as.table(cor_mat)) |>
  as_tibble() |>
  rename(v1 = Var1, v2 = Var2, r = Freq) |>
  mutate(
    v1 = factor(v1, levels = vars),
    v2 = factor(v2, levels = rev(vars))
  )

col_baja <- "#F43F5E"
col_alta <- cores$primary

th_cor <- theme(
  panel.grid = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank()
)
p_cor <- ggplot(cor_long, aes(x = v1, y = v2, fill = r)) +
  geom_tile(colour = cores$white, linewidth = 0.6) +
  geom_text(
    aes(label = number(r, accuracy = 0.01)),
    colour = lab_heatmap_cell(FALSE),
    size = LAB_SZ(3),
    family = "montserrat",
    fontface = "bold"
  ) +
  scale_fill_gradient2(
    low = col_baja,
    mid = cores$light,
    high = col_alta,
    midpoint = 0,
    limits = c(-1, 1),
    name = "r"
  ) +
  tema_pub() +
  th_cor +
  labs(
    title = "Correlación de Pearson entre variables",
    subtitle = "Matriz simétrica · mtcars",
    x = NULL, y = NULL,
    caption = "Proba paleta B · Nordic Frost · distritoZero"
  )

p_cor_dark_base <- ggplot(cor_long, aes(x = v1, y = v2, fill = r)) +
  geom_tile(colour = cores$dark, linewidth = 0.6) +
  geom_text(
    aes(label = number(r, accuracy = 0.01)),
    colour = lab_heatmap_cell(TRUE),
    size = LAB_SZ(3),
    family = "montserrat",
    fontface = "bold"
  ) +
  scale_fill_gradient2(
    low = col_baja,
    mid = cores$mid,
    high = col_alta,
    midpoint = 0,
    limits = c(-1, 1),
    name = "r"
  ) +
  tema_pub(dark = TRUE) +
  th_cor +
  labs(
    title = "Correlación de Pearson entre variables",
    subtitle = "Matriz simétrica · mtcars",
    x = NULL, y = NULL,
    caption = "Proba paleta B · Nordic Frost · distritoZero"
  )

path_cor_l <- file.path(out_dir, "fig-04-heatmap-light.png")
agg_png(path_cor_l, width = 1200, height = 1100, res = 150)
print(p_cor)
dev.off()
message("Gardado: ", path_cor_l)
path_cor_d <- file.path(out_dir, "fig-04-heatmap-dark.png")
agg_png(path_cor_d, width = 1200, height = 1100, res = 150)
print(p_cor_dark_base)
dev.off()
message("Gardado: ", path_cor_d)

# ── 5. Ridgeline ──────────────────────────────────────────────────────────────
th_ridge <- theme(
  legend.position = "none",
  panel.grid.major.y = element_blank()
)
p_ridge <- ggplot(mt, aes(x = mpg, y = cyl, fill = cyl)) +
  geom_density_ridges(
    scale = 1.15,
    rel_min_height = 0.015,
    colour = cores$white,
    alpha = 0.88,
    linewidth = 0.55
  ) +
  scale_fill_proxecto(name = NULL) +
  tema_pub() +
  th_ridge +
  labs(
    title = "Forma da distribución de mpg",
    subtitle = "Comparación entre grupos de cilindrada",
    x = "mpg", y = NULL,
    caption = "Proba paleta B · Nordic Frost · distritoZero"
  )

save_plot_dual(p_ridge, "fig-05-ridgeline", dark_theme = th_ridge)

# ── 6. Bump ───────────────────────────────────────────────────────────────────
rank_gear <- mt |>
  group_by(gear, cyl) |>
  summarise(mpg_m = mean(mpg), .groups = "drop") |>
  group_by(gear) |>
  mutate(rango = rank(-mpg_m, ties.method = "min")) |>
  ungroup() |>
  mutate(gear = as.integer(as.character(gear)))

etiquetas_fin <- rank_gear |> filter(gear == max(gear))

th_bump <- theme(
  panel.grid = element_blank(),
  legend.position = "none",
  axis.line.y = element_blank(),
  axis.ticks = element_blank()
)
mk_bump <- function(dark) {
  ggplot(rank_gear, aes(x = gear, y = rango, colour = cyl)) +
    geom_bump(linewidth = 1, smooth = 6) +
    geom_point(size = LAB_SZ(3.25)) +
    geom_text(
      data = etiquetas_fin,
      aes(label = cyl),
      x = max(rank_gear$gear) + 0.22,
      hjust = 0,
      colour = lab_panel_pri(dark),
      size = LAB_SZ(3.25),
      family = "montserrat",
      fontface = "bold"
    ) +
    scale_y_reverse(breaks = 1:3) +
    scale_x_continuous(
      breaks = sort(unique(rank_gear$gear)),
      expand = expansion(mult = c(0.06, 0.22))
    ) +
    scale_colour_proxecto(name = NULL) +
    tema_pub(dark = dark) +
    th_bump +
    labs(
      title = "Ranking de cilindrada por caixa de cambios",
      subtitle = "Posición 1 = maior mpg medio dentro de cada gear",
      x = "Número de marchas (gear)", y = "Posición",
      caption = "Proba paleta B · Nordic Frost · distritoZero"
    )
}
save_plot_pair(mk_bump(FALSE), mk_bump(TRUE), "fig-06-bump", h = 800)

# ── 7. Waffle ─────────────────────────────────────────────────────────────────
conteo <- mt |> count(cyl, name = "n")
parts <- setNames(conteo$n, as.character(conteo$cyl))

th_waffle <- theme(
  legend.position = "right",
  axis.title.x = element_text(size = BASE_PT * 0.88),
  legend.text = element_text(size = BASE_PT * 0.98),
  plot.title = element_text(size = BASE_PT * 1.45)
)
p_waffle <- waffle(
  parts = parts,
  rows = 8,
  size = 0.85,
  colors = escala_discreta[seq_along(parts)],
  title = "Composición de mtcars por cilindrada",
  xlab = "1 cadrado = 1 coche · Proba paleta B · distritoZero"
) +
  tema_pub() +
  th_waffle

save_plot_dual(p_waffle, "fig-07-waffle", w = 1200, h = 1000, dark_theme = th_waffle)

# ── 8. Serie proxy ────────────────────────────────────────────────────────────
set.seed(2)
ts_proxy <- mt |>
  arrange(am, mpg) |>
  group_by(am) |>
  mutate(
    idx = row_number(),
    mpg_smooth = predict(loess(mpg ~ idx, span = 0.8)),
    banda = runif(n(), 1.2, 2.5),
    inf = mpg_smooth - banda,
    sup = mpg_smooth + banda
  ) |>
  ungroup()

evento_idx <- 12
th_ts <- theme(legend.position = "top")
p_ts <- ggplot(ts_proxy, aes(x = idx, y = mpg_smooth, colour = am, fill = am)) +
  geom_ribbon(aes(ymin = inf, ymax = sup), alpha = 0.14, colour = NA) +
  geom_line(linewidth = 1.05) +
  geom_point(aes(y = mpg), size = sz(1.65), alpha = 0.35, inherit.aes = TRUE) +
  geom_vline(
    xintercept = evento_idx,
    colour = cores$tertiary,
    linetype = "dashed",
    linewidth = 0.6
  ) +
  scale_colour_proxecto(name = NULL) +
  scale_fill_proxecto(name = NULL) +
  tema_pub() +
  th_ts +
  labs(
    title = "Tendencia de mpg ao longo do índice ordenado",
    subtitle = "Ordenado por tipo de caixa · banda aproximada ao redor do loess",
    x = "Índice (non temporal)", y = "mpg",
    caption = "Proba paleta B · Nordic Frost · distritoZero"
  )

save_plot_dual(p_ts, "fig-08-serie", dark_theme = th_ts)

# ── Portada e Open Graph ──────────────────────────────────────────────────────
file.copy(
  file.path(out_dir, "fig-01-barras-light.png"),
  file.path(out_dir, "cover.png"),
  overwrite = TRUE
)
og_dir <- file.path(repo_root, "static", "img", "og")
dir.create(og_dir, recursive = TRUE, showWarnings = FALSE)
file.copy(
  file.path(out_dir, "fig-01-barras-light.png"),
  file.path(og_dir, "proba-identidade-nordic-mtcars.png"),
  overwrite = TRUE
)

message("Listo. Post: ", out_dir)
