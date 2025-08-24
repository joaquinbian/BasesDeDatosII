USE Clase02
GO

CREATE TABLE PresupuestosAnualesAreas
(
    IDArea SMALLINT NOT NULL,
    Anio SMALLINT NOT NULL,
    Presupuesto MONEY NOT NULL CHECK (Presupuesto >= 0),
    FOREIGN KEY (IDArea) REFERENCES Areas(IDArea),
    PRIMARY KEY (IDArea, Anio)
)
GO

CREATE TABLE Proyectos
(
    IDProyecto INT NOT NULL PRIMARY KEY IDENTITY(1,1), --incremental
    Nombre VARCHAR(255) NOT NULL
)
GO

CREATE TABLE EmpleadosProyecto
(
    IDEmpleado INT NOT NULL FOREIGN KEY REFERENCES Empleados(IDEmpleado),
    IDProyecto INT NOT NULL FOREIGN KEY REFERENCES Proyectos(IDProyecto),
    PRIMARY KEY (IDEmpleado, IDProyecto)
)
GO

CREATE TABLE TiemposEmpleadosProyecto
(
    ID BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    IDEmpleado int NOT NULL,
    IDProyecto int NOT NULL,
    Fecha Date NOT NULL,
    MinutosTrabajados SMALLINT NOT NULL CHECK (MinutosTrabajados > 0)
)
GO


ALTER TABLE TiemposEmpleadosProyecto
ADD CONSTRAINT FK_EmpleadosProyecto FOREIGN KEY(IDEmpleado, IDProyecto) REFERENCES EmpleadosProyecto(IDEmpleado, IDProyecto)
GO


-- CONSULTAS DE ACCION
INSERT INTO Areas(IDArea, Nombre, Mail) VALUES(1, 'Sistemas', 'sistemas@mail.com');
INSERT INTO Areas(IDArea, Nombre, Mail) VALUES(2, 'Recursos Humanos', 'rrhh@mail.com');
