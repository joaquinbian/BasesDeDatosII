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
         IF @Legajo IS NULL OR LTRIM(RTRIM(@Legajo)) = ''
            RAISERROR('El legajo es obligatorio', 16, 1)
        
        IF @Email IS NULL OR @Email NOT LIKE '%_@__%.__%'
            RAISERROR('Email inválido', 16, 1)
        
        -- Verificar duplicados
        IF EXISTS(SELECT 1 FROM Estudiantes WHERE Legajo = @Legajo)
            RAISERROR('Ya existe un estudiante con ese legajo', 16, 1)
        
        INSERT INTO Estudiantes(Legajo, Nombre, Apellido, Email) 
        VALUES(@Legajo, @Nombre, @Apellido, @Email)
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE()
        RAISERROR('No se pudo insertar el usuario', 16, 1)
    END CATCH
END
EXEC sp_Agregar_Estudiante "000aaa", "Joaquin", "Bianchi", "joaquin@mail.com"
GO


-- Realizar un procedimiento almacenado llamado sp_Agregar_Materia que permita registrar una materia en el sistema. 
--El procedimiento debe recibir como parámetro el Nombre, el Nivel, Carrera y CodigoMateria.

CREATE OR ALTER PROCEDURE sp_Agregar_Materia (
    @Nombre VARCHAR(100),
    @Nivel TINYINT,
    @Carrera VARCHAR(150),
	@CodigoMateria VARCHAR(4)
) 
AS
BEGIN
    BEGIN TRY
        IF @Nombre IS NULL OR TRIM(@Nombre) = ''
        BEGIN
            RAISERROR('Se debe ingresar un nombre', 16, 1)
        END

        IF EXISTS(SELECT 1 FROM Materias WHERE Nivel = @Nivel AND Nombre = @Nombre AND Carrera = @Carrera)
        BEGIN
            RAISERROR('La materia ya existe', 16, 1)
        END
        IF @Nivel IS NULL OR @Nivel < 1 OR @Nivel > 6  -- Ajusta según tu sistema
        BEGIN
            RAISERROR('El nivel debe estar entre 1 y 6', 16, 1)
        END
        IF @CodigoMateria IS NULL OR LEN(@CodigoMateria) != 4
        BEGIN
            RAISERROR('El código debe tener exactamente 4 caracteres', 16, 1)
        END
        
        INSERT INTO Materias(Nombre, Nivel, Carrera, CodigoMateria) VALUES (@Nombre, @Nivel, @Carrera, @CodigoMateria)

    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE()
    END CATCH
END

EXEC sp_Agregar_Materia 'Programacion I', 1, 'Tecnicatura Universitaria en Programacion', 'PRG01'
GO


-- Realizar un procedimiento almacenado llamado sp_Agregar_EstudianteMateria que permita registrar el postulamiento de un estudiante como tutor o alumno a una materia en el sistema. 
--El procedimiento debe recibir como parámetro el IDEstudiante, el IDMateria y Rol (Tutor o Alumno)

CREATE or ALTER PROCEDURE sp_Agregar_EstudianteMateria (
    @IDEstudiante INT,
    @IDMateria INT,
    @Rol VARCHAR(10)
) AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Estudiantes WHERE IDEstudiante = @IDEstudiante)
        BEGIN
            RAISERROR('El estudiante ingresado no existe', 16, 1)
        END
        IF NOT EXISTS (SELECT 1 FROM Materias WHERE IDMateria = @IDMateria)
        BEGIN
            RAISERROR('La materia ingresada no existe', 16, 1)
        END
        IF @Rol != 'Tutor' AND @Rol != 'Alumno'
        BEGIN
            RAISERROR('El estudiante debe ser "Tutor" o "Alumno"', 16, 1)
        END

        IF EXISTS(
            SELECT 1 FROM Estudiantes 
            WHERE IDEstudiante = @IDEstudiante 
            AND Activo = 0)
        BEGIN
            RAISERROR('El estudiante no está activo', 16, 1)
            RETURN
        END
        
        INSERT INTO EstudiantesMaterias(IDEstudiante, IDMateria, Rol) VALUES(@IDEstudiante, @IDMateria, @Rol)
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE()
    END CATCH   
END


EXEC sp_Agregar_EstudianteMateria 2, 1, 'Tutor'

select * from EstudiantesMaterias
GO



-- Realizar un procedimiento almacenado llamado sp_Agregar_Tutoria que permita registrar una tutoría en el sistema.
-- El procedimiento debe recibir como parámetro el IDEstudianteTutor, el IDEstudianteAlumno, el IDMateria, Fecha y Duración

