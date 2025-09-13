USE DBArchivos;
GO

-- Por cada usuario listar el nombre, apellido y el nombre del tipo de usuario.
SELECT Nombre, Apellido, TiposUsuario.TipoUsuario FROM Usuarios INNER JOIN TiposUsuario ON Usuarios.IDTipoUsuario = TiposUsuario.IDTipoUsuario;


-- Listar el ID, nombre, apellido y tipo de usuario de aquellos usuarios que sean del tipo 'Suscripción Free' o 'Suscripción Básica'
SELECT Nombre, Apellido, TiposUsuario.TipoUsuario FROM Usuarios 
INNER JOIN TiposUsuario ON Usuarios.IDTipoUsuario = TiposUsuario.IDTipoUsuario 
WHERE TiposUsuario.TipoUsuario LIKE 'Suscripcion Free' OR TiposUsuario.TipoUsuario LIKE 'Suscripcion Basica';