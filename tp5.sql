USE DBArchivos
GO

-- La cantidad de archivos con extensión zip.
SELECT COUNT(*) as 'Archivos zip' FROM Archivos WHERE Extension LIKE 'zip'


--La cantidad de archivos que fueron modificados y, por lo tanto, su fecha de última modificación no es la misma que la fecha de creación.
SELECT COUNT(*) as 'Archivos modificados' FROM Archivos WHERE FechaCreacion != FechaUltimaModificacion


-- La fecha de creación más antigua de los archivos con extensión pdf.
SELECT MIN(FechaCreacion) FROM Archivos;
 

 -- La cantidad de extensiones distintas cuyos archivos tienen en su nombre o en su descripción la palabra 'Informe' o 'Documento'.
 SELECT COUNT(*) from Archivos WHERE Nombre LIKE '%Informe%' OR Descripcion LIKE '%Informe%' or Nombre LIKE '%Documento%' or Descripcion LIKE '%Documento%';

 -- El promedio de tamaño (expresado en Megabytes) de los archivos con extensión 'doc', 'docx', 'xls', 'xlsx'.
SELECT AVG(Tamanio) AS 'MB promedio' FROM Archivos WHERE Extension IN ('doc', 'docx', 'xls', 'xlsx') -- me da 0...


-- La cantidad de archivos que le fueron compartidos al usuario con apellido 'Clarck'

SELECT COUNT(*)AS 'Archivos compartidos a clarck' FROM ArchivosCompartidos AC 
INNER JOIN Usuarios U ON ac.IDUsuario = u.IDUsuario WHERE u.Apellido LIKE 'Clarck';

-- La cantidad de tipos de usuario que tienen asociado usuarios que registren, como dueños, archivos con extensión pdf.
