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
            BEGIN
                RAISERROR('El legajo es obligatorio', 16, 1)
                RETURN
            END
        IF @Email IS NULL OR @Email NOT LIKE '%_@__%.__%'
            BEGIN
                RAISERROR('Email inválido', 16, 1)
                RETURN
            END
        -- Verificar duplicados
        IF EXISTS(SELECT 1 FROM Estudiantes WHERE Legajo = @Legajo)
            BEGIN
                RAISERROR('Ya existe un estudiante con ese legajo', 16, 1)
                RETURN
            END
        INSERT INTO Estudiantes(Legajo, Nombre, Apellido, Email) 
        VALUES(@Legajo, @Nombre, @Apellido, @Email)
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE()
        RAISERROR('No se pudo insertar el usuario', 16, 1)
    END CATCH
END
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
            RETURN
        END

        IF EXISTS(SELECT 1 FROM Materias WHERE Nivel = @Nivel AND Nombre = @Nombre AND Carrera = @Carrera)
        BEGIN
            RAISERROR('La materia ya existe', 16, 1)
            RETURN
        END
        IF @Nivel IS NULL OR @Nivel < 1 OR @Nivel > 6  -- Ajusta según tu sistema
        BEGIN
            RAISERROR('El nivel debe estar entre 1 y 6', 16, 1)
            RETURN
        END
        IF @CodigoMateria IS NULL OR LEN(@CodigoMateria) != 4
        BEGIN
            RAISERROR('El código debe tener exactamente 4 caracteres', 16, 1)
            RETURN
        END
        
        INSERT INTO Materias(Nombre, Nivel, Carrera, CodigoMateria) VALUES (@Nombre, @Nivel, @Carrera, @CodigoMateria)

    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE()
    END CATCH
END

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
            RETURN
        END
        IF NOT EXISTS (SELECT 1 FROM Materias WHERE IDMateria = @IDMateria)
        BEGIN
            RAISERROR('La materia ingresada no existe', 16, 1)
            RETURN
        END
        IF @Rol != 'Tutor' AND @Rol != 'Alumno'
        BEGIN
            RAISERROR('El estudiante debe ser "Tutor" o "Alumno"', 16, 1)
            RETURN
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
GO



USE DBTutorias
GO

-- =============================================
-- SCRIPT PARA POPULAR LA BASE DE DATOS DBTutorias
-- =============================================

PRINT '===== INICIANDO CARGA DE DATOS ====='
GO

-- =============================================
-- 1. AGREGAR ESTUDIANTES
-- =============================================
PRINT 'Agregando Estudiantes...'

EXEC sp_Agregar_Estudiante '001234', 'Juan', 'Pérez', 'juan.perez@universidad.edu'
EXEC sp_Agregar_Estudiante '001235', 'María', 'García', 'maria.garcia@universidad.edu'
EXEC sp_Agregar_Estudiante '001236', 'Carlos', 'Rodríguez', 'carlos.rodriguez@universidad.edu'
EXEC sp_Agregar_Estudiante '001237', 'Ana', 'Martínez', 'ana.martinez@universidad.edu'
EXEC sp_Agregar_Estudiante '001238', 'Luis', 'López', 'luis.lopez@universidad.edu'
EXEC sp_Agregar_Estudiante '001239', 'Laura', 'González', 'laura.gonzalez@universidad.edu'
EXEC sp_Agregar_Estudiante '001240', 'Pedro', 'Fernández', 'pedro.fernandez@universidad.edu'
EXEC sp_Agregar_Estudiante '001241', 'Sofía', 'Sánchez', 'sofia.sanchez@universidad.edu'
EXEC sp_Agregar_Estudiante '001242', 'Diego', 'Ramírez', 'diego.ramirez@universidad.edu'
EXEC sp_Agregar_Estudiante '001243', 'Valentina', 'Torres', 'valentina.torres@universidad.edu'
EXEC sp_Agregar_Estudiante '001244', 'Martín', 'Flores', 'martin.flores@universidad.edu'
EXEC sp_Agregar_Estudiante '001245', 'Camila', 'Díaz', 'camila.diaz@universidad.edu'

