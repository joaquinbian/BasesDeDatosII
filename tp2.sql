USE DBArchivos
GO

INSERT INTO TiposUsuario(TipoUsuario) 
VALUES
('Suscripcion Free'),
('Suscripcion Basica'),
('Suscripcion Plus'),
('Suscripcion Premium'),
('Suscripcion Empresarial');
GO

INSERT INTO Permisos(Nombre)
VALUES 
('Lectura'),
('Comentario'),
('Escritura'),
('Administrador');
GO

SELECT * FROM TiposUsuario;

INSERT INTO Usuarios(Nombre, Apellido, IDTipoUsuario)
VALUES
('Adrian', 'Clarck', 1),
('Maria', 'Gonzalez', 2),
('Carlos', 'Lopez', 3),
('Ana', 'Martinez', 4),
('Luis', 'Fernandez', 5),
('John', 'Smith', 1),
('Emily', 'Johnson', 2),
('Michael', 'Williams', 3),
('Jessica', 'Brown', 4),
('David', 'Jones', 5);
GO

SELECT * FROM Usuarios;

INSERT INTO TiposArchivos(TipoArchivo)
VALUES
('Documento PDF'),
('Imagen JPEG'),
('Imagen BMP'),
('Archivo ZIP'),
('Ejecutable EXE'),
('Documento Word'),
('Hoja de Calculo Excel'),
('Presentacion PowerPoint'),
('Archivo de Texto TXT'),
('Archivo HTML'),
('Archivo CSS'),
('Archivo JavaScript'),
('Archivo XML'),
('Archivo JSON'),
('Archivo MP3'),
('Video MP4'),
('Archivo WAV'),
('Imagen PNG'),
('Archivo GIF'),
('Archivo TAR');
GO

SELECT * FROM Usuarios;
SELECT * FROM TiposArchivos;

