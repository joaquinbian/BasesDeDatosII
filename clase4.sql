USE DBArchivos
GO


SELECT * FROM Archivos WHERE Nombre = 'Informe Anual'; --coincidencia exacta

-- like sin comodines tmb busca coincidencias exactas, pero es case insensitive
SELECT * FROM Archivos WHERE Nombre LIKE 'informe anual';


-- comodin % -> matchea 0, 1 o mas caracteres
--todos los que comiencen con i
SELECT * FROM Archivos WHERE Nombre LIKE 'i%';

--todos los que contengan la a, al principio, al medio o al final
SELECT * FROM Archivos WHERE Nombre LIKE '%a%';

--todos los que contengan una a seguido de un caracter cualquiera y otra a 
SELECT * FROM Archivos WHERE Nombre LIKE '%a_a%';

--todos los que contengan una m seguida de los caracteres entre corchetes
SELECT * FROM Archivos WHERE Nombre LIKE '%m[aeiou]%';

--todos los que contengan una m Y NO este seguida de los caracteres dentro de  los corchetes
--niega al de arriba
SELECT * FROM Archivos WHERE Nombre LIKE '%m[^aeiou]%';

--todos los que comience con una vocal y siga con una letra entre la j y la z (incluyente)
--y finalice con cualquier caracter
SELECT * FROM Archivos WHERE Nombre LIKE '[aeiou][j-z]%';

-- todos los que arranquen con consonantes
SELECT * FROM Archivos WHERE Nombre LIKE '[^aeiou1234567890]%';




-- DECISION CON CASE-WHEN

SELECT Nombre, Descripcion, Extension,
CASE 
WHEN Tamanio < 100000 THEN 'Pequeño'
WHEN Tamanio BETWEEN 100001 AND 10000000 THEN 'Mediano'
ELSE 'Grande'
END AS 'Tamanio'
FROM Archivos; 


-- inner join