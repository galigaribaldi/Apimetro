------------------------------------------------------------
------------------------------------------------------------
--------------------====Consulta maestra===-----------------
------(Descripción de las columnas, tipo de columna)--------
------(llaves primarias, llaves foráneas y relaciones)------
------------------------------------------------------------
------------------------------------------------------------
SELECT
    cols.column_name,
    cols.data_type,
    CASE
        WHEN pk.column_name IS NOT NULL THEN 'Primary Key'
        WHEN fk.column_name IS NOT NULL THEN 'Foreign Key'
        ELSE 'None'
    END AS constraint_type,
    fk.foreign_table_name AS references_table
FROM
    information_schema.columns cols
    -- Identificar Llaves Primarias
    LEFT JOIN (
        SELECT kcu.column_name, kcu.table_name, kcu.table_schema
        FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
            AND tc.table_schema = kcu.table_schema
        WHERE
            tc.constraint_type = 'PRIMARY KEY'
    ) pk ON cols.table_name = pk.table_name
    AND cols.column_name = pk.column_name
    AND cols.table_schema = pk.table_schema
    -- Identificar Llaves Foráneas y su tabla destino
    LEFT JOIN (
        SELECT kcu.column_name, kcu.table_name, kcu.table_schema, ccu.table_name AS foreign_table_name
        FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
            AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
        WHERE
            tc.constraint_type = 'FOREIGN KEY'
    ) fk ON cols.table_name = fk.table_name
    AND cols.column_name = fk.column_name
    AND cols.table_schema = fk.table_schema
WHERE
    cols.table_name = 'historico_operacion'
    AND cols.table_schema = 'public'
ORDER BY cols.ordinal_position;
--------------------
--------------------