# render_post_actas_plenos_lalin.R
# Figuras R (paleta B · Nordic Frost) para o post sobre votacións / actas (Lalín).
# Datos: JSON exportados pola pipeline R → app React (app_react/src/data/*.json).
#
# Uso (dende a raíz de distritoZero):
#   Rscript scripts/render_post_actas_plenos_lalin.R
#
# Opcional:
#   1º argumento: ruta absoluta ao root de distritoZero.
#   Variable de entorno ACTAS_ROOT: raíz do repo actas_organos_colexiados
#   (por defecto: ../02_administracion/actas_organos_colexiados relativo a distritoZero).
#
# Se os JSON están desactualizados, executar antes no repo de actas:
#   Rscript 02_scripts/export_json.R (xera app_react/src/data/*.json).

args_trail <- commandArgs(trailingOnly = TRUE)
ca <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", ca, value = TRUE)
file_arg <- if (length(file_arg)) sub("^--file=", "", file_arg[[1]]) else NA_character_
if (is.na(file_arg) || !nzchar(file_arg)) {
  stop(
    "Executa dende a raíz do repo:\n",
    "  Rscript scripts/render_post_actas_plenos_lalin.R\n",
    "Opcional: ACTAS_ROOT ou 1º arg = root distritoZero."
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

actas_root <- Sys.getenv("ACTAS_ROOT", unset = "")
if (!nzchar(actas_root)) {
  actas_root <- normalizePath(
    file.path(repo_root, "..", "02_administracion", "actas_organos_colexiados"),
    mustWork = FALSE
  )
} else {
  actas_root <- normalizePath(actas_root, mustWork = TRUE)
}
data_dir <- file.path(actas_root, "app_react", "src", "data")
if (!dir.exists(data_dir)) {
  stop(
    "Non se atopou o cartafol de datos da app: ", data_dir,
    "\nDefine ACTAS_ROOT coa ruta ao repo actas_organos_colexiados."
  )
}

out_dir <- file.path(repo_root, "content", "post", "actas-plenos-lalin")
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
  library(forcats)
  library(tibble)
  library(scales)
  library(lubridate)
  library(jsonlite)
  library(glue)
  library(ragg)
})

source(file.path(identidade_root, "R", "tema_proxecto.R"))
usar_paleta("B")
cores$bg_dark   <- .paletas[["B"]]$bg_dark
cores$grad_high <- .paletas[["B"]]$grad_high

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

LAB_SZ <- function(mm) sz(mm) * 1.18

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

# Cores alineadas co gráfico G01 da app React (tipos de votación)
CORES_TIPO_VOT <- c(
  Unanimidade = "#2A9D8F",
  `Man alzada` = "#E9C46A",
  Ordinaria   = "#F4A261",
  Descoñecido = "#ADB5BD"
)

CORES_PARTIDO <- c(
  cxg_cctt     = "#E63946",
  pp           = "#457B9D",
  psdeg_psoe   = "#F4A261",
  bng          = "#2A9D8F",
  pgd          = "#9B5DE5",
  apac         = "#F9C74F",
  non_adscrito = "#8D99AE",
  conxunta     = "#6C757D"
)

LABELS_CURTOS <- c(
  cxg_cctt     = "CxG-CC-TT",
  pp           = "PP",
  psdeg_psoe   = "PSdeG-PSOE",
  bng          = "BNG",
  pgd          = "P.G.D.",
  apac         = "APAC/PAC",
  non_adscrito = "Non adscrito",
  conxunta     = "Conxunta"
)

PROPONENTES_PARTIDOS <- c(
  "pp", "psdeg_psoe", "bng", "pgd", "apac",
  "non_adscrito", "cxg_cctt", "conxunta"
)

# ── Datos JSON ───────────────────────────────────────────────────────────────
vp <- fromJSON(file.path(data_dir, "votacions.json"), simplifyDataFrame = TRUE)
idx <- fromJSON(file.path(data_dir, "indice.json"), simplifyDataFrame = TRUE)

vp <- vp |>
  mutate(
    data = as.Date(data),
    tipo_votacion = as.character(tipo_votacion)
  )

idx <- idx |>
  mutate(data = as.Date(data))

# ── 1. Tipos de votación por lexislatura (equivalente G01 React) ─────────────
tipos_orden <- c("unanimidade", "man_alzada", "ordinaria", "desconecido")
labels_tipos <- c("Unanimidade", "Man alzada", "Ordinaria", "Descoñecido")