PRINT 'Estudiantes agregados: 12'
GO

-- =============================================
-- 2. AGREGAR MATERIAS
-- =============================================
PRINT 'Agregando Materias...'

-- Primer año
EXEC sp_Agregar_Materia 'Programación I', 1, 'Tecnicatura Universitaria en Programación', 'PRG1'
EXEC sp_Agregar_Materia 'Matemática I', 1, 'Tecnicatura Universitaria en Programación', 'MAT1'
EXEC sp_Agregar_Materia 'Inglés Técnico I', 1, 'Tecnicatura Universitaria en Programación', 'ING1'
EXEC sp_Agregar_Materia 'Sistemas y Organizaciones', 1, 'Tecnicatura Universitaria en Programación', 'SYO1'

-- Segundo año
EXEC sp_Agregar_Materia 'Programación II', 2, 'Tecnicatura Universitaria en Programación', 'PRG2'
EXEC sp_Agregar_Materia 'Base de Datos I', 2, 'Tecnicatura Universitaria en Programación', 'BDD1'
EXEC sp_Agregar_Materia 'Estadística', 2, 'Tecnicatura Universitaria en Programación', 'EST2'
EXEC sp_Agregar_Materia 'Arquitectura de Computadoras', 2, 'Tecnicatura Universitaria en Programación', 'ARC2'

-- Tercer año
EXEC sp_Agregar_Materia 'Programación III', 3, 'Tecnicatura Universitaria en Programación', 'PRG3'
EXEC sp_Agregar_Materia 'Base de Datos II', 3, 'Tecnicatura Universitaria en Programación', 'BDD2'
EXEC sp_Agregar_Materia 'Desarrollo Web', 3, 'Tecnicatura Universitaria en Programación', 'WEB3'
EXEC sp_Agregar_Materia 'Proyecto Final', 3, 'Tecnicatura Universitaria en Programación', 'PRY3'


PRINT 'Materias agregadas: 12'
GO

-- =============================================
-- 3. REGISTRAR ESTUDIANTES COMO TUTORES Y ALUMNOS
-- =============================================
PRINT 'Registrando roles de estudiantes en materias...'

-- Obtener los IDs de los estudiantes (dinámico)
DECLARE @Juan INT, @Maria INT, @Carlos INT, @Ana INT, @Luis INT, @Laura INT
DECLARE @Pedro INT, @Sofia INT, @Diego INT, @Valentina INT, @Martin INT, @Camila INT

SELECT @Juan = IDEstudiante FROM Estudiantes WHERE Legajo = '001234'
SELECT @Maria = IDEstudiante FROM Estudiantes WHERE Legajo = '001235'
SELECT @Carlos = IDEstudiante FROM Estudiantes WHERE Legajo = '001236'
SELECT @Ana = IDEstudiante FROM Estudiantes WHERE Legajo = '001237'
SELECT @Luis = IDEstudiante FROM Estudiantes WHERE Legajo = '001238'
SELECT @Laura = IDEstudiante FROM Estudiantes WHERE Legajo = '001239'
SELECT @Pedro = IDEstudiante FROM Estudiantes WHERE Legajo = '001240'
SELECT @Sofia = IDEstudiante FROM Estudiantes WHERE Legajo = '001241'
SELECT @Diego = IDEstudiante FROM Estudiantes WHERE Legajo = '001242'
SELECT @Valentina = IDEstudiante FROM Estudiantes WHERE Legajo = '001243'
SELECT @Martin = IDEstudiante FROM Estudiantes WHERE Legajo = '001244'
SELECT @Camila = IDEstudiante FROM Estudiantes WHERE Legajo = '001245'

-- Juan - Tutor avanzado
--EXEC sp_Agregar_EstudianteMateria @Juan, 2, 'Tutor'  -- Programación I
EXEC sp_Agregar_EstudianteMateria @Juan, 3, 'Tutor'  -- Matemática I
EXEC sp_Agregar_EstudianteMateria @Juan, 6, 'Tutor'  -- Programación II
EXEC sp_Agregar_EstudianteMateria @Juan, 10, 'Alumno' -- Programación III

