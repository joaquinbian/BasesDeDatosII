USE DBArchivos;
GO

-- Todos los usuarios indicando Apellido, Nombre.
SELECT Apellido, Nombre FROM Usuarios;



-- Todos los usuarios indicando Apellido y Nombre con el formato: [Apellido], [Nombre] (ordenados por Apellido en forma descendente). 
SELECT Apellido + ', ' + Nombre AS 'Apellido y Nombre' FROM Usuarios ORDER BY Apellido DESC;


-- Los usuarios cuyo IDTipoUsuario sea 5 (indicando Nombre, Apellido)
SELECT Apellido + ', ' + Nombre AS 'Apellido y Nombre' FROM Usuarios WHERE IDUsuario = 5;

-- El último usuario del listado en orden alfabético (ordenado por Apellido y luego por Nombre). Indicar IDUsuario, Apellido y Nombre.
SELECT TOP 1 Apellido + ', ' + Nombre AS 'Apellido y Nombre' FROM Usuarios ORDER BY Apellido DESC, Nombre DESC;

-- Los archivos cuyo año de creación haya sido 2021 (Indicar Nombre, Extensión y Fecha de creación).
 SELECT Nombre, Extension, FechaCreacion FROM Archivos WHERE YEAR(FechaCreacion) = 2021;


--Todos los usuarios con el siguiente formato Apellido, Nombre en una nueva columna llamada ApellidoYNombre, en orden alfabético.
SELECT Apellido + ', ' + Nombre AS 'Apellido y Nombre' FROM Usuarios ORDER BY [Apellido y Nombre] ASC;


-- Todos los archivos, indicando el semestre en el cual se produjo su fecha de creación. Indicar Nombre, Extensión, Fecha de Creación 
-- y la frase “Primer Semestre” o “Segundo Semestre” según corresponda.

SELECT 
Nombre, 
Extension, 
FechaCreacion,
CASE WHEN MONTH(FechaCreacion) >= 6 THEN 'Segundo Semestre'
ELSE 'Primer Semestre' END AS 'Semestre'
FROM Archivos;


--Ídem al punto anterior, pero ordenarlo por semestre y fecha de creación.

SELECT 
Nombre, 
Extension, 
FechaCreacion,
CASE WHEN MONTH(FechaCreacion) >= 6 THEN 'Segundo Semestre'
ELSE 'Primer Semestre' END AS 'Semestre'
FROM Archivos
ORDER BY MONTH(FechaCreacion) ASC, FechaCreacion ASC;


--Todas las Extensiones de los archivos creados. NOTA: no se pueden repetir.

SELECT DISTINCT Extension FROM Archivos;


-- Todos los archivos que no estén eliminados. Indicar IDArchivo, IDUsuarioDueño, Fecha de Creación y Tamaño del archivo. 
-- Ordenar los resultados por Fecha de Creación (del más reciente al más antiguo).
SELECT IDArchivo, IDUsuarioDuenio, FechaCreacion, Tamanio FROM Archivos WHERE Eliminado = 0 ORDER BY FechaCreacion DESC;


--Todos los archivos que estén eliminados cuyo Tamaño del archivo se encuentre entre 40960 y 204800 (ambos inclusive). Indicar el valor de todas las columnas. 
SELECT * FROM Archivos WHERE Eliminado = 1 AND Tamanio BETWEEN 40960 AND 204800;

-- Listar los meses del año en los que se crearon los archivos entre los años 2020 y 2022 (ambos inclusive). NOTA: no indicar más de una vez el mismo mes.

SELECT DISTINCT
CASE WHEN MONTH(FechaCreacion) = 1 THEN 'Enero' 
    WHEN MONTH(FechaCreacion) = 2 THEN 'Febrero' 
    WHEN MONTH(FechaCreacion) = 3 THEN 'Marzo' 
    WHEN MONTH(FechaCreacion) = 4 THEN 'Abril' 
    WHEN MONTH(FechaCreacion) = 5 THEN 'Mayo' 
    WHEN MONTH(FechaCreacion) = 6 THEN 'Junio' 
    WHEN MONTH(FechaCreacion) = 7 THEN 'Julio' 
    WHEN MONTH(FechaCreacion) = 8 THEN 'Agosto' 
    WHEN MONTH(FechaCreacion) = 9 THEN 'Septiembre' 
    WHEN MONTH(FechaCreacion) = 10 THEN 'Octubre' 
    WHEN MONTH(FechaCreacion) = 11 THEN 'Noviembre' 
    ELSE 'Diciembre' END AS 'Mes de creacion'
FROM Archivos WHERE YEAR(FechaCreacion) BETWEEN 2020 AND 2022;


-- Indicar los distintos ID de los Usuarios Dueños de archivos que nunca modificaron sus archivos y que no se encuentren eliminados. NOTA: no se pueden repetir.
SELECT DISTINCT IDUsuarioDuenio FROM Archivos WHERE Eliminado = 0 AND FechaCreacion = FechaUltimaModificacion;


-- Listar todos los datos de los Archivos cuyos Dueños sean los usuarios con ID 1, 3, 5, 8, 9. 
-- Los registros deben estar ordenados por IDUsuarioDueño y Tamaño de forma ascendente.

SELECT * FROM Archivos WHERE IDUsuarioDuenio IN (1, 3, 5, 8, 9) ORDER BY IDUsuarioDuenio ASC, Tamanio ASC;


-- Listar todos los datos de los tres Archivos de más bajo Tamaño que no se encuentren Eliminados.

SELECT top 3 * FROM Archivos WHERE Eliminado = 0 ORDER BY Tamanio ASC;

-- Listar los Archivos que estén Eliminados y la Fecha de Ultima Modificación sea menor o igual al año 2021 o bien no estén Eliminados y la Fecha de Ultima Modificación sean mayor al año 2021. 
--Indicar todas las columnas excepto IDUsuarioDueño y Fecha de Creación. Ordenar por IDArchivo.

SELECT 
IDArchivo, 
Nombre, 
Descripcion, 
Extension, 
IDTipoArchivo, 
Tamanio, 
FechaUltimaModificacion, 
Eliminado 
FROM Archivos WHERE Eliminado = 1 AND YEAR(FechaUltimaModificacion) <= 2021 OR Eliminado = 0 AND YEAR(FechaUltimaModificacion) > 2021;