USE DBArchivos;
GO

-- Por cada usuario listar el nombre, apellido y el nombre del tipo de usuario.
SELECT Nombre, Apellido, TiposUsuario.TipoUsuario FROM Usuarios INNER JOIN TiposUsuario ON Usuarios.IDTipoUsuario = TiposUsuario.IDTipoUsuario;


-- Listar el ID, nombre, apellido y tipo de usuario de aquellos usuarios que sean del tipo 'Suscripción Free' o 'Suscripción Básica'
SELECT Nombre, Apellido, TiposUsuario.TipoUsuario FROM Usuarios 
INNER JOIN TiposUsuario ON Usuarios.IDTipoUsuario = TiposUsuario.IDTipoUsuario 
WHERE TiposUsuario.TipoUsuario LIKE 'Suscripcion Free' OR TiposUsuario.TipoUsuario LIKE 'Suscripcion Basica';


-- Listar los nombres de archivos, extensión, tamaño expresado en Megabytes y el nombre del tipo de archivo.
--NOTA: En la tabla Archivos el tamaño está expresado en Bytes.

SELECT Nombre, Extension, Tamanio AS 'Tamanio en Bytes', Tamanio / 1048576 AS 'Tamanio en MB' FROM Archivos
INNER JOIN TiposArchivos ON Archivos.IDTipoArchivo = TiposArchivos.IDTipoArchivo;


-- Listar los nombres de archivos junto a la extensión con el siguiente formato 'NombreArchivo.extension'. Por ejemplo, 'Actividad.pdf'.
--Sólo listar aquellos cuyo tipo de archivo contenga los términos 'ZIP', 'Word', 'Excel', 'Javascript' o 'GIF'
SELECT Nombre + '.' + Extension AS 'Archivo' FROM Archivos
INNER JOIN TiposArchivos ON Archivos.IDTipoArchivo = TiposArchivos.IDTipoArchivo
WHERE TiposArchivos.TipoArchivo LIKE '%ZIP%' 
OR  TiposArchivos.TipoArchivo LIKE '%JavaScript%' 
OR  TiposArchivos.TipoArchivo LIKE '%Word%' 
OR  TiposArchivos.TipoArchivo LIKE '%Excel%' 
OR  TiposArchivos.TipoArchivo LIKE '%GIF%' ;


-- Listar los nombres de archivos, su extensión, el tamaño en megabytes y la fecha de creación de aquellos archivos que le pertenezcan al usuario dueño con nombre 'Michael' y apellido 'Williams'.