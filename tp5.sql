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
SELECT COUNT(IDTipoArchivo) FROM TiposUsuario TU 
INNER JOIN Usuarios U ON U.IDTipoUsuario = TU.IDTipoUsuario
INNER JOIN Archivos A ON a.IDUsuarioDuenio = U.IDUsuario
WHERE A.Extension LIKE 'pdf'



-- El tamaño máximo expresado en Megabytes de los archivos que hayan sido creados en el año 2024.
SELECT MAX(Tamanio) / 1048576 FROM Archivos WHERE YEAR(FechaCreacion) = 2024


-- El nombre del tipo de usuario y la cantidad de usuarios distintos de dicho tipo que registran, como dueños, archivos con extensión pdf.
SELECT TU.TipoUsuario, count(distinct u.IDUsuario) FROM TiposUsuario TU 
INNER JOIN Usuarios U ON U.IDTipoUsuario = TU.IDTipoUsuario
INNER JOIN Archivos A ON a.IDUsuarioDuenio = U.IDUsuario
WHERE A.Extension LIKE 'pdf'
GROUP BY TU.TipoUsuario


-- El nombre y apellido de los usuarios dueños y la suma total del tamaño de los archivos que tengan compartidos con otros usuarios. 
--Mostrar ordenado de mayor sumatoria de tamaño a menor.

SELECT u.Nombre, u.Apellido, SUM(a.Tamanio) FROM ArchivosCompartidos AC
INNER JOIN Archivos A ON AC.IDArchivo = A.IDArchivo
INNER JOIN Usuarios U ON A.IDUsuarioDuenio = U.IDUsuario
GROUP BY u.Nombre, u.Apellido
ORDER BY SUM(a.Tamanio) DESC;


-- El nombre del tipo de archivo y el promedio de tamaño de los archivos que corresponden a dicho tipo de archivo.
SELECT TA.TipoArchivo, AVG(A.Tamanio * 1.0) FROM Archivos A 
INNER JOIN TiposArchivos TA ON TA.IDTipoArchivo = A.IDTipoArchivo
GROUP BY TA.TipoArchivo


-- Por cada extensión, indicar la extensión, la cantidad de archivos con esa extensión y el total acumulado en bytes. 
-- Ordenado por cantidad de archivos de forma ascendente.
SELECT A.Extension, COUNT(TA.IDTipoArchivo) as TipoArchivo, SUM(a.Tamanio) as TamanioTotal FROM Archivos A
INNER JOIN TiposArchivos TA ON A.IDTipoArchivo = TA.IDTipoArchivo
GROUP BY a.Extension
ORDER BY COUNT(TipoArchivo) ASC;


-- Por cada usuario, indicar IDUSuario, Apellido, Nombre y la sumatoria total en bytes de los archivos que es dueño. 
-- Si algún usuario no registra archivos indicar 0 en la sumatoria total.

SELECT U.IDUsuario, U.Apellido, U.Nombre, ISNULL(SUM(A.Tamanio), 0) FROM Usuarios U 
LEFT JOIN Archivos A ON U.IDUsuario = A.IDUsuarioDuenio
GROUP BY U.IDUsuario, U.Apellido, U.Nombre;


-- Los tipos de archivos que fueron compartidos más de una vez con el permiso con nombre 'Lectura'
SELECT TA.TipoArchivo FROM ArchivosCompartidos AC
INNER JOIN Archivos A on AC.IDArchivo = A.IDArchivo
INNER JOIN TiposArchivos TA ON TA.IDTipoArchivo = A.IDTipoArchivo
INNER JOIN Permisos P ON AC.IDPermiso = P.IDPermiso
WHERE P.Nombre LIKE 'Lectura'
GROUP BY ta.TipoArchivo
HAVING COUNT(ta.TipoArchivo) > 1


-- Por cada tipo de archivo indicar el tipo de archivo y el tamaño del archivo de dicho tipo que sea más pesado.
SELECT TA.TipoArchivo, MAX(A.Tamanio) as Tamanio FROM TiposArchivos TA
INNER JOIN Archivos A ON A.IDTipoArchivo = TA.IDTipoArchivo
GROUP BY ta.TipoArchivo


-- El nombre del tipo de archivo y el promedio de tamaño de los archivos que corresponden a dicho tipo de archivo.
-- Solamente listar aquellos registros que superen los 50 Megabytes de promedio.
SELECT TA.TipoArchivo, AVG(A.Tamanio * 1.0 / 1048576) as PromedioTamanio FROM Archivos A
INNER JOIN TiposArchivos TA ON A.IDTipoArchivo = TA.IDTipoArchivo
GROUP BY TA.TipoArchivo
HAVING  AVG(A.Tamanio * 1.0 / 1048576) > 50