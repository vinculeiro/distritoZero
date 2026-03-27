---
translationKey: proxectos
title: Proyectos
slug: proxectos
menu:
  main:
    name: Proyectos
    weight: 6
    params:
      icon: layout-grid
comments: false
---

Aplicaciones interactivas y visores ligados a los análisis. La tarjeta abre la **versión integrada** en el mismo servidor Hugo (<code>/apps/plenos-lalin/</code>). Tras cambiar la app, ejecuta <code>npm run build</code> en <code>app_react</code> y <code>scripts/sync-plenos-app.ps1</code> en la raíz de este repo.

<div class="project-grid" role="list">

{{< proxectos-plenos-card >}}

</div>
