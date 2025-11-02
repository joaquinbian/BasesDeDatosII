USE DBTutoriasTp8;
GO

 
--Realizar un trigger que al registrar la postulación de un estudiante a una materia:
-- - Verifique que el Estudiante este activo.
-- - Verifique que no se repita el Rol para esa Materia y Estudiante.
-- - Registre la postulación del estudiante.

CREATE TRIGGER t_RegistrarCliente ON EstudiantesMaterias
INSTEAD OF INSERT
AS BEGIN
    DECLARE @IdEstudiante INT
    DECLARE @IdMateria INT
    DECLARE @Rol VARCHAR(10)
    SELECT @IdEstudiante = IDEstudiante FROM inserted
    SELECT @IdMateria = IDMateria FROM inserted
    SELECT @Rol = Rol FROM inserted

    IF EXISTS(SELECT 1 FROM Estudiantes WHERE IDEstudiante = @IdEstudiante AND Activo = 0)
    BEGIN
        PRINT('El estudiante debe estar activo');
        ROLLBACK TRANSACTION
        RETURN
    END

    IF EXISTS (SELECT 1 FROM EstudiantesMaterias WHERE Rol = @Rol AND IdMateria = @IdMateria AND IDEstudiante = @IdEstudiante)
    BEGIN
        PRINT('El estudiante ya se encuentra enlistado');
        ROLLBACK TRANSACTION
        RETURN
    END

    INSERT INTO EstudiantesMaterias(IDEstudiante, IDMateria, Rol) VALUES(@IdEstudiante, @IDMateria, @Rol)
END
GO

--Realizar un trigger que al agregar una tutoría:
-- Verifique que el Estudiante Tutor y el Estudiante Alumno están activos.
-- Verifique que El Tutor y Alumno no sean los mismos.
-- Verifique tanto el tutor como el alumno se hayan postulado en esa materia con los respectivos roles.
-- Verifique que el Estudiante Alumno tenga suficientes créditos (No menor a 5 créditos negativos)
-- Descuente los créditos al Estudiante Alumno.
-- Registre la tutoría.

CREATE TRIGGER t_AgregarTutoria ON Tutorias
INSTEAD OF INSERT
AS BEGIN
    IF EXISTS
    (
        SELECT 1 FROM inserted I 
        INNER JOIN Estudiantes E ON e.IDEstudiante = i.IDEstudianteAlumno
        WHERE e.Activo = 0
    ) 
    BEGIN
        PRINT('El estudiante debe estar activo')
        ROLLBACK TRANSACTION
        RETURN
    END

    IF EXISTS
    (
        SELECT 1 FROM inserted I 
        INNER JOIN Estudiantes E ON e.IDEstudiante = i.IDEstudianteTutor
        WHERE e.Activo = 0
    ) 
    BEGIN
        PRINT('El tutor debe estar activo')
        ROLLBACK TRANSACTION
        RETURN
    END

    IF EXISTS (SELECT 1 FROM inserted I WHERE i.IDEstudianteAlumno = i.IDEstudianteTutor)  
    BEGIN
        PRINT('El estudiante y el tutor no pueden ser el mismo')
        ROLLBACK TRANSACTION
        RETURN
    END

    IF EXISTS (
        SELECT 1 FROM inserted I 
        WHERE NOT EXISTS (
            SELECT 1 FROM EstudiantesMaterias EM 
            WHERE EM.IDEstudiante = I.IDEstudianteAlumno
            AND EM.IDMateria = I.IDMateria 
            AND EM.Rol = 'Alumno'
        )
    )
    BEGIN
        PRINT('El estudiante no esta anotado en la materia como alumno')
        ROLLBACK TRANSACTION
        RETURN
    END

    IF NOT EXISTS (
        SELECT 1 FROM inserted I INNER JOIN EstudiantesMaterias EM ON I.IDEstudianteTutor = EM.IDEstudiante
        WHERE i.IDMateria = EM.IDMateria AND EM.Rol ='Tutor' 
    ) 
    BEGIN
        PRINT('El estudiante no esta anotado en la materia como alumno')
        ROLLBACK TRANSACTION
        RETURN
    END

    IF EXISTS
    (
        SELECT 1 FROM inserted I INNER JOIN Estudiantes E ON I.IDEstudianteAlumno = E.IDEstudiante
        WHERE (e.SaldoCredito - i.Duracion) < -5
    )
    BEGIN
        PRINT('El estudiante no posee creditos suficientes')
        ROLLBACK TRANSACTION
        RETURN
    END


    UPDATE E SET e.SaldoCredito = e.SaldoCredito - i.Duracion 
    FROM Estudiantes E INNER JOIN inserted I ON e.IDEstudiante = I.IDEstudianteAlumno
   
    INSERT INTO HistorialCreditos(IDEstudiante, Cantidad, Tipo, Descripcion)
    SELECT IDEstudianteAlumno, Duracion, 'Usa', 'Usa ' + CAST(Duracion AS VARCHAR) + ' para tutoria' FROM inserted
  
    INSERT INTO Tutorias(IDEstudianteAlumno, IDEstudianteTutor, IDMateria, Fecha, Duracion) 
    SELECT IDEstudianteAlumno, IDEstudianteTutor, IDMateria, Fecha, Duracion FROM inserted

END
GO

