USE Clase07
GO


-- cuando se intente borrar una cuenta bancaria, no borrarla y en su lugar seleccionar la informacion que se queria borrar

CREATE TRIGGER TR_DELETE_CUENTA_BANCARIA ON Cuentas
INSTEAD OF DELETE
AS
BEGIN
    SELECT * FROM Cuentas;
END