CREATE OR ALTER PROCEDURE sp_Agregar_Tutoria(
    @IDEstudianteTutor INT,
    @IDEstudianteAlumno INT,
    @IDMateria INT,
    @Fecha DATE,
    @Duracion TINYINT
) AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION
        IF NOT EXISTS (SELECT 1 FROM Estudiantes WHERE IDEstudiante = @IDEstudianteTutor)
            BEGIN
                RAISERROR('El estudiante TUTOR ingresado no existe', 16, 1)
                RETURN
            END

        IF NOT EXISTS (SELECT 1 FROM Estudiantes WHERE IDEstudiante = @IDEstudianteAlumno)
            BEGIN
                RAISERROR('El estudiante ALUMNO ingresado no existe', 16, 1)
                RETURN
            END

        IF @IDEstudianteAlumno = @IDEstudianteTutor 
            BEGIN
                RAISERROR('El alumno no puede ser el tutor', 16, 1)
                RETURN
            END
        
        IF EXISTS (SELECT 1 FROM Estudiantes 
           WHERE IDEstudiante IN (@IDEstudianteTutor, @IDEstudianteAlumno) 
           AND Activo = 0)
            BEGIN
                RAISERROR('Uno o ambos estudiantes no están activos', 16, 1)
                RETURN
            END
        
        IF NOT EXISTS (SELECT 1 FROM Materias WHERE IDMateria = @IDMateria)
            BEGIN
                RAISERROR('La materia ingresada no existe', 16, 1)
                RETURN
        END


        IF NOT EXISTS (SELECT 1 FROM EstudiantesMaterias WHERE IDEstudiante = @IDEstudianteTutor AND IDMateria = @IDMateria AND Rol = 'Tutor')
            BEGIN
                RAISERROR('El estudiante tutor ingresado no esta registrado como tutor en la materia', 16, 1)
                RETURN
            END

            IF NOT EXISTS (SELECT 1 FROM EstudiantesMaterias WHERE IDEstudiante = @IDEstudianteAlumno AND IDMateria = @IDMateria AND Rol = 'Alumno')
            BEGIN
                RAISERROR('El estudiante alimno ingresado no esta registrado como alimno en la materia', 16, 1)
                RETURN
            END

        IF EXISTS (SELECT 1 FROM Estudiantes WHERE IDEstudiante=@IDEstudianteAlumno AND SaldoCredito <= -5)
            BEGIN
                RAISERROR('El alumno no tiene credito suficiente para tomar tutorias', 16, 1)
                RETURN 
            END

       
        IF CAST(GETDATE() AS date) > @Fecha
            BEGIN
                RAISERROR('La fecha de la tutoria es invalida', 16, 1)
                RETURN
            END

        IF @Duracion < 1 OR @Duracion > 8 
            BEGIN
                RAISERROR('La duracion tiene que ser de minimo 1 hora y maximo 8 horas', 16,  1)
                RETURN
            END
        
        INSERT INTO Tutorias(IDEstudianteTutor, IDEstudianteAlumno, IDMateria, Fecha, Duracion) VALUES(@IDEstudianteTutor, @IDEstudianteAlumno, @IDMateria, @Fecha, @Duracion)
        UPDATE Estudiantes SET SaldoCredito = SaldoCredito - @Duracion WHERE IDEstudiante = @IDEstudianteAlumno
        DECLARE @NombreMateria VARCHAR(100)
        SELECT @NombreMateria = Nombre FROM Materias WHERE IDMateria = @IDMateria
        INSERT INTO HistorialCreditos(IDEstudiante, Cantidad, Tipo, Descripcion)
        VALUES (@IDEstudianteAlumno, @Duracion, 'Usa', 'Se asigna tutoria al alumno de ' + @NombreMateria)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        PRINT ERROR_MESSAGE()
    END CATCH
END
GO

-- Realizar un procedimiento almacenado llamado sp_Confirmar_Tutoria que registre la confirmación por parte del Tutor o Alumno. 
-- El procedimiento debe recibir: el IDTutoria y el Rol de quien confirma.


