USE DBArchivos
GO


SELECT * FROM Archivos WHERE Nombre = 'Informe Anual'; --coincidencia exacta

-- like sin comodines tmb busca coincidencias exactas, pero es case insensitive
SELECT * FROM Archivos WHERE Nombre LIKE 'informe anual';


-- comodin % -> matchea 0, 1 o mas caracteres
--todos los que comiencen con i
SELECT * FROM Archivos WHERE Nombre LIKE 'i%';

