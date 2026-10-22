# Guía de Implementación: Dashboard de Ventas E-Commerce en Power BI

Proyecto desarrollado para: `D:\Josefina\Proyectos\Datascience\Power-BI\prueba_cloude`  
Archivo principal: `ventas_prueba_cloud.pbip` (Power BI Project / Developer Mode)  
Fecha: Octubre 2026  

---

## 1. Estructura de Archivos Generados

```
D:\Josefina\Proyectos\Datascience\Power-BI\prueba_cloude\
│
├── ventas_prueba_cloud.pbip                <-- Archivo raíz del proyecto (doble clic para abrir en Power BI Desktop)
│
├── ventas_prueba_cloud.Report/             <-- Definición visual del informe
│   ├── definition.pbir                     <-- Vinculación con el modelo semántico
│   └── report.json                         <-- Página 'Resumen de ventas', KPIs, gráficos, segmentadores y tema visual
│
├── ventas_prueba_cloud.SemanticModel/      <-- Modelo semántico (Tabular Model TMSL)
│   ├── definition.pbism                    <-- Metadatos del modelo semántico
│   ├── model.bim                           <-- Tablas, tipos de datos, relaciones 1:N, particiones M y medidas DAX
│   └── .pbi/
│       └── localSettings.json              <-- Configuración regional (es-ES)
│
└── salida_dashboard/                       <-- Carpeta de recursos auxiliares y documentación
    ├── README_INSTRUCCIONES.md             <-- Esta guía técnica completa
    ├── consultas_power_query.m             <-- Código M de todas las tablas (con tabulación en detalle_pedidos)
    ├── medidas_dax.dax                     <-- Código DAX de las 8 medidas con comentarios y formatos
    ├── tema_colores_paleta.json            <-- Archivo de tema visual (Violeta, Lila, Teal, Crema)
    └── resumen_metricas_verificacion.csv   <-- Benchmarks auditados de control de calidad
```

---

## 2. Validación de Datos y Modelo Estrella

Se verificó el 100% de la integridad de los archivos CSV originales:

| Tabla | Tipo | Filas | Clave Primaria | Delimitador | Claves Foráneas / Relaciones | Integridad |
|---|---|---|---|---|---|---|
| **detalle_pedidos** | Fact (Hechos) | 3.774 | `id_detalle` | **Tabulación (`\t`)** | `id_pedido`, `id_producto` | 100% (0 huérfanos) |
| **pedidos** | Dimensión | 2.700 | `id_pedido` | Coma (`,`) | `id_cliente` | 100% (0 huérfanos) |
| **clientes** | Dimensión | 2.200 | `id_cliente` | Coma (`,`) | Ninguna | 100% único |
| **productos** | Dimensión | 40 | `id_producto` | Coma (`,`) | Ninguna | 100% único |
| **Calendario** | Dimensión Fecha | 365 | `Fecha` | Generada dinámicamente | Vinculada con `pedidos[fecha]` | Año 2025 completo |

### Relaciones del Modelo:
1. `detalle_pedidos[id_pedido]` -> `pedidos[id_pedido]` (Muchos a 1)
2. `detalle_pedidos[id_producto]` -> `productos[id_producto]` (Muchos a 1)
3. `pedidos[id_cliente]` -> `clientes[id_cliente]` (Muchos a 1)
4. `pedidos[fecha]` -> `Calendario[Fecha]` (Muchos a 1)

> **Comportamiento del flujo de filtros:**  
> Al filtrar por `Región` (tabla `clientes`), el filtro fluye hacia `pedidos` y de allí hacia `detalle_pedidos`. De igual manera, el filtrado por `Categoría` (`productos`) y `Fecha` (`Calendario`) afecta directamente a la tabla de hechos.

---

## 3. Catálogo de Medidas DAX y Benchmarks de Control

Todas las medidas están creadas en la tabla contenedora `[_Medidas]`:

### 1. Ventas Brutas
* **Fórmula:** `SUMX(detalle_pedidos, detalle_pedidos[cantidad] * detalle_pedidos[precio_unitario])`
* **Formato:** Moneda (`$ #,##0.00`)
* **Valor esperado (Total Año):** `$ 129.578.200,00`

### 2. Ventas Netas
* **Fórmula:** `SUMX(detalle_pedidos, detalle_pedidos[cantidad] * detalle_pedidos[precio_unitario] * (1 - detalle_pedidos[descuento]))`
* **Confirmación técnica de descuento:** Se verificó que el campo `descuento` está expresado como **tasa decimal** (rango `0.00` a `0.40`). Por ende, `(1 - descuento)` aplica la reducción exacta del porcentaje correspondiente.
* **Formato:** Moneda (`$ #,##0.00`)
* **Valor esperado (Total Año):** `$ 115.000.003,60`

