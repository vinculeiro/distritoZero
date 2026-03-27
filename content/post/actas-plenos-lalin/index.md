---
translationKey: actas-plenos-lalin
title: "Actas e votacións dos plenos (Lalín) · vista dende os datos"
description: "Gráficos en R cos JSON da app de exploración das actas e a análise en 02_scripts"
date: 2026-03-25
slug: actas-plenos-lalin
image: fig-01-tipos-lexislatura-light.png
image_alt: "Barras apiladas: tipos de votación por lexislatura"
categories:
  - Opinión
tags:
  - R
  - ggplot2
  - Datos abertos
  - Lalín
weight: 90
---

Este artigo resume **varias vistas** dos **plenarios municipais de Lalín** usando os mesmos **datos JSON** que alimentan a aplicación React de consulta das actas (`app_react/src/data/`). A investigación orixinal e as táboas están no proxecto de actas (`02_scripts`, en particular `05_analise_votacions_plenos.R`); aquí exportáronse figuras coa **identidade gráfica Nordic Frost (paleta B)** de `identidade_grafica`, en versión **clara e escura** para o tema do blog.

Se os JSON non están ao día, no repo de actas podes volver xeralos con `02_scripts/export_json.R` antes de renderizar.

As figuras xéranse na raíz de **distritoZero** con:

```text
Rscript scripts/render_post_actas_plenos_lalin.R
```

Se o repositorio de actas non está en `../02_administracion/actas_organos_colexiados` respecto a distritoZero, define a variable de entorno **`ACTAS_ROOT`** coa ruta absoluta a `actas_organos_colexiados`.

## Tipo de votación por lexislatura

Equivalente á lóxica do gráfico **G01** da app (unanimidade, man alzada, ordinaria); as cores dos tipos coinciden coa visualización React.

{{< chart-dual light="fig-01-tipos-lexislatura-light.png" dark="fig-01-tipos-lexislatura-dark.png" alt="Tipos de votación por lexislatura, barras apiladas en porcentaxe" >}}

## Conflitividade ao longo do tempo

Porcentaxe de votacións **non unánimes** (man alzada ou ordinaria) por semestre; o tamaño do punto indica cantas votacións hai nese intervalo.

{{< chart-dual light="fig-02-conflitividade-semestre-light.png" dark="fig-02-conflitividade-semestre-dark.png" alt="Liña e área: porcentaxe de votacións non unánimes por semestre" >}}

## Resultado das votacións

Distribución dos resultados rexistrados nas votacións parseadas.

{{< chart-dual light="fig-03-resultado-votacions-light.png" dark="fig-03-resultado-votacions-dark.png" alt="Barras horizontais: número de votacións por resultado" >}}

## Temas na orde do día

Frecuencia de **tema** no índice de puntos (`indice.json`).

{{< chart-dual light="fig-04-temas-indice-light.png" dark="fig-04-temas-indice-dark.png" alt="Barras: temas máis frecuentes no índice de actas" >}}

## Iniciativas por partido

Mocións, mocións de urxencia e solicitudes por **partido** e **lexislatura** (visión próxima ao bloque C3 da análise en R).

{{< chart-dual light="fig-05-iniciativas-partido-light.png" dark="fig-05-iniciativas-partido-dark.png" alt="Barras por faceta de lexislatura: iniciativas por partido" >}}

---

*Paleta B · Nordic Frost · distritoZero · datos: actas plenos Lalín*
