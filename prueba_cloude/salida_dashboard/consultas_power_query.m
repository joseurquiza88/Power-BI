// =========================================================================
// POWER QUERY (M) - PROYECTO VENTAS PRUEBA CLOUD
// =========================================================================
// Ubicación de archivos fuente: D:\Josefina\Proyectos\Datascience\Power-BI\prueba_cloude\

// -------------------------------------------------------------------------
// 1. Dim_Clientes
// -------------------------------------------------------------------------
let
    Origen = Csv.Document(File.Contents("D:\Josefina\Proyectos\Datascience\Power-BI\prueba_cloude\clientes.csv"),[Delimiter=",", Columns=3, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Encabezados promovidos" = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{
        {"id_cliente", type text},
        {"region", type text},
        {"segmento", type text}
    })
in
    #"Tipo cambiado"


// -------------------------------------------------------------------------
// 2. Dim_Pedidos
// -------------------------------------------------------------------------
let
    Origen = Csv.Document(File.Contents("D:\Josefina\Proyectos\Datascience\Power-BI\prueba_cloude\pedidos.csv"),[Delimiter=",", Columns=3, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Encabezados promovidos" = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{
        {"id_pedido", type text},
        {"fecha", type date},
        {"id_cliente", type text}
    })
in
    #"Tipo cambiado"


// -------------------------------------------------------------------------
// 3. Dim_Productos
// -------------------------------------------------------------------------
let
    Origen = Csv.Document(File.Contents("D:\Josefina\Proyectos\Datascience\Power-BI\prueba_cloude\productos.csv"),[Delimiter=",", Columns=5, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Encabezados promovidos" = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{
        {"id_producto", type text},
        {"producto", type text},
        {"categoria", type text},
        {"precio", type number},
        {"costo", type number}
    })
in
    #"Tipo cambiado"


// -------------------------------------------------------------------------
// 4. Fact_Detalle_Pedidos (Separado por tabulaciones #(tab))
// -------------------------------------------------------------------------
let
    Origen = Csv.Document(File.Contents("D:\Josefina\Proyectos\Datascience\Power-BI\prueba_cloude\detalle_pedidos.csv"),[Delimiter="#(tab)", Columns=6, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Encabezados promovidos" = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{
        {"id_detalle", Int64.Type},
        {"id_pedido", type text},
        {"id_producto", type text},
        {"cantidad", Int64.Type},
        {"precio_unitario", type number},
        {"descuento", type number}
    })
in
    #"Tipo cambiado"


// -------------------------------------------------------------------------
// 5. Dim_Calendario (Generada dinámicamente para el año 2025)
// -------------------------------------------------------------------------
let
    FechaInicio = #date(2025, 1, 1),
    FechaFin = #date(2025, 12, 31),
    TotalDias = Duration.Days(FechaFin - FechaInicio) + 1,
    ListaFechas = List.Dates(FechaInicio, TotalDias, #duration(1, 0, 0, 0)),
    Tabla = Table.FromList(ListaFechas, Splitter.SplitByNothing(), {"Fecha"}, null, ExtraValues.Error),
    TipoFecha = Table.TransformColumnTypes(Tabla,{{"Fecha", type date}}),
    ColAnio = Table.AddColumn(TipoFecha, "Año", each Date.Year([Fecha]), Int64.Type),
    ColNroMes = Table.AddColumn(ColAnio, "NroMes", each Date.Month([Fecha]), Int64.Type),
    ColMes = Table.AddColumn(ColNroMes, "Mes", each Date.ToText([Fecha], "MMMM", "es-ES"), type text),
    ColMesAnio = Table.AddColumn(ColMes, "Mes-Año", each Date.ToText([Fecha], "MMM-yyyy", "es-ES"), type text),
    ColTrimestre = Table.AddColumn(ColMesAnio, "Trimestre", each "T" & Text.From(Date.QuarterOfYear([Fecha])), type text),
    ColDiaSemana = Table.AddColumn(ColTrimestre, "Día Semana", each Date.ToText([Fecha], "dddd", "es-ES"), type text)
in
    ColDiaSemana


// -------------------------------------------------------------------------
// 6. _Medidas (Tabla contenedora vacía para organizar las medidas DAX)
// -------------------------------------------------------------------------
let
    Origen = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i44FAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Column1 = _t]),
    #"Tipo cambiado" = Table.TransformColumnTypes(Origen,{{"Column1", type text}}),
    #"Columnas quitadas" = Table.RemoveColumns(#"Tipo cambiado",{"Column1"})
in
    #"Columnas quitadas"
