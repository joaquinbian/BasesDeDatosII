USE DBTutorias
GO

-- Crear una vista que devuelva el listado de todos los estudiantes que estén activos en el sistema
--  mostrando su legajo, nombre, apellido, email y saldo de créditos actual.

CREATE VIEW V_ESTUDIANTES_ACTIVOS AS
    SELECT Legajo, Nombre, Apellido, Email, SaldoCredito FROM Estudiantes WHERE Activo = 1;
GO

-- Crear una vista que devuelva el listado de postulaciones de estudiantes a materias, mostrando el nombre completo del estudiante, el nombre de la materia y el rol (Tutor o Alumno) en el que se postuló.
CREATE VIEW V_POSTULACIONES AS
SELECT E.Nombre, E.Apellido, M.Nombre AS NombreMateria, Rol FROM EstudiantesMaterias EM
INNER JOIN Estudiantes E ON E.IDEstudiante = EM.IDEstudiante
INNER JOIN Materias M ON M.IDMateria = EM.IDMateria;
GO

-- Crear una vista que devuelva las tutorías que fueron confirmadas 
--tanto por el tutor como por el alumno, mostrando la fecha, duración, nombre de la materia, nombre completo del tutor y nombre completo del alumno.

CREATE VIEW V_TUTORIAS_CONFIRMADAS AS
    SELECT 
        t.Fecha, 
        t.Duracion, 
        m.Nombre as Materia, 
        ea.Nombre as NombreAlumno, 
        ea.Apellido as ApellidoAlumno, 
        et.Nombre as NombreTutor, 
        et.Apellido as ApellidoTutor 
    FROM Tutorias T 
    INNER JOIN Estudiantes EA ON T.IDEstudianteAlumno = EA.IDEstudiante
    INNER JOIN Estudiantes ET ON T.IDEstudianteTutor = ET.IDEstudiante
    INNER JOIN Materias M ON T.IDMateria = M.IDMateria
    WHERE T.Estado = 'Realizada';
    GO


-- Crear una vista que devuelva el historial de movimientos de créditos de todos los estudiantes.
--mostrando el nombre completo del estudiante, la fecha del movimiento, el tipo de movimiento (Gana o Usa), la cantidad de créditos y la descripción del movimiento.

CREATE VIEW V_HISTORIAL_CREDITOS AS
    SELECT E.Nombre, E.Apellido, Fecha, Tipo, E.SaldoCredito, Descripcion FROM HistorialCreditos HC
    INNER JOIN Estudiantes E ON E.IDEstudiante = HC.IDEstudiante
    GO