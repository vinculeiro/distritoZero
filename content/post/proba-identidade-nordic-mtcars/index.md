---
translationKey: proba-identidade-nordic-mtcars
title: "Proba de identidade · Paleta Nordic Frost (mtcars)"
description: "Exploración con ggplot2 e datos mtcars usando a opción B da guía de marca"
date: 2026-03-25
slug: proba-identidade-nordic-mtcars
image: cover.png
image_alt: "Gráfico de barras horizontais de consumo medio por cilindrada, cores índigo e fondo claro"
og_image: "img/og/proba-identidade-nordic-mtcars.png"
categories:
  - Opinión
tags:
  - Identidade gráfica
  - ggplot2
  - R
  - mtcars
weight: 95
---

Artigo de **proba** para ver como a **paleta cromática B (Nordic Frost)** —índigo, cian e ámbar— queda nun post do blog, con gráficos feitos en **R** e o tema definido en `identidade_grafica` (`R/tema_proxecto.R`). Os datos son o clásico conxunto **mtcars**.

Cada gráfico ten **dúas versións exportadas** (fondo claro e fondo escuro). Ao **cambiar o modo da web** (claro / escuro) no tema Stack, o CSS mostra unha ou outra automaticamente (`html[data-scheme]`).

As figuras xéranse con `Rscript scripts/render_post_proba_nordic_mtcars.R` na raíz do repositorio (require o cartafol xemelgo `00_infraestrutura/identidade_grafica`).

## Barras horizontais

Consumo medio (mpg) por número de cilindros.

{{< chart-dual light="fig-01-barras-light.png" dark="fig-01-barras-dark.png" alt="Barras horizontais: mpg medio por cilindrada" >}}

## Lollipop

Os doce modelos con maior potencia (hp).

{{< chart-dual light="fig-02-lollipop-light.png" dark="fig-02-lollipop-dark.png" alt="Lollipop dos modelos con maior hp" >}}

## Dispersión

Peso (`wt`) fronte a rendemento (`mpg`), cor por cilindrada; recta de tendencia global.

{{< chart-dual light="fig-03-scatter-light.png" dark="fig-03-scatter-dark.png" alt="Dispersión wt vs mpg con etiquetas" >}}

## Mapa de calor · correlacións

Correlacións de Pearson entre sete variables numéricas.

{{< chart-dual light="fig-04-heatmap-light.png" dark="fig-04-heatmap-dark.png" alt="Matriz de correlación" >}}

## Ridgeline

Distribución de `mpg` por grupo de cilindrada.

{{< chart-dual light="fig-05-ridgeline-light.png" dark="fig-05-ridgeline-dark.png" alt="Densidades ridgeline por cilindrada" >}}

## Bump chart

Ranking das cilindradas segundo mpg medio dentro de cada valor de `gear`.

{{< chart-dual light="fig-06-bump-light.png" dark="fig-06-bump-dark.png" alt="Bump chart ranking por marchas" >}}

## Waffle

Proporción de coches por cilindrada (1 cadrado = 1 unidade; total 32).

{{< chart-dual light="fig-07-waffle-light.png" dark="fig-07-waffle-dark.png" alt="Waffle de composición por cilindrada" >}}

## Serie con banda

Índice ordenado por tipo de caixa e tendencia suavizada (proxy de serie temporal).

{{< chart-dual light="fig-08-serie-light.png" dark="fig-08-serie-dark.png" alt="Liña con banda e punto de referencia" >}}

---

*Proba paleta B · Nordic Frost · distritoZero*