### 3. Cantidad de Pedidos
* **Fórmula:** `DISTINCTCOUNT(pedidos[id_pedido])`
* **Formato:** Entero (`#,##0`)
* **Valor esperado:** `2.700`

### 4. Unidades Vendidas
* **Fórmula:** `SUM(detalle_pedidos[cantidad])`
* **Formato:** Entero (`#,##0`)
* **Valor esperado:** `4.500`

### 5. Ticket Promedio
* **Fórmula:** `DIVIDE([Ventas Netas], [Cantidad Pedidos], 0)`
* **Formato:** Moneda (`$ #,##0.00`)
* **Valor esperado:** `$ 42.592,59`

### 6. Costo de Productos Vendidos (COGS)
* **Fórmula:** `SUMX(detalle_pedidos, detalle_pedidos[cantidad] * RELATED(productos[costo]))`
* **Técnica:** Se utiliza `RELATED` navegando la relación 1 a Muchos existente entre `productos` y `detalle_pedidos`, evitando duplicaciones o uniones costosas.
* **Formato:** Moneda (`$ #,##0.00`)
* **Valor esperado:** `$ 86.992.280,00`

### 7. Margen Bruto
* **Fórmula:** `[Ventas Netas] - [Costo de Productos Vendidos]`
* **Formato:** Moneda (`$ #,##0.00`)
* **Valor esperado:** `$ 28.007.723,60`

### 8. Porcentaje de Margen
* **Fórmula:** `DIVIDE([Margen Bruto], [Ventas Netas], 0)`
* **Formato:** Porcentaje (`0.00%`)
* **Valor esperado:** `24,35%`

---

## 4. Diseño del Informe ("Resumen de ventas")

* **Paleta cromática aplicada:**
  * **Violeta principal (`#5E35B1` / `#4A148C`):** Encabezados, títulos y acentos principales.
  * **Lila suave (`#7E57C2` / `#9575CD`):** Barras de ventas mensuales.
  * **Verde azulado / Teal (`#00897B` / `#004D40`):** Barras de categoría, métricas de margen y rentabilidad.
  * **Crema (`#FFF8E7` / `#FDFBF7`):** Fondo de tarjetas KPI y lienzo del informe.
* **Componentes interactivos organizados en el lienzo (1280x720):**
  1. **Banner Superior:** Título "Resumen de Ventas | E-Commerce 2025" con fondo violeta y texto crema.
  2. **Fila de Segmentadores:**
     * Segmentador por Rango de Fecha (`Calendario[Fecha]`).
     * Segmentador por Región (`clientes[region]`).
     * Segmentador por Categoría (`productos[categoria]`).
  3. **Tarjetas KPI:**
     * Ventas Netas (`$115.00M`)
     * Total Pedidos (`2.700`)
     * Unidades Vendidas (`4.500`)
     * Margen Bruto (`$28.01M`)
  4. **Gráfico de Columnas:** Evolución mensual de ventas netas de Enero a Diciembre 2025 (`Calendario[Mes]` ordenado cronológicamente por `Calendario[NroMes]`).
  5. **Gráfico de Barras:** Ventas netas ordenadas por categoría de producto (`productos[categoria]`).

---

## 5. Cómo abrir y utilizar el proyecto en Power BI Desktop

### Opción A (Recomendada y directa):
1. Abrí el archivo `ventas_prueba_cloud.pbip` haciendo doble clic o desde **Power BI Desktop** > **Archivo** > **Abrir**.
2. Al abrirse por primera vez, si Power BI muestra una barra amarilla solicitando *"Aplicar cambios"* o *"Actualizar"*, hacé clic en **Actualizar** (Refresh) en la pestaña Inicio.
3. El motor de Power BI leerá automáticamente las particiones M configuradas con las rutas relativas a los CSV locales y renderizará el informe interactivo de inmediato.

### Opción B (Importación de tema o consultas si querés recrear o editar algo manualmente):
* Si querés importar el tema en otro informe: En Power BI Desktop andá a **Ver** > menú desplegable de **Temas** > **Buscar temas** y seleccioná `salida_dashboard/tema_colores_paleta.json`.
* Si deseás inspeccionar o modificar las consultas Power Query: En **Inicio** > **Transformar datos** > **Editor avanzado**, podés contrastar con `salida_dashboard/consultas_power_query.m`.