INSERT INTO Archivos 
(
    IDUsuarioDuenio, 
    IDTipoArchivo, 
    Nombre, 
    Extension, 
    Descripcion, 
    Tamanio, 
    FechaCreacion, 
    FechaUltimaModificacion, 
    Eliminado
) VALUES 
(1, 1, 'Informe Anual', 'pdf', 'Informe de resultados anuales',  204800,' 2021-03-15', '2021-02-16', 0),
(1, 2, 'Foto de perfil', 'jpg', 'Imagen para perfil en la plataforma',  51200,' 2022-01-10', '2022-01-10', 0),
(1, 4, 'Backup sistema', 'zip', 'Copia de seguridad del sistema',  104857600, '2023-05-01', '2023-05-01', 1),
(2, 8, 'Presentacion Proyecto', 'pptx', 'Presentacion del proyecto final',  307200, '2022-07-22', '2022-07-22', 0),
(2, 7, 'Reporte Financiero', 'xls', 'Reporte del estado financiero',  102400, '2022-12-05', '2022-12-06', 0),
(2, 18, 'Diagrama de red', 'png', 'Diagrama de la red interna',  81920, '2021-09-15', '2021-09-15', 0),
(3, 1, 'Manual de usuario', 'pdf', 'Manual de uso del software',  256000, '2021-11-10', '2021-11-11', 0),
(3, 7, 'Informe de ventas', 'xls', 'Informe de ventas del trimestre',  76800, '2023-01-20',  '2023-01-21', 0),
(4, 6, 'Documento Legal', 'docx', 'Contrato legal revisado',  51200, '2020-03-01', '2020-03-02', 0),
(4, 8, 'Plan de Marketing', 'pptx', 'Plan de Marketing para el nuevo prodcuto', 153600, '2022-10-10', '2022-10-11', 0),
(4, 7, 'Presupuesto 2023', 'xls', 'Presupuesto aprobado para 2023', 12800, '2023-08-15', '2023-08-16', 0),
(4,18, 'Logo Empresa', 'png', 'Logo oficial de la empresa', 102400, '2020-06-20', '2020-06-20', 1),
(5,15, 'Audio Conferencia', 'mp3', 'Grabacion de la conferencia anual', 52428800, '2021-04-12', '2021-04-12', 0),
(5,16, 'Video Promocional', 'mp4', 'Video promocional del nuevo producto', 104857600, '2023-02-14', '2023-02-14', 0),
(6,6, 'Guia de estilo', 'docx', 'Guia del estilo para la empresa', 40960, '2022-05-30', '2022-05-30', 0),
(6,1, 'Esquema de base de datos', 'pdf', 'Esquema detallado de la base de datos', 40960, '2023-07-21', '2023-07-21', 0),
(7,8, 'Presentacion Producto', 'pptx', 'Presentacion de caracteristicas del nuevo producto', 204800, '2021-08-15', '2021-08-15', 0),
(7,6, 'Analisis competencia', 'docx', 'Analisis del mercado y competencia', 61440, '2022-03-18', '2022-03-18', 0),
(8,6, 'Memorandum interno', 'docx', 'Memorandum para todo el personal', 30720, '2023-11-10', '2023-11-10', 0),
(8,1, 'Propyesta comercial', 'pdf', 'Propuesta comercial para el cliente', 153600, '2021-04-05', '2021-04-06', 1),
(9,7, 'Plan Estrategico', 'xls', 'Plan estrategico para los proximos 5 anios', 256000, '2023-02-28', '2023-02-28', 0),
(9,1, 'Informe de sostenibilidad', 'pdf', 'Informe anual de sostenibilidad', 204800, '2020-11-11', '2020-11-11', 0),
(9,6, 'Resumen Ejecutivo', 'docx', 'Resumen ejecutivo del informe anual', 40960, '2021-12-20', '2021-12-20', 0),
(1,4, 'Backup datos', 'zip', 'Copia de seguridad de los datos', 209715200, '2024-01-01', '2024-01-01', 0),
(2,1, 'Esquema del proyecto', 'pdf', 'Esquema general del proyecto', 102400, '2022-04-15', '2022-04-16', 0),
(3,16, 'Video corporativo', 'mp4', 'Video de presentacion corporativa', 157286400, '2023-06-05', '2023-06-05', 1),
(4,6, 'Documento de propuesta', 'docx', 'Propuesta enviada al cliente', 61440, '2021-09-01', '2021-09-01', 0),
(7,1, 'Estudio de mercado', 'pdf', 'Estudio de mercado para la nueva campania', 153600, '2022-06-22', '2022-06-22', 0),
(8,7, 'Modelo Financiero', 'xls', 'Modelo financiero para la nueva lina de negocio', 204800, '2024-02-01', '2024-02-02', 0),
(9,4, 'Archivo de codigo', 'zip', 'Codigo fuente del proyecto', 104857600, '2023-03-30', '2023-03-31', 1),
(2,6, 'Documento Eliminado', 'docx', 'Documento que fue eliminado', 40960, '2021-07-15', '2021-07-15', 1),
(4,18, 'Imagen vieja', 'png', 'Imagen que fue reemplazada', 102400, '2022-09-10', '2022-09-10', 1),
(6,1, 'Archivo descontinuado', 'pdf', 'Archivo que ya no se usa', 153600,' 2020-12-25', '2020-12-26', 1),
(8,8, 'Version Antigua', 'pptx', 'Version anterior de la presentacion', 204800, '2023-05-15', '2023-05-16', 1);
GO

SELECT * FROM Archivos;
SELECT * FROM Usuarios;
SELECT * FROM Permisos;


INSERT INTO ArchivosCompartidos(IDArchivo, IDUsuario, IDPermiso, FechaCompartido)
VALUES
(1, 6, 1, '2022-05-11'),
(2, 7, 2, '2022-06-15'),
(3, 8, 3, '2023-01-12'),
(4, 9, 1, '2020-08-01'),
(5, 5, 4, '2023-09-20'),
(6, 6, 1, '2022-02-18'),
(7, 7, 3, '2021-10-05'),
(8, 8, 1, '2023-04-17'),
(9, 9, 2, '2020-04-25'),
(10, 1, 4, '2022-11-30'),
(11, 2, 1, '2021-06-22'),
(12, 3, 3, '2023-02-14'),
(13, 4, 2, '2020-01-19'),
(14, 6, 1, '2023-03-23'),
(15,7, 4, '2022-07-29'),
(16,7, 2, '2023-12-05'),
(17,8, 1, '2021-09-16'),
(18,9, 3, '2020-12-07'),
(18,1, 4, '2024-02-28'),
(18,10, 1, '2023-05-10');
GO