CREATE OR ALTER PROCEDURE sp_Confirmar_Tutoria (
    @IDTutoria INT,
    @Rol VARCHAR(10)
) AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION
        IF NOT EXISTS (SELECT 1 FROM Tutorias WHERE IDTutoria = @IDTutoria)
            BEGIN
                RAISERROR('La tutoria ingresada no existe', 16, 1)
                RETURN
            END
        SET @Rol = TRIM(@Rol)
        IF @Rol != 'Tutor' AND @Rol != 'Alumno'
            BEGIN
                RAISERROR('El estudiante debe ser "Tutor" o "Alumno"', 16, 1)
                RETURN
        END
        
        DECLARE @Confirm_Alumno BIT 
        DECLARE @Confirm_Tutor BIT 
        DECLARE @Duracion TINYINT 
        DECLARE @ID_Tutor INT 
        DECLARE @Estado VARCHAR(20)
        DECLARE @NombreMateria VARCHAR(100)
        SELECT 
             @ID_Tutor = IDEstudianteTutor,
             @Duracion = Duracion,
             @Confirm_Tutor = ConfirmaTutor,
             @Confirm_Alumno = ConfirmaAlumno,
             @Estado = Estado
        FROM Tutorias
        WHERE IDTutoria = @IDTutoria

        SELECT @NombreMateria = Nombre FROM Materias WHERE IDMateria = (SELECT IDMateria FROM Tutorias WHERE IDTutoria = @IDTutoria)

        IF @Estado != 'PENDIENTE'
            BEGIN
                RAISERROR('Solo se pueden confirmar tutorías pendientes', 16, 1)
            RETURN
        END

        IF @Confirm_Alumno = 1 AND @Confirm_Tutor = 1 
            BEGIN
                PRINT 'La tutoria ya ha sido confirmada por ambas partes'
                RETURN
            END
        
        IF @Rol = 'Alumno'
            BEGIN
                IF @Confirm_Alumno = 1 
                    BEGIN
                        PRINT 'La tutoria ya ha sido confirmada por el alumno'
                        RETURN
                    END
                
                UPDATE Tutorias SET ConfirmaAlumno = 1 WHERE IDTutoria = @IDTutoria
                IF @Confirm_Tutor = 1
                    BEGIN 
                        UPDATE Tutorias SET Estado = 'Realizada' WHERE IDTutoria = @IDTutoria
                        UPDATE Estudiantes SET SaldoCredito = SaldoCredito + @Duracion WHERE IDEstudiante = @ID_Tutor
                        INSERT INTO HistorialCreditos(IDEstudiante, Cantidad, Tipo, Descripcion) 
                        VALUES (@ID_Tutor, @Duracion, 'Gana', 'Gana por tutoria de ' + @NombreMateria)
                END
            END
        IF @Rol = 'Tutor'
            BEGIN
                IF @Confirm_Tutor = 1
                    BEGIN
                        PRINT 'La tutoria ya ha sido confirmada por el tutor'
                        RETURN
                    END
                UPDATE Tutorias SET ConfirmaTutor = 1 WHERE IDTutoria = @IDTutoria
                
                IF @Confirm_Alumno = 1
                    BEGIN 
                        UPDATE Tutorias SET Estado = 'Realizada' WHERE IDTutoria = @IDTutoria
                        UPDATE Estudiantes SET SaldoCredito = SaldoCredito + @Duracion WHERE IDEstudiante = @ID_Tutor
                        INSERT INTO HistorialCreditos(IDEstudiante, Cantidad, Tipo, Descripcion) 
                        VALUES (@ID_Tutor, @Duracion, 'Gana', 'Gana por tutoria de ' + @NombreMateria)
                END
            END
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION
        PRINT ERROR_MESSAGE()
    END CATCH
END
GO

-- Realizar un procedimiento almacenado llamado sp_Obtener_Tutorias que reciba un IDEstudiante y un Rol ('Tutor' o 'Alumno'). 
--El procedimiento debe devolver un listado con las tutorías brindadas o recibidas (según el rol enviado) 
--indicando el nombre y apellido del estudiante tutor, nombre y apellido del estudiante alumno, fecha, nombre de la materia y cantidad de horas de la tutoría.


CREATE OR ALTER PROCEDURE sp_Obtener_Tutorias (
    @IDEstudiante INT,
    @Rol VARCHAR(10)
) AS
BEGIN
    BEGIN TRY
        SET @Rol = TRIM(@Rol)
        IF @Rol != 'Tutor' AND @Rol != 'Alumno'
            BEGIN
                RAISERROR('El estudiante debe ser "Tutor" o "Alumno"', 16, 1)
                RETURN
        END

        IF NOT EXISTS(SELECT 1 FROM Estudiantes WHERE IDEstudiante=@IDEstudiante)
            BEGIN
                RAISERROR('El estudiante no existe', 16, 1)
                RETURN
            END
        
        SELECT 
            EA.Nombre AS NombreAlumno, EA.Apellido AS ApellidoAlumno,
            ET.Nombre AS NombreTutor, ET.Apellido AS ApellidoTutor,
            M.Nombre,
            Fecha,
            Duracion
        FROM Tutorias T
        INNER JOIN Estudiantes EA ON EA.IDEstudiante = T.IDEstudianteAlumno
        INNER JOIN Estudiantes ET ON ET.IDEstudiante = T.IDEstudianteTutor
        INNER JOIN Materias M ON M.IDMateria = T.IDMateria
        WHERE 
        (@Rol = 'Tutor' AND T.IDEstudianteTutor = @IDEstudiante)
        OR
        (@Rol = 'Alumno' AND T.IDEstudianteAlumno = @IDEstudiante)
    END TRY
    BEGIN CATCH
    PRINT ERROR_MESSAGE()
    END CATCH
END