a1 <- vp |>
  filter(!is.na(tipo_votacion), nzchar(tipo_votacion)) |>
  mutate(
    tipo_votacion = if_else(
      tipo_votacion %in% tipos_orden,
      tipo_votacion,
      "desconecido"
    ),
    tipo_votacion = factor(tipo_votacion, levels = tipos_orden, labels = labels_tipos)
  ) |>
  count(lexislatura, tipo_votacion) |>
  group_by(lexislatura) |>
  mutate(pct = n / sum(n)) |>
  ungroup() |>
  mutate(
    lexislatura = factor(lexislatura, levels = sort(unique(as.character(lexislatura))))
  )

lbl_col_tipo <- function(tipo) {
  case_when(
    tipo == "Man alzada" ~ "#1E293B",
    TRUE ~ "#FFFFFF"
  )
}

mk_p1 <- function(dark) {
  a1_lbl <- a1 |>
    filter(pct >= 0.05) |>
    mutate(
      col_txt = lbl_col_tipo(as.character(tipo_votacion)),
      etiqueta = paste0(round(pct * 100), "%")
    )
  ggplot(a1, aes(x = lexislatura, y = pct, fill = tipo_votacion)) +
    geom_col(position = "stack", width = 0.62) +
    geom_text(
      data = a1_lbl,
      aes(label = etiqueta, colour = I(col_txt)),
      position = position_stack(vjust = 0.5),
      size = LAB_SZ(3.2),
      family = "montserrat",
      fontface = "bold",
      show.legend = FALSE
    ) +
    scale_y_continuous(labels = percent_format(accuracy = 1), expand = expansion(0, 0)) +
    scale_fill_manual(values = CORES_TIPO_VOT, name = NULL) +
    tema_pub(dark = dark) +
    theme(
      panel.grid.major.x = element_blank(),
      axis.text.x = element_text(angle = 0, hjust = 0.5)
    ) +
    labs(
      title = "Tipo de votación por lexislatura",
      subtitle = "Proporción sobre o total de votacións rexistradas nos JSON da app",
      x = NULL,
      y = NULL,
      caption = glue("Fonte: {basename(data_dir)} · Lalín · plenos")
    )
}

save_plot_pair(mk_p1(FALSE), mk_p1(TRUE), "fig-01-tipos-lexislatura", w = 1350, h = 780)

# ── 2. Conflitividade: % non unánimes por semestre ───────────────────────────
c2 <- vp |>
  filter(!is.na(tipo_votacion), !is.na(data)) |>
  mutate(
    es_non_unan = tipo_votacion %in% c("man_alzada", "ordinaria"),
    semestre = floor_date(data, "6 months")
  ) |>
  group_by(semestre, lexislatura) |>
  summarise(
    total = n(),
    non_unan = sum(es_non_unan, na.rm = TRUE),
    pct_non_unan = non_unan / total,
    .groups = "drop"
  ) |>
  filter(total >= 3) |>
  filter(is.finite(pct_non_unan))

cores_lexi <- c("2012-2015" = "#E63946", "2015-2019" = "#457B9D", "2019-2023" = "#2A9D8F")
# calquera outra lexislatura: cor de apoio
extra_lexi <- setdiff(unique(c2$lexislatura), names(cores_lexi))
if (length(extra_lexi)) {
  cores_lexi <- c(cores_lexi, setNames(rep(cores$secondary, length(extra_lexi)), extra_lexi))
}

mk_p2 <- function(dark) {
  ggplot(c2, aes(x = semestre, y = pct_non_unan)) +
    geom_area(aes(fill = lexislatura), alpha = 0.22) +
    geom_line(aes(color = lexislatura), linewidth = 1) +
    geom_point(aes(color = lexislatura, size = total), alpha = 0.9) +
    scale_y_continuous(labels = percent_format(accuracy = 1), limits = c(0, NA)) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    scale_color_manual(values = cores_lexi, name = NULL) +
    scale_fill_manual(values = cores_lexi, name = NULL) +
    scale_size(range = c(2.2, 6), guide = "none") +
    tema_pub(dark = dark) +
    theme(panel.grid.minor = element_blank()) +
    labs(
      title = "Votacións non unánimes ao longo do tempo",
      subtitle = "Por semestre; o tamaño do punto reflicte o número de votacións no período",
      x = NULL,
      y = NULL,
      caption = glue("Fonte: {basename(data_dir)} · Lalín")
    )
}

