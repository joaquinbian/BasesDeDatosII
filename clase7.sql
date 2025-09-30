CREATE DATABASE Clase07
GO

USE Clase07;
GO

CREATE TABLE Clientes (
    IDCliente INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    Apellidos VARCHAR(50) NOT NULL,
    Nombres VARCHAR(50) NOT NULL,
    Estado BIT NOT NULL
)

CREATE TABLE TiposCuenta(
    IDTipoCuenta VARCHAR(2) NOT NULL PRIMARY KEY,
    Nombre VARCHAR(50)
)


CREATE TABLE Cuentas(
    IDCuenta INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    IDCliente INT NOT NULL FOREIGN KEY REFERENCES Clientes(IDCliente),
    IDTipoCuenta VARCHAR(2) NOT NULL FOREIGN KEY REFERENCES TiposCuenta(IDTipoCuenta),
    FechaApertura DATE NOT NULL,
    FechaBaja DATE,
    LimiteDescubierto MONEY NOT NULL,
    Saldo Money NOT NULL
)

CREATE TABLE Movimientos(
    IDMovimiento BIGINT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    IDCuenta INT NOT NULL FOREIGN KEY REFERENCES Cuentas(IDCuenta),
    Fecha DATETIME NOT NULL,
    Importe Money NOT NULL,
    TipoMovimiento CHAR(1) NOT NULL
)

ALTER TABLE Movimientos
ADD CONSTRAINT CHK_Importe CHECK (Importe >= 0)

ALTER TABLE Movimientos
ADD CONSTRAINT CHK_TipoMov CHECK (TipoMovimiento IN ('D', 'C'))

ALTER TABLE Cuentas
ADD CONSTRAINT CHK_SaldoCorrecto CHECK(Saldo >= LimiteDescubierto * -1)

DELETE FROM TiposCuenta;
DELETE from Clientes;
DELETE from Cuentas;
-- 1. Tipos de Cuenta
INSERT INTO TiposCuenta (IDTipoCuenta, Nombre)
VALUES 
('CC', 'Cuenta Corriente'),
('CA', 'Caja de Ahorro'),
('SU', 'Cuenta Sueldo');


-- 2. Clientes
INSERT INTO Clientes (Apellidos, Nombres, Estado)
VALUES
('González', 'María', 1),
('Pérez', 'Juan', 1),
('Rodríguez', 'Ana', 1),
('López', 'Carlos', 0), -- inactivo
('Martínez', 'Lucía', 1);

SELECT * FROM Clientes;

-- 3. Cuentas
INSERT INTO Cuentas (IDCliente, IDTipoCuenta, FechaApertura, FechaBaja, LimiteDescubierto, Saldo)
VALUES
(11, 'CC', '2021-05-10', NULL, 5000, 12000),   -- María González
(11, 'CA', '2022-03-15', NULL, 0, 3500),      -- María González
(12, 'CA', '2020-10-01', NULL, 0, 800),       -- Juan Pérez
(13, 'SU', '2023-01-20', NULL, 0, 2000),      -- Ana Rodríguez
(14, 'CC', '2019-07-07', '2024-01-01', 1000, 0), -- Carlos López (dada de baja)
(15, 'CA', '2024-02-11', NULL, 0, 15000);     -- Lucía Martínez

SELECT * FROM Cuentas;
-- 4. Movimientos
-- Convención: Importe >= 0, 'C' = crédito, 'D' = débito
INSERT INTO Movimientos (IDCuenta, Fecha, Importe, TipoMovimiento)
VALUES
-- Movimientos de María (Cuenta Corriente ID=9)
(9, '2024-09-01 10:30:00', 2000, 'C'),  -- depósito
(9, '2024-09-05 15:20:00', 500, 'D'),   -- extracción
(9, '2024-09-10 09:00:00', 1200, 'D'),  -- pago

-- Movimientos de María (Caja de Ahorro ID=10)
(10, '2024-08-15 11:00:00', 1000, 'C'),
(10, '2024-08-18 14:00:00', 200, 'D'),

-- Movimientos de Juan (Caja de Ahorro ID=11)
(11, '2024-07-02 09:45:00', 500, 'C'),
(11, '2024-07-04 18:30:00', 100, 'D'),

-- Movimientos de Ana (Cuenta Sueldo ID=12)
(12, '2024-06-01 12:00:00', 2000, 'C'),
(12, '2024-06-02 10:00:00', 500, 'D'),

-- Movimientos de Lucía (Caja de Ahorro ID=14)
(14, '2024-05-10 08:30:00', 10000, 'C'),
(14, '2024-05-12 16:00:00', 3000, 'D');