-- Realizar un trigger que al tener las dos confirmaciones en un registro de tutoría:
-- Registre en el historial de créditos de ambos (Tutor y Alumno) los créditos obtenidos o Ganados
CREATE OR ALTER TRIGGER t_ConfirmarTutoria ON Tutorias
AFTER UPDATE
AS BEGIN

    IF EXISTS (
        SELECT 1 
        FROM inserted I 
        INNER JOIN deleted D ON i.IDTutoria = d.IDTutoria
        WHERE (i.ConfirmaAlumno = 1 AND i.ConfirmaTutor = 1) 
          AND (d.ConfirmaAlumno = 0 OR d.ConfirmaTutor = 0)
    )  
    BEGIN
        -- Registrar créditos GANADOS por el TUTOR (solo los que cumplen condición)
        INSERT INTO HistorialCreditos(IDEstudiante, Cantidad, Tipo, Descripcion)
        SELECT 
            I.IDEstudianteTutor, 
            I.Duracion, 
            'INGRESO', 
            'Gana ' + CAST(I.Duracion AS VARCHAR) + ' creditos de tutoria'
        FROM inserted I
        INNER JOIN deleted D ON I.IDTutoria = D.IDTutoria
        WHERE (I.ConfirmaAlumno = 1 AND I.ConfirmaTutor = 1) 
          AND (D.ConfirmaAlumno = 0 OR D.ConfirmaTutor = 0);

        -- Actualizar SaldoCredito del TUTOR (solo los que cumplen condición)
        UPDATE E 
        SET E.SaldoCredito = E.SaldoCredito + I.Duracion 
        FROM Estudiantes E 
        INNER JOIN inserted I ON I.IDEstudianteTutor = E.IDEstudiante
        INNER JOIN deleted D ON I.IDTutoria = D.IDTutoria
        WHERE (I.ConfirmaAlumno = 1 AND I.ConfirmaTutor = 1) 
          AND (D.ConfirmaAlumno = 0 OR D.ConfirmaTutor = 0);
    END
END
GO

--Realizar un trigger que al eliminar un registro de tutoría realice la cancelación de esta.
--El trigger deberá:
--Sumar los créditos descontados al estudiante con rol de alumno de acuerdo con la duración de la tutoría.
--Descontar los créditos al estudiante con rol de tutor de acuerdo con la duración de la tutoría si el registro eliminado tenía la aprobación de ambos.
--Actualizar el estado de esta a “Cancelada”.

CREATE TRIGGER t_EliminarTutoria ON Tutorias
INSTEAD OF DELETE
AS BEGIN
    IF EXISTS(
        SELECT 1 FROM deleted D WHERE d.Estado != 'Cancelada'
    ) 
    BEGIN
        UPDATE E SET e.SaldoCredito = E.SaldoCredito + d.Duracion FROM Estudiantes E
        INNER JOIN deleted D ON D.IDEstudianteAlumno = E.IDEstudiante
        WHERE D.Estado != 'Cancelada'

        INSERT INTO HistorialCreditos(IDEstudiante, Cantidad, Tipo, Descripcion)
        SELECT D.IDEstudianteAlumno, D.Duracion, 'Recupera', 'Recupera ' + CAST(d.Duracion as varchar) + ' por cancelacion de tutoria' 
        FROM deleted D
        WHERE d.Estado != 'Cancelada'

        UPDATE E SET e.SaldoCredito = E.SaldoCredito - d.Duracion FROM Estudiantes E
        INNER JOIN deleted D ON D.IDEstudianteTutor = E.IDEstudiante
        WHERE D.Estado != 'Cancelada' AND (D.ConfirmaAlumno = 1 and D.ConfirmaTutor = 1)
        
        INSERT INTO HistorialCreditos(IDEstudiante, Cantidad, Tipo, Descripcion)
        SELECT D.IDEstudianteTutor, D.Duracion, 'No gana', 'No gana ' + CAST(d.Duracion as varchar) + ' por cancelacion de tutoria' 
        FROM deleted D
        WHERE d.Estado != 'Cancelada' AND (D.ConfirmaAlumno = 1 and D.ConfirmaTutor = 1)      
        
        UPDATE T SET t.Estado = 'Cancelada' FROM Tutorias T 
        INNER JOIN deleted D on D.IDTutoria = T.IDTutoria
        WHERE D.Estado != 'Cancelada'
    END
END
GO


--Realizar un trigger que al eliminar un estudiante realice la baja lógica del mismo en el sistema. 
--El trigger deberá:
--Cambiar el estado a inactivo.
--Realizar la baja física de todos sus registros en la tabla “HistorialCreditos”.

CREATE TRIGGER t_EliminarEstudiante ON Estudiantes
INSTEAD OF DELETE
AS BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM deleted D WHERE d.Activo = 1
    ) 
    BEGIN 
        PRINT('No hay estudiantes activos para eliminar')
        ROLLBACK TRANSACTION 
        RETURN
    END

    UPDATE E SET E.Activo = 0 FROM Estudiantes E 
    INNER JOIN deleted D ON E.IDEstudiante = D.IDEstudiante 
    WHERE D.Activo = 1

    DELETE FROM HistorialCreditos WHERE IDEstudiante IN (SELECT IDEstudiante FROM deleted WHERE Activo = 1)
END