-- María - Tutora de bases de datos
EXEC sp_Agregar_EstudianteMateria @Maria, 7, 'Tutor'  -- Base de Datos I
EXEC sp_Agregar_EstudianteMateria @Maria, 11, 'Tutor' -- Base de Datos II
EXEC sp_Agregar_EstudianteMateria @Maria, 2, 'Alumno' -- Programación I

-- Carlos - Tutor de matemática
EXEC sp_Agregar_EstudianteMateria @Carlos, 3, 'Tutor'  -- Matemática I
EXEC sp_Agregar_EstudianteMateria @Carlos, 8, 'Tutor'  -- Estadística
EXEC sp_Agregar_EstudianteMateria @Carlos, 6, 'Alumno' -- Programación II

-- Ana - Alumna de primer año
EXEC sp_Agregar_EstudianteMateria @Ana, 2, 'Alumno' -- Programación I
EXEC sp_Agregar_EstudianteMateria @Ana, 3, 'Alumno' -- Matemática I
EXEC sp_Agregar_EstudianteMateria @Ana, 4, 'Alumno' -- Inglés Técnico I

-- Luis - Tutor de desarrollo web
EXEC sp_Agregar_EstudianteMateria @Luis, 12, 'Tutor' -- Desarrollo Web
EXEC sp_Agregar_EstudianteMateria @Luis, 10, 'Tutor'  -- Programación III
EXEC sp_Agregar_EstudianteMateria @Luis, 7, 'Alumno' -- Base de Datos I

-- Laura - Alumna de segundo año
EXEC sp_Agregar_EstudianteMateria @Laura, 6, 'Alumno' -- Programación II
EXEC sp_Agregar_EstudianteMateria @Laura, 7, 'Alumno' -- Base de Datos I
EXEC sp_Agregar_EstudianteMateria @Laura, 8, 'Alumno' -- Estadística

-- Pedro - Tutor de arquitectura
EXEC sp_Agregar_EstudianteMateria @Pedro, 9, 'Tutor'  -- Arquitectura de Computadoras
EXEC sp_Agregar_EstudianteMateria @Pedro, 5, 'Tutor'  -- Sistemas y Organizaciones
EXEC sp_Agregar_EstudianteMateria @Pedro, 12, 'Alumno'-- Desarrollo Web

-- Sofía - Alumna de primer año
EXEC sp_Agregar_EstudianteMateria @Sofia, 2, 'Alumno' -- Programación I
EXEC sp_Agregar_EstudianteMateria @Sofia, 3, 'Alumno' -- Matemática I
EXEC sp_Agregar_EstudianteMateria @Sofia, 5, 'Alumno' -- Sistemas y Organizaciones

-- Diego - Alumno de segundo año
EXEC sp_Agregar_EstudianteMateria @Diego, 6, 'Alumno' -- Programación II
EXEC sp_Agregar_EstudianteMateria @Diego, 7, 'Alumno' -- Base de Datos I

-- Valentina - Tutora de inglés
EXEC sp_Agregar_EstudianteMateria @Valentina, 4, 'Tutor' -- Inglés Técnico I
EXEC sp_Agregar_EstudianteMateria @Valentina, 6, 'Alumno'-- Programación II

-- Martín - Alumno de tercer año
EXEC sp_Agregar_EstudianteMateria @Martin, 10, 'Alumno' -- Programación III
EXEC sp_Agregar_EstudianteMateria @Martin, 11, 'Alumno'-- Base de Datos II
EXEC sp_Agregar_EstudianteMateria @Martin, 12, 'Alumno'-- Desarrollo Web

-- Camila - Alumna de primer año
EXEC sp_Agregar_EstudianteMateria @Camila, 2, 'Alumno' -- Programación I
EXEC sp_Agregar_EstudianteMateria @Camila, 4, 'Alumno' -- Inglés Técnico I

PRINT 'Roles registrados exitosamente'
GO

-- =============================================
-- 4. CREAR TUTORÍAS
-- =============================================
PRINT 'Creando tutorías...'

-- Obtener los IDs de los estudiantes (dinámico)
DECLARE @Juan INT, @Maria INT, @Carlos INT, @Ana INT, @Luis INT, @Laura INT
DECLARE @Pedro INT, @Sofia INT, @Diego INT, @Valentina INT, @Martin INT, @Camila INT

