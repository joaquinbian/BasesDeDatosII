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