save_plot_pair(mk_p2(FALSE), mk_p2(TRUE), "fig-02-conflitividade-semestre", w = 1350, h = 780)

# ── 3. Resultado das votacións ───────────────────────────────────────────────
a3 <- vp |>
  filter(!is.na(resultado), nzchar(resultado)) |>
  count(resultado) |>
  mutate(resultado = fct_reorder(resultado, n))

mk_p3 <- function(dark) {
  tc <- if (dark) cores$txt_dark else cores$tit_light
  nmax <- max(a3$n, na.rm = TRUE)
  ggplot(a3, aes(x = n, y = resultado)) +
    geom_col(fill = cores$primary, width = 0.65) +
    geom_text(
      aes(x = n + nmax * 0.04, label = n),
      hjust = 0,
      size = LAB_SZ(3.4),
      family = "montserrat",
      fontface = "bold",
      colour = tc
    ) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.14))) +
    tema_pub(dark = dark) +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.x = element_blank()
    ) +
    labs(
      title = "Resultado das votacións",
      subtitle = "Contaxios por categoría (rexistro nas actas)",
      x = "Número de votacións",
      y = NULL,
      caption = glue("Fonte: {basename(data_dir)}")
    )
}

save_plot_pair(mk_p3(FALSE), mk_p3(TRUE), "fig-03-resultado-votacions")

# ── 4. Temas no índice de puntos (top) ───────────────────────────────────────
a4 <- idx |>
  filter(!is.na(tema), nzchar(tema)) |>
  count(tema, sort = TRUE) |>
  slice_head(n = 14) |>
  mutate(tema = fct_reorder(tema, n))

mk_p4 <- function(dark) {
  tc <- if (dark) cores$txt_dark else cores$tit_light
  nmax <- max(a4$n, na.rm = TRUE)
  ggplot(a4, aes(x = n, y = tema)) +
    geom_col(fill = cores$tertiary, width = 0.68) +
    geom_text(
      aes(x = n + nmax * 0.035, label = n),
      hjust = 0,
      size = LAB_SZ(3.2),
      family = "montserrat",
      fontface = "bold",
      colour = tc
    ) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
    tema_pub(dark = dark) +
    theme(
      panel.grid.major.y = element_blank(),
      axis.text.y = element_text(size = BASE_PT * 0.95)
    ) +
    labs(
      title = "Temas máis frecuentes na orde do día",
      subtitle = "Índice de actas (top 14 categorías)",
      x = "Número de puntos",
      y = NULL,
      caption = glue("Fonte: indice.json · {basename(data_dir)}")
    )
}

save_plot_pair(mk_p4(FALSE), mk_p4(TRUE), "fig-04-temas-indice")

# ── 5. Iniciativas por partido e lexislatura (visión C3) ─────────────────────
a5 <- idx |>
  filter(
    tipo %in% c("mocion", "mocion_urxencia", "solicitude"),
    proponente %in% PROPONENTES_PARTIDOS
  ) |>
  count(lexislatura, proponente) |>
  mutate(
    etiqueta = coalesce(LABELS_CURTOS[proponente], proponente),
    etiqueta = factor(etiqueta)
  )

mk_p5 <- function(dark) {
  tc <- if (dark) cores$txt_dark else cores$tit_light
  ggplot(a5, aes(x = n, y = fct_reorder(etiqueta, n, sum), fill = proponente)) +
    geom_col(show.legend = FALSE) +
    geom_text(
      aes(label = n),
      hjust = -0.15,
      size = LAB_SZ(3.1),
      family = "montserrat",
      colour = tc
    ) +
    facet_wrap(~lexislatura, nrow = 1L) +
    scale_fill_manual(values = CORES_PARTIDO) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.2))) +
    tema_pub(dark = dark) +
    theme(
      panel.grid.major.y = element_blank(),
      strip.text = element_text(face = "bold", size = BASE_PT * 1.05)
    ) +
    labs(
      title = "Iniciativas políticas por partido",
      subtitle = "Mocións, mocións de urxencia e solicitudes · por lexislatura",
      x = "Número de iniciativas",
      y = NULL,
      caption = glue("Fonte: indice.json · {basename(data_dir)}")
    )
}

save_plot_pair(mk_p5(FALSE), mk_p5(TRUE), "fig-05-iniciativas-partido", w = 1500, h = 820)

message("Listo. Figuras en: ", normalizePath(out_dir))
