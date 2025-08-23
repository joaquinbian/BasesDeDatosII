USE Clase02
GO

CREATE TABLE PresupuestosAnualesAreas(
    IDArea SMALLINT NOT NULL,
    Anio SMALLINT NOT NULL,
    Presupuesto MONEY NOT NULL CHECK (Presupuesto >= 0),
    FOREIGN KEY (IDArea) REFERENCES Areas(IDArea),
    PRIMARY KEY (IDArea, Anio)
)
GO

CREATE TABLE Proyectos (
    IDProyecto INT NOT NULL PRIMARY KEY IDENTITY(1,1), --incremental
    Nombre VARCHAR(255) NOT NULL
)