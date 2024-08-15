SELECT 
    lin.ID, 
    lin.nombre, 
    lin.sistema, 
    lin.Anio_inauguracion,
    lin.color_en, 
    lin.color_esp,
    lin.tam_km,
    lin.existe,
    lin.ramal_id,
    lin.linea_base_ramal,
    ----
    deslin.terminal_original,
    deslin.inicio_original as Inicio_Original_Descripcion, 
    deslin.direccion as Direccion_Descripcion,
    deslin.anio_inicio_ampliacion as Anio_Inicio_Ampliacion_Descripcion,
    --deslin.anio_fin_ampliacion as Anio_Fin_Ampliacion_Descripcion
FROM lineas lin
JOIN descripcion_lineas deslin
ON lin.id = deslin.Linea_base
where terminal_original= 'Zocalo';



linea = lin

descripcion_linea deslin