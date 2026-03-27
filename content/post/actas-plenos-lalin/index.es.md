---
translationKey: actas-plenos-lalin
title: "Actas y votaciones de los plenos (Lalín) · vista desde los datos"
description: "Gráficos en R con los JSON de la app de exploración de actas y el análisis en 02_scripts"
date: 2026-03-25
slug: actas-plenos-lalin
image: fig-01-tipos-lexislatura-light.png
image_alt: "Barras apiladas: tipos de votación por legislatura"
categories:
  - Opinión
tags:
  - R
  - ggplot2
  - Datos abiertos
  - Lalín
weight: 90
---

Este artículo resume **varias vistas** de los **plenos municipales de Lalín** usando los mismos **datos JSON** que alimentan la aplicación React (`app_react/src/data/`). La investigación original está en el proyecto de actas (`02_scripts`, sobre todo `05_analise_votacions_plenos.R`); aquí las figuras usan la **paleta B (Nordic Frost)** de `identidade_grafica`, en versión **clara y oscura** para el tema del blog.

Si los JSON no están actualizados, en el repo de actas puedes regenerarlos con `02_scripts/export_json.R` antes de renderizar.

Las figuras se generan en la raíz de **distritoZero** con:

```text
Rscript scripts/render_post_actas_plenos_lalin.R
```

Si el repositorio de actas no está en `../02_administracion/actas_organos_colexiados` respecto a distritoZero, define la variable de entorno **`ACTAS_ROOT`** con la ruta absoluta a `actas_organos_colexiados`.

## Tipo de votación por legislatura

Equivalente a la lógica del gráfico **G01** de la app (unanimidad, mano alzada, ordinaria).

{{< chart-dual light="fig-01-tipos-lexislatura-light.png" dark="fig-01-tipos-lexislatura-dark.png" alt="Tipos de votación por legislatura, barras apiladas en porcentaje" >}}

## Conflictividad a lo largo del tiempo

Porcentaje de votaciones **no unánimes** por semestre; el tamaño del punto indica cuántas votaciones hay en ese intervalo.

{{< chart-dual light="fig-02-conflitividade-semestre-light.png" dark="fig-02-conflitividade-semestre-dark.png" alt="Línea y área: porcentaje de votaciones no unánimes por semestre" >}}

## Resultado de las votaciones

Distribución de los resultados registrados.

{{< chart-dual light="fig-03-resultado-votacions-light.png" dark="fig-03-resultado-votacions-dark.png" alt="Barras horizontales: número de votaciones por resultado" >}}

## Temas en el orden del día

Frecuencia de **tema** en el índice de puntos (`indice.json`).

{{< chart-dual light="fig-04-temas-indice-light.png" dark="fig-04-temas-indice-dark.png" alt="Barras: temas más frecuentes en el índice de actas" >}}

## Iniciativas por partido

Mociones, mociones de urgencia y solicitudes por **partido** y **legislatura**.

{{< chart-dual light="fig-05-iniciativas-partido-light.png" dark="fig-05-iniciativas-partido-dark.png" alt="Barras por legislatura: iniciativas por partido" >}}

---

*Paleta B · Nordic Frost · distritoZero · datos: actas plenos Lalín*
