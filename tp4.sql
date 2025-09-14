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

SELECT Archivos.Nombre, Extension, Tamanio AS 'Tamanio en Bytes', Tamanio / 1048576 AS 'Tamanio en MB', FechaCreacion FROM Archivos
INNER JOIN Usuarios ON Archivos.IDUsuarioDuenio = Usuarios.IDUsuario
WHERE Usuarios.Nombre LIKE 'Michael' AND Usuarios.Apellido LIKE 'Williams';


-- Listar los datos completos del archivo más pesado del usuario dueño con nombre 'Michael' y apellido 'Williams'. 
-- Si hay varios archivos que cumplen esa condición, listarlos a todos.

SELECT * FROM Archivos
INNER JOIN Usuarios ON Archivos.IDUsuarioDuenio = Usuarios.IDUsuario
WHERE Usuarios.Nombre LIKE 'Michael' AND Usuarios.Apellido LIKE 'Williams'
 AND Archivos.Tamanio = (
    SELECT MAX(Tamanio) FROM Archivos INNER JOIN Usuarios ON Archivos.IDUsuarioDuenio = Usuarios.IDUsuario
    WHERE Usuarios.Nombre LIKE 'Michael' AND Usuarios.Apellido LIKE 'Williams'
 )
;

-- Listar nombres de archivos, extensión, tamaño en bytes, fecha de creación y de modificación, apellido y nombre del usuario dueño de aquellos archivos cuya descripción contengan el término 'empresa' o 'presupuesto'

SELECT Archivos.Nombre, Extension, Tamanio, FechaCreacion, FechaUltimaModificacion, Usuarios.Apellido, Usuarios.Nombre FROM Archivos
INNER JOIN Usuarios ON Archivos.IDUsuarioDuenio = Usuarios.IDUsuario
WHERE Descripcion LIKE '%empresa%' OR Descripcion LIKE '%presupuesto%';

-- Listar las extensiones sin repetir de los archivos cuyos usuarios dueños tengan tipo de usuario 'Suscripción Plus', 'Suscripción Premium' o 'Suscripción Empresarial'
SELECT Extension, TipoUsuario FROM Archivos 
INNER JOIN Usuarios ON IDUsuarioDuenio = IDUsuario
INNER JOIN TiposUsuario ON Usuarios.IDTipoUsuario = TiposUsuario.IDTipoUsuario 
WHERE TipoUsuario LIKE 'Suscripcion Plus' OR TipoUsuario LIKE 'Suscripcion Empresarial' OR TipoUsuario LIKE 'Suscripcion Premium';



-- Listar los apellidos y nombres de los usuarios dueños y el tamaño del archivo de los tres archivos con extensión 'zip' más pesados.
-- Puede ocurrir que el mismo usuario aparezca varias veces en el listado.


SELECT TOP 3 Usuarios.Nombre, Usuarios.Apellido, Tamanio FROM Archivos
INNER JOIN Usuarios ON Archivos.IDUsuarioDuenio = Usuarios.IDUsuario
WHERE Extension LIKE 'zip'
ORDER BY Tamanio ASC; 


-- Por cada archivo listar el nombre del archivo, la extensión, el tamaño en bytes, el nombre del tipo de archivo y el tamaño calculado en su mayor expresión y la unidad calculada. 
--Siendo Gigabytes si al menos pesa un gigabyte, Megabytes si al menos pesa un megabyte, Kilobyte si al menos pesa un kilobyte o en su defecto expresado en bytes.
--Por ejemplo, si el archivo imagen.jpg pesa 40960 bytes entonces debe figurar 40 en la columna Tamaño Calculado y 'Kilobytes' en la columna unidad


SELECT Nombre, Extension, Tamanio, TipoArchivo,
CASE WHEN Tamanio >= 1073741824 THEN Tamanio / 1073741824 --GB
WHEN Tamanio >= 1048576 THEN Tamanio / 1048576 --MB
WHEN Tamanio >= 1024 THEN Tamanio / 1024 --KB
ELSE Tamanio  END AS 'Tamanio Calculado',

CASE WHEN Tamanio >= 1073741824 THEN 'Gigabytes' --GB
WHEN Tamanio >= 1048576 THEN 'Megabytes' --MB
WHEN Tamanio >= 1024 THEN 'Kilobytes' --KB
ELSE 'Bytes'  END AS 'Unidad'
FROM Archivos
INNER JOIN TiposArchivos ON Archivos.IDTipoArchivo = TiposArchivos.IDTipoArchivo
;

-- Listar los nombres de archivo y extensión de los archivos que han sido compartidos.
SELECT Nombre, Extension FROM Archivos A 
INNER JOIN ArchivosCompartidos AC ON A.IDArchivo = AC.IDArchivo;



-- Listar los nombres de archivo y extensión de los archivos que han sido compartidos a usuarios con apellido 'Clarck' o 'Jones'
SELECT A.Nombre, Extension FROM Archivos A 
INNER JOIN ArchivosCompartidos AC ON A.IDArchivo = AC.IDArchivo
INNER JOIN Usuarios U ON AC.IDUsuario = U.IDUsuario
WHERE AC.IDUsuario IN (SELECT IDUsuario FROM Usuarios WHERE Apellido LIKE 'Clarck' OR Apellido LIKE 'Jones');


-- Listar los nombres de archivo, extensión, apellidos y nombres de los usuarios a quienes se le hayan compartido archivos con permiso de 'Escritura'

SELECT A.Nombre, A.Extension, U.Apellido, U.Nombre FROM ArchivosCompartidos AC
INNER JOIN Archivos A ON AC.IDArchivo = A.IDArchivo
INNER JOIN Usuarios U ON U.IDUsuario = AC.IDUsuario
INNER JOIN Permisos P ON AC.IDPermiso = P.IDPermiso
WHERE P.Nombre LIKE 'Escritura';

-- Listar los nombres de archivos y extensión de los archivos que no han sido compartidos
SELECT Nombre, Extension FROM Archivos A
LEFT JOIN ArchivosCompartidos AC ON A.IDArchivo = AC.IDArchivo
WHERE AC.IDArchivo IS NULL;

--Listar los apellidos y nombres de los usuarios dueños que tienen archivos eliminados.
SELECT DISTINCT U.Apellido, U.Nombre FROM Usuarios U
INNER JOIN Archivos A ON U.IDUsuario = A.IDUsuarioDuenio
WHERE A.Eliminado = 1;