SELECT @Juan = IDEstudiante FROM Estudiantes WHERE Legajo = '001234'
SELECT @Maria = IDEstudiante FROM Estudiantes WHERE Legajo = '001235'
SELECT @Carlos = IDEstudiante FROM Estudiantes WHERE Legajo = '001236'
SELECT @Ana = IDEstudiante FROM Estudiantes WHERE Legajo = '001237'
SELECT @Luis = IDEstudiante FROM Estudiantes WHERE Legajo = '001238'
SELECT @Laura = IDEstudiante FROM Estudiantes WHERE Legajo = '001239'
SELECT @Pedro = IDEstudiante FROM Estudiantes WHERE Legajo = '001240'
SELECT @Sofia = IDEstudiante FROM Estudiantes WHERE Legajo = '001241'
SELECT @Diego = IDEstudiante FROM Estudiantes WHERE Legajo = '001242'
SELECT @Valentina = IDEstudiante FROM Estudiantes WHERE Legajo = '001243'
SELECT @Martin = IDEstudiante FROM Estudiantes WHERE Legajo = '001244'
SELECT @Camila = IDEstudiante FROM Estudiantes WHERE Legajo = '001245'

-- Tutorías para hoy y próximos días
DECLARE @Hoy DATE = CAST(GETDATE() AS DATE)
DECLARE @Manana DATE = DATEADD(DAY, 1, @Hoy)
DECLARE @En2Dias DATE = DATEADD(DAY, 2, @Hoy)
DECLARE @En3Dias DATE = DATEADD(DAY, 3, @Hoy)
DECLARE @En5Dias DATE = DATEADD(DAY, 5, @Hoy)
DECLARE @En7Dias DATE = DATEADD(DAY, 7, @Hoy)

-- Juan tutora a Ana en Programación I
--EXEC sp_Agregar_Tutoria 
  --  @IDEstudianteTutor = @Juan,
    --@IDEstudianteAlumno = @Ana,
    --@IDMateria = 2,
    --@Fecha = @Manana,
    --@Duracion = 2

-- Juan tutora a Sofía en Programación I
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Juan,
    @IDEstudianteAlumno = @Sofia,
    @IDMateria = 2,
    @Fecha = @En2Dias,
    @Duracion = 1

-- María tutora a Laura en Base de Datos I
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Maria,
    @IDEstudianteAlumno = @Laura,
    @IDMateria = 7,
    @Fecha = @En3Dias,
    @Duracion = 2

-- Carlos tutora a Ana en Matemática I
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Carlos,
    @IDEstudianteAlumno = @Ana,
    @IDMateria = 3,
    @Fecha = @En2Dias,
    @Duracion = 3

-- Carlos tutora a Sofía en Matemática I
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Carlos,
    @IDEstudianteAlumno = @Sofia,
    @IDMateria = 3,
    @Fecha = @En5Dias,
    @Duracion = 2

-- Luis tutora a Pedro en Desarrollo Web
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Luis,
    @IDEstudianteAlumno = @Pedro,
    @IDMateria = 12,
    @Fecha = @En3Dias,
    @Duracion = 1

-- Luis tutora a Martín en Programación III
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Luis,
    @IDEstudianteAlumno = @Martin,
    @IDMateria = 10,
    @Fecha = @En7Dias,
    @Duracion = 2

-- Pedro tutora a Sofía en Sistemas y Organizaciones
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Pedro,
    @IDEstudianteAlumno = @Sofia,
    @IDMateria = 5,
    @Fecha = @Manana,
    @Duracion = 1

-- Valentina tutora a Ana en Inglés Técnico I
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Valentina,
    @IDEstudianteAlumno = @Ana,
    @IDMateria = 4,
    @Fecha = @En5Dias,
    @Duracion = 2

-- Valentina tutora a Camila en Inglés Técnico I
EXEC sp_Agregar_Tutoria 
    @IDEstudianteTutor = @Valentina,
    @IDEstudianteAlumno = @Camila,
    @IDMateria = 4,
    @Fecha = @En7Dias,
    @Duracion = 1

