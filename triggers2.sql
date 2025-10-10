USE Clase07
GO
-- mejora de codigo del triggers.sql. TTenemos que hacerlo en otro archivo porque solo puede haber un trigger x archivo
CREATE TRIGGER TR_LOGIC_DELETE_CUENTA_BANCARIA ON Cuentas
INSTEAD OF DELETE
AS
BEGIN
   UPDATE Cuentas SET FechaBaja = GETDATE() WHERE FechaBaja IS NULL AND IDCuenta IN (select IDCuenta FROM deleted)
END

DELETE FROM Cuentas WHERE IDCuenta IN (13, 14);

SELECT * FROM Cuentas;

UPDATE Cuentas SET FechaBaja = null;
