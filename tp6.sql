USE DBArchivos
GO

-- Los nombres y extensiones y tamaño en Megabytes de los archivos que pesen más que el promedio de archivos.
DECLARE @BYTES_TO_MB int
SET @BYTES_TO_MB = 1048576

DECLARE @AVG_SIZE_FILES DECIMAL
SET @AVG_SIZE_FILES = (SELECT AVG(Tamanio * 1.0) FROM Archivos)

SELECT Nombre, Extension, Tamanio / @BYTES_TO_MB as TamanioMB FROM Archivos
WHERE Tamanio > @AVG_SIZE_FILES


SELECT @AVG_SIZE_FILES / @BYTES_TO_MB



-- Los usuarios indicando apellido y nombre que no sean dueños de ningún archivo con extensión 'zip'.

SELECT Nombre, Apellido FROM Usuarios
WHERE IDUsuario NOT IN (SELECT IDUsuarioDuenio FROM Archivos WHERE Extension LIKE 'zip')



-- Los usuarios indicando IDUsuario, apellido, nombre y tipo de usuario que no hayan creado ni modificado ningún archivo en el año actual.
SELECT IDUsuario, Apellido, Nombre, TU.TipoUsuario FROM Usuarios U
INNER JOIN TiposUsuario TU ON U.IDTipoUsuario = TU.IDTipoUsuario
WHERE U.IDUsuario NOT IN(
    SELECT A.IDUsuarioDuenio FROM Archivos A 
    WHERE YEAR(A.FechaCreacion) = YEAR(GETDATE()) OR YEAR(A.FechaUltimaModificacion) =  YEAR(GETDATE()) 
    )


-- Los tipos de usuario que no registren usuario con archivos eliminados.
SELECT DISTINCT TU.TipoUsuario, TU.IDTipoUsuario FROM TiposUsuario TU
WHERE TU.IDTipoUsuario NOT IN (
    SELECT distinct U.IDTipoUsuario FROM Usuarios U
    INNER JOIN Archivos A ON U.IDUsuario = A.IDUsuarioDuenio
    WHERE Eliminado = 1
)

-- Los tipos de archivos que no se hayan compartido con el permiso de 'Lectura'
SELECT TA.TipoArchivo FROM TiposArchivos TA 
WHERE NOT EXISTS (
SELECT A.IDTipoArchivo FROM ArchivosCompartidos AC
INNER JOIN Permisos P ON AC.IDPermiso = P.IDPermiso
INNER JOIN Archivos A ON AC.IDArchivo = A.IDArchivo
WHERE P.Nombre = 'Lectura' AND A.IDTipoArchivo = TA.IDTipoArchivo
)


-- Los nombres y extensiones de los archivos que tengan un tamaño mayor al del archivo con extensión 'xls' más grande.
SELECT Nombre, Extension from Archivos WHERE Tamanio > (
    SELECT MAX(Tamanio) FROM Archivos WHERE Extension = 'xls'
)


-- Los nombres y extensiones de los archivos que tengan un tamaño mayor al del archivo con extensión 'zip' más pequeño.
SELECT Nombre, Extension from Archivos WHERE Tamanio > (
    SELECT MIN(Tamanio) FROM Archivos WHERE Extension = 'zip'
)


-- Por cada tipo de archivo indicar el tipo y la cantidad de archivos eliminados y la cantidad de archivos no eliminados.
SELECT TA.TipoArchivo, 
(
    SELECT COUNT(*) FROM Archivos A WHERE Eliminado = 1 AND A.IDTipoArchivo = TA.IDTipoArchivo
) AS 'Archivos Eliminados',
(
    SELECT COUNT(*) FROM Archivos A WHERE Eliminado = 0 AND A.IDTipoArchivo = TA.IDTipoArchivo
) AS 'Archivos NO Eliminados'
FROM TiposArchivos TA



--Por cada usuario indicar el IDUsuario, el apellido, el nombre 
--la cantidad de archivos pequeños (menos de 20MB) y la cantidad de archivos grandes (20MBs o más)
DECLARE @BYTES_TO_MB int
SET @BYTES_TO_MB = 1048576

SELECT U.IDUsuario, U.Apellido, U.Nombre,
(
    SELECT COUNT(*) FROM Archivos A WHERE U.IDUsuario = A.IDUsuarioDuenio AND A.Tamanio * 1.0 / @BYTES_TO_MB < 20 
) AS 'Archivos Pequenios',
(
    SELECT COUNT(*) FROM Archivos A WHERE U.IDUsuario = A.IDUsuarioDuenio AND A.Tamanio * 1.0 / @BYTES_TO_MB >= 20 

) AS 'Archivos Grandes'
FROM Usuarios U

-- Por cada usuario indicar el IDUsuario, el apellido, el nombre 
-- y la cantidad de archivos creados en el año 2022, la cantidad en el año 2023 y la cantidad creados en el 2024.

SELECT 
U.IDUsuario, U.Apellido, U.Nombre,
(
    SELECT COUNT(*) FROM Archivos A WHERE A.IDUsuarioDuenio = U.IDUsuario AND YEAR(A.FechaCreacion) = 2022
) AS 'Archivos 2022',
(
    SELECT COUNT(*) FROM Archivos A WHERE A.IDUsuarioDuenio = U.IDUsuario AND YEAR(A.FechaCreacion) = 2023
) AS 'Archivos 2023',
(
    SELECT COUNT(*) FROM Archivos A WHERE A.IDUsuarioDuenio = U.IDUsuario AND YEAR(A.FechaCreacion) = 2024
) AS 'Archivos 2024'
 FROM Usuarios U


 -- Los archivos que fueron compartidos con permiso de 'Comentario' pero no con permiso de 'Lectura'

SELECT * FROM (
SELECT a.Nombre, 
(
    SELECT COUNT(*) FROM ArchivosCompartidos AC 
    INNER JOIN Permisos P ON P.IDPermiso = AC.IDPermiso
    WHERE Nombre = 'Lectura' AND AC.IDArchivo = A.IDArchivo
)AS 'Archivos Lectura',
(
    SELECT COUNT(*) FROM ArchivosCompartidos AC 
    INNER JOIN Permisos P ON P.IDPermiso = AC.IDPermiso
    WHERE Nombre = 'Comentario' AND AC.IDArchivo = A.IDArchivo
)AS 'Archivos Comentario'

 FROM Archivos A
) AS Auxiliar WHERE [Archivos Comentario] >= 1 AND [Archivos Lectura] = 0


-- Los tipos de archivos que registran más archivos eliminados que no eliminados.
SELECT * FROM (SELECT 
TA.TipoArchivo,
(SELECT COUNT(*) FROM Archivos A WHERE Eliminado = 1 AND A.IDTipoArchivo = TA.IDTipoArchivo) as ArchivosEliminados,  
(SELECT COUNT(*) FROM Archivos A WHERE Eliminado = 0 AND A.IDTipoArchivo = TA.IDTipoArchivo) as ArchivosNOEliminados 
 FROM TiposArchivos TA) AS AUXILIAR WHERE ArchivosEliminados > ArchivosNOEliminados