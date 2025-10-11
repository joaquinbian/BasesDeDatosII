USE DBTutorias
GO

-- Realizar un procedimiento almacenado llamado sp_Agregar_Estudiante que permita registrar un estudiante en el sistema. 
--El procedimiento debe recibir como parámetro Legajo, Nombre, Apellido y Email.

CREATE OR ALTER PROCEDURE sp_Agregar_Estudiante(
    @Legajo VARCHAR(10),
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Email VARCHAR(150)
)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Estudiantes(Legajo, Nombre, Apellido, Email) VALUES(@Legajo, @Nombre, @Apellido, @Email)
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE()
        RAISERROR('No se pudo insertar el usuario', 16, 1)
    END CATCH
END
EXEC sp_Agregar_Estudiante "000aaa", "Joaquin", "Bianchi", "joaquin@mail.com"


SELECT * FROM Estudiantes