PRINT 'Tutorías creadas: 10'
GO

-- =============================================
-- 5. CONFIRMAR ALGUNAS TUTORÍAS (SIMULANDO USO REAL)
-- =============================================
PRINT 'Confirmando tutorías...'

-- Obtener los IDs de las tutorías recién creadas (dinámico)
DECLARE @Tut1 INT, @Tut2 INT, @Tut3 INT, @Tut4 INT, @Tut8 INT

-- Obtener los últimos 10 IDs de tutorías (las que acabamos de crear)
SELECT TOP 1 @Tut1 = IDTutoria FROM Tutorias ORDER BY IDTutoria DESC
SET @Tut1 = @Tut1 - 9  -- Primera tutoría

SET @Tut2 = @Tut1 + 1  -- Segunda tutoría
SET @Tut3 = @Tut1 + 2  -- Tercera tutoría
SET @Tut4 = @Tut1 + 3  -- Cuarta tutoría
SET @Tut8 = @Tut1 + 7  -- Octava tutoría

-- Tutoría 1: Juan -> Ana (Programación I) - Ambos confirman
EXEC sp_Confirmar_Tutoria @IDTutoria = @Tut1, @Rol = 'Tutor'
EXEC sp_Confirmar_Tutoria @IDTutoria = @Tut1, @Rol = 'Alumno'

-- Tutoría 2: Juan -> Sofía (Programación I) - Solo tutor confirma
EXEC sp_Confirmar_Tutoria @IDTutoria = @Tut2, @Rol = 'Tutor'

-- Tutoría 3: María -> Laura (Base de Datos I) - Ambos confirman
EXEC sp_Confirmar_Tutoria @IDTutoria = @Tut3, @Rol = 'Alumno'
EXEC sp_Confirmar_Tutoria @IDTutoria = @Tut3, @Rol = 'Tutor'

-- Tutoría 4: Carlos -> Ana (Matemática I) - Solo alumno confirma
EXEC sp_Confirmar_Tutoria @IDTutoria = @Tut4, @Rol = 'Alumno'

-- Tutoría 8: Pedro -> Sofía (Sistemas) - Ambos confirman
EXEC sp_Confirmar_Tutoria @IDTutoria = @Tut8, @Rol = 'Tutor'
EXEC sp_Confirmar_Tutoria @IDTutoria = @Tut8, @Rol = 'Alumno'

PRINT 'Tutorías confirmadas (algunas parciales, otras completas)'
GO

-- =============================================
-- 6. VERIFICAR DATOS CARGADOS
-- =============================================
PRINT ''
PRINT '===== RESUMEN DE DATOS CARGADOS ====='

SELECT 'Estudiantes' AS Tabla, COUNT(*) AS Cantidad FROM Estudiantes
UNION ALL
SELECT 'Materias', COUNT(*) FROM Materias
UNION ALL
SELECT 'EstudiantesMaterias', COUNT(*) FROM EstudiantesMaterias
UNION ALL
SELECT 'Tutorías', COUNT(*) FROM Tutorias
UNION ALL
SELECT 'Historial Créditos', COUNT(*) FROM HistorialCreditos

PRINT ''
PRINT '===== EJEMPLOS DE CONSULTAS ====='
PRINT 'Para ver tutorías de Juan como tutor:'
PRINT '  EXEC sp_Obtener_Tutorias @IDEstudiante = 1, @Rol = ''Tutor'''
PRINT ''
PRINT 'Para ver tutorías de Ana como alumna:'
PRINT '  EXEC sp_Obtener_Tutorias @IDEstudiante = 4, @Rol = ''Alumno'''
PRINT ''
PRINT 'Ver estado de créditos:'
PRINT '  SELECT Nombre, Apellido, SaldoCredito FROM Estudiantes ORDER BY SaldoCredito DESC'
PRINT ''
PRINT 'Ver historial de un estudiante:'
PRINT '  SELECT * FROM HistorialCreditos WHERE IDEstudiante = 1 ORDER BY Fecha DESC'
PRINT ''
PRINT '===== CARGA COMPLETADA EXITOSAMENTE ====='
GO