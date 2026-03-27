---
translationKey: proba-identidade-nordic-mtcars
title: "Prueba de identidad · Paleta Nordic Frost (mtcars)"
description: "Exploración con ggplot2 y datos mtcars usando la opción B de la guía de marca"
date: 2026-03-25
slug: proba-identidade-nordic-mtcars
image: cover.png
image_alt: "Gráfico de barras horizontales de consumo medio por cilindrada, colores índigo y fondo claro"
og_image: "img/og/proba-identidade-nordic-mtcars.png"
categories:
  - Opinión
tags:
  - Identidad gráfica
  - ggplot2
  - R
  - mtcars
weight: 95
---

Artículo de **prueba** para ver cómo la **paleta cromática B (Nordic Frost)** —índigo, cian y ámbar— queda en una entrada del blog, con gráficos hechos en **R** y el tema definido en `identidade_grafica` (`R/tema_proxecto.R`). Los datos son el clásico conjunto **mtcars**.

Cada gráfico tiene **dos versiones exportadas** (fondo claro y fondo oscuro). Al **cambiar el modo de la web** (claro / oscuro) en el tema Stack, el CSS muestra una u otra automáticamente (`html[data-scheme]`).

Las figuras se generan con `Rscript scripts/render_post_proba_nordic_mtcars.R` en la raíz del repositorio (requiere la carpeta hermana `00_infraestrutura/identidade_grafica`).

## Barras horizontales

Consumo medio (mpg) por número de cilindros.

{{< chart-dual light="fig-01-barras-light.png" dark="fig-01-barras-dark.png" alt="Barras horizontales: mpg medio por cilindrada" >}}

## Lollipop

Los doce modelos con mayor potencia (hp).

{{< chart-dual light="fig-02-lollipop-light.png" dark="fig-02-lollipop-dark.png" alt="Lollipop de los modelos con mayor hp" >}}

## Dispersión

Peso (`wt`) frente a rendimiento (`mpg`), color por cilindrada; recta de tendencia global.

{{< chart-dual light="fig-03-scatter-light.png" dark="fig-03-scatter-dark.png" alt="Dispersión wt vs mpg con etiquetas" >}}

## Mapa de calor · correlaciones

Correlaciones de Pearson entre siete variables numéricas.

{{< chart-dual light="fig-04-heatmap-light.png" dark="fig-04-heatmap-dark.png" alt="Matriz de correlación" >}}

## Ridgeline

Distribución de `mpg` por grupo de cilindrada.

{{< chart-dual light="fig-05-ridgeline-light.png" dark="fig-05-ridgeline-dark.png" alt="Densidades ridgeline por cilindrada" >}}

## Bump chart

Ranking de cilindradas según mpg medio dentro de cada valor de `gear`.

{{< chart-dual light="fig-06-bump-light.png" dark="fig-06-bump-dark.png" alt="Bump chart de ranking por marchas" >}}

## Waffle

Proporción de coches por cilindrada (1 cuadrado = 1 unidad; total 32).

{{< chart-dual light="fig-07-waffle-light.png" dark="fig-07-waffle-dark.png" alt="Waffle de composición por cilindrada" >}}

## Serie con banda

Índice ordenado por tipo de caja y tendencia suavizada (aproximación a serie temporal).

{{< chart-dual light="fig-08-serie-light.png" dark="fig-08-serie-dark.png" alt="Línea con banda y punto de referencia" >}}

---

*Prueba paleta B · Nordic Frost · distritoZero*
