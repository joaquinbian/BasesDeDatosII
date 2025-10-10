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

