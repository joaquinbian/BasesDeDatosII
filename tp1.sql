CREATE DATABASE DBArchivos;
GO

USE DBArchivos;
GO

CREATE TABLE TiposArchivos(
    IDTipoArchivo BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    TipoArchivo VARCHAR(255) NOT NULL
);
GO

CREATE TABLE TiposUsuario(
    IDTipoUsuario BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    TipoUsuario VARCHAR(255) NOT NULL
);
GO

CREATE TABLE Permisos(
    IDPermiso BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(255) NOT NULL
);
GO

CREATE TABLE Usuarios(
    IDUsuario BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    IDTipoUsuario BIGINT NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    FOREIGN KEY (IDTipoUsuario) REFERENCES TiposUsuario(IDTipoUsuario)
);
GO

CREATE TABLE Archivos(
    IDArchivo BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    IDUsuarioDuenio BIGINT NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(255) NOT NULL,
    Extension VARCHAR(50) NOT NULL,
    IDTipoArchivo BIGINT NOT NULL,
    Tamanio INT NOT NULL,
    FechaCreacion DATE NOT NULL,
    FechaUltimaModificacion DATE NOT NULL,
    Eliminado BIT NOT NULL,
    FOREIGN KEY (IDUsuarioDuenio) REFERENCES Usuarios(IDUsuario),
    FOREIGN KEY (IDTipoArchivo) REFERENCES TiposArchivos(IDTipoArchivo)
);
GO

CREATE TABLE ArchivosCompartidos(
    IDArchivo BIGINT NOT NULL,
    IDUsuario BIGINT NOT NULL,
    IDPermiso BIGINT NOT NULL,
    PRIMARY KEY(IDArchivo, IDUsuario),
    FOREIGN KEY (IDArchivo) REFERENCES Archivos(IDArchivo),
    FOREIGN KEY (IDUsuario) REFERENCES Usuarios(IDUsuario),
    FOREIGN KEY (IDPermiso) REFERENCES Permisos(IDPermiso)
);
GO


ALTER TABLE ArchivosCompartidos 
ADD FechaCompartido DATE NOT NULL;
GO 