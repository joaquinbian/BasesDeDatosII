USE Clase07
GO


-- Al modificar el tipo de cuenta, si se realiza el cambio de cuenta corrienta a caja de ahorro
-- verificar que la cuenta corriente no tenga saldo negativo para realizar el proceso
-- si puede hacerse la modificacion, quitar el limite descubierto
--puede ser after o update este caso
CREATE TRIGGER TR_CAMBIO_TIPO_CUENTA ON Cuentas 
INSTEAD OF UPDATE
AS 
BEGIN  
    SELECT * FROM cuentas;
END
