-- ********************************************************************
--  *  DDL Y DML DEL PROYECTO DE UNA BASE DE DATOS PARA UNA VETERINARIA*
-- ********************************************************************
-- Ultima modificación 5 de agosto del 2021
set LINE 180;

-- Creamos un tablespace
CREATE TABLESPACE VETERINARIA
DATAFILE 'c:\app\erik\oradata\orcl\users.dbf'
size 50M;

-- Creamos un usuario para la base de datos
CREATE USER VETERINARIA_ADM IDENTIFIED BY PASS123
DEFAULT TABLESPACE VETERINARIA TEMPORARY TABLESPACE TEMP;
GRANT DBA TO VETERINARIA_ADM;
ALTER USER VETERINARIA_ADM QUOTA UNLIMITED ON VETERINARIA;

-- Limpiamos las tablas y secuencias ya existentes
DROP TABLE VETERINARIA
DROP TABLE PROPIETARIO;
DROP TABLE TELEFONOPROP;
DROP TABLE MASCOTA;
DROP TABLE SERVICIO;
DROP TABLE MASCOTA_SERVICIO
DROP TABLE EMPLEADO;
DROP TABLE CONSULTA;
DROP TABLE SERVICIO_CONSULTA;
DROP TABLE DATOS_INTERNAMIENTO;
DROP TABLE INTERNAMIENTO;
DROP TABLE MEDICO;
DROP TABLE CUIDADOR;
DROP TABLE TELEFONO_CUIDADOR;
DROP TABLE RECIBO
DROP TABLE PAGO
DROP TABLE MEDICAMENTO;
DROP TABLE CONS_MEDI;
DROP TABLE INTER_MEDI;
SELECT TABLE_NAME FROM USER_TABLES;

DROP SEQUENCE SQ_CLAVEPROPIETARIO;
DROP SEQUENCE SQ_CLAVE_SERVICIO;
DROP SEQUENCE SQ_CLAVE_CONSULTA;
DROP SEQUENCE SQ_CLAVE_VACUNA;
DROP SEQUENCE SQ_CLAVE_DESP;
DROP SEQUENCE SQ_CLAVEINTER;
DROP SEQUENCE SQ_CLAVEEMP;
DROP SEQUENCE SQ_CLAVECUI;
DROP SEQUENCE SQ_FOLIO;
DROP SEQUENCE SQ_NUMPAGO;
DROP SEQUENCE SQ_CLAVE_MASCOTA;


CREATE TABLE PROPIETARIO(
    claveProp NUMBER(4) PRIMARY KEY,
    nomProp VARCHAR2(15) NOT NULL,
    apPatProp VARCHAR2(15) NOT NULL,
    apMatProp VARCHAR2(15),
    colProp VARCHAR2(20) NOT NULL,
    numCalleProp NUMBER(5) NOT NULL,
    calleProp VARCHAR2(15) NOT NULL,
    delegProp VARCHAR2(20) NOT NULL
);

CREATE TABLE TELEFONOPROP(
    claveProp NUMBER(4),
    telefono NUMBER(10),
    CONSTRAINT fkTelProp FOREIGN KEY(claveProp) REFERENCES propietario ON DELETE CASCADE,
    CONSTRAINT pkTelProp PRIMARY KEY(claveProp, telefono)
);

CREATE TABLE MASCOTA(
    claveMascota NUMBER(4),
    claveProp NUMBER(4),
    nomMascota VARCHAR2(15) NOT NULL,
    colorMascota VARCHAR2(15) NOT NULL,
    especieMascota VARCHAR2(15) NOT NULL,
    razaMascota VARCHAR2(15) NOT NULL,
    edadMascota NUMBER(2) NOT NULL,
    CONSTRAINT fkMasc FOREIGN KEY (claveProp) REFERENCES propietario ON DELETE CASCADE,
    CONSTRAINT pkMasc PRIMARY KEY (claveMascota)
);

CREATE TABLE SERVICIO(
    claveServ NUMBER(4) PRIMARY KEY,
    tipoServ NUMBER(1) NOT NULL,
    descripcionServ VARCHAR2(50) NOT NULL,
    costoServ NUMBER(5) NOT NULL,
    CONSTRAINT CK_TIPOSERV CHECK ( TIPOSERV IN (1,2,3,4) ),
    CONSTRAINT CK_DESCSER CHECK ( DESCRIPCIONSERV IN ('CONSULTA’, ‘VACUNACION’, ‘DESPARACITACION’, ‘INTERNAMIENTO') )
);

CREATE TABLE MASCOTA_SERVICIO (
    ClaveServ NUMBER(4) ,
    ClaveMascota NUMBER(4),
    fechaAtencion DATE DEFAULT SYSDATE,
    CONSTRAINT PK_MASC_SERV PRIMARY KEY (CLAVESERV, CLAVEMASCOTA),
    CONSTRAINT FK_CLVSERV FOREIGN KEY (CLAVESERV) REFERENCES SERVICIO(CLAVESERV),
    CONSTRAINT FK_CLVMASC FOREIGN KEY (CLAVEMASCOTA) REFERENCES MASCOTA(CLAVEMASCOTA) ON DELETECASCADE
);
-- Hasta aqui ya se actualizó la creación de las tablas

CREATE TABLE EMPLEADO(
    claveEmp NUMBER(4) NOT NULL,
    nomEmp VARCHAR2(15) NOT NULL,
    apPatEmp VARCHAR2(15) NOT NULL,
    apMatEmp VARCHAR2(15),
    horarioInicioServ VARCHAR2(5) NOT NULL,
    horarioFinServ VARCHAR2(5) NOT NULL,
    fechaIngresoEmp DATE DEFAULT SYSDATE,
    CONSTRAINT PK_EMPLEADO PRIMARY KEY (claveEmp),
    CONSTRAINT CK_HORA_INICIO CHECK ( horarioInicioServ LIKE ( ‘__:__’)),    
    CONSTRAINT CK_HORA_FIN CHECK ( horarioFinServ LIKE ( ‘__:__’))
);

CREATE TABLE CONSULTA(
    claveCons NUMBER(4),
    diagnostico VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_CONSULTA PRIMARY KEY (claveCons)
);

CREATE TABLE SERVICIO_CONSULTA(
    claveServ NUMBER(4),
    claveCons NUMBER(4),
    claveEmp NUMBER(4),
    CONSTRAINT PK_SERVCONS PRIMARY KEY (claveServ,claveCons),
    CONSTRAINT FK_SERV1 FOREIGN KEY (claveServ) REFERENCES SERVICIO,
    CONSTRAINT FK_SERV2 FOREIGN KEY (claveCons) REFERENCES CONSULTA,
    CONSTRAINT FK_SERV3 FOREIGN KEY (claveEmp) REFERENCES EMPLEADO
);

CREATE TABLE DATOS_INTERNAMIENTO(
    claveInter NUMBER(4),
    inicioInternamiento DATE DEFAULT SYSDATE,
    finInternamiento DATE,
    diasInternamiento NUMBER(2) ,
    CONSTRAINT PK_DATOSINTER PRIMARY KEY (claveInter)
);

CREATE TABLE INTERNAMIENTO(
    claveServ NUMBER(4),
    claveInter NUMBER(4),
    claveEmp NUMBER(4),
    CONSTRAINT PK_INTERNAMIENTO PRIMARY KEY (claveServ,claveInter),
    CONSTRAINT FK_INTER1 FOREIGN KEY (claveServ) REFERENCES SERVICIO,
    CONSTRAINT FK_INTER2 FOREIGN KEY (claveEmp) REFERENCES EMPLEADO,
    CONSTRAINT FK_INTER3 FOREIGN KEY (claveInter) REFERENCES DATOS_INTERNAMIENTO
);

CREATE TABLE MEDICO(
    claveEmp NUMBER(4),
    claveMedico NUMBER(4),
    cedulaProfMed NUMBER(8) NOT NULL,
    especialidadMed VARCHAR2(20) NOT NULL,
    CONSTRAINT PK_MEDICO PRIMARY KEY (claveEmp,claveMedico),
    CONSTRAINT FK_MEDICO FOREIGN KEY (claveEmp) REFERENCES EMPLEADO
);

CREATE TABLE CUIDADOR(
    claveEmp NUMBER(4),
    claveCui NUMBER(4),
    areaClinica VARCHAR2(20) NOT NULL,
    delCuid VARCHAR2(20) NOT NULL,
    colCuid VARCHAR2(20) NOT NULL,
    calleCuid VARCHAR2(20) NOT NULL,
    CONSTRAINT PK_CUIDADOR PRIMARY KEY (claveEmp,claveCui),
    CONSTRAINT FK_CUIDADOR FOREIGN KEY (claveEmp) REFERENCES EMPLEADO
);

CREATE TABLE TELEFONO_CUIDADOR(
    claveEmp NUMBER(4),
    telefonoCui NUMBER(10),
    CONSTRAINT PK_TELCUI PRIMARY KEY (claveEmp,telefonoCui),
    CONSTRAINT FK_TELCUI FOREIGN KEY (claveEmp) REFERENCES EMPLEADO
);


CREATE TABLE RECIBO
(
    folio NUMBER(5),
    claveProp NUMBER(5) NOT NULL,
    fechaRecibo DATE DEFAULT SYSDATE,
    montoTotal NUMBER(7,2) NOT NULL,
    CONSTRAINT fkReciboPropi FOREIGN KEY(claveProp) REFERENCES propietario,
    CONSTRAINT pkRecibo PRIMARY KEY(folio),
    CONSTRAINT ckRecFolio CHECK(folio>0)
);

CREATE TABLE PAGO
(
    folio NUMBER(5) ,
    numPago NUMBER(2),
    montoPago NUMBER(7,2) NOT NULL,
    conceptoPago VARCHAR2(15) NOT NULL,
    claveServ NUMBER(4) NOT NULL,
    saldoPagar NUMBER(7,2),
    CONSTRAINT fkPagoServ FOREIGN KEY(claveServ) REFERENCES servicio,
    CONSTRAINT fkPagoFolio FOREIGN KEY(folio) REFERENCES recibo ON DELETE CASCADE,
    CONSTRAINT pkCuidInter PRIMARY KEY(folio, numPago),
    CONSTRAINT ckPagoNum CHECK(numPago>0),
    CONSTRAINT ckConcepPago CHECK( conceptoPago IN (‘Pago Unico’ , ‘Abono’) )
);

CREATE TABLE MEDICAMENTO(
    clvMedicamento NUMBER(2),
    nomMedicamento VARCHAR(30) NOT NULL,
    CONSTRAINT pkClave_Medi PRIMARY KEY(clvMedicamento)
);

CREATE TABLE CONS_MEDI(
    clvMedicamento NUMBER(2) ,
    clvCons NUMBER(4) , 
    CONSTRAINT fkCons_ClvMedic FOREIGN KEY (clvMedicamento) REFERENCES MEDICAMENTO,
    CONSTRAINT fkCons_ClvCons FOREIGN KEY(clvCons) REFERENCES CONSULTA,
    CONSTRAINT pkConsulta_Medi PRIMARY KEY(clvMedicamento, clvCons)
);

CREATE TABLE INTER_MEDI(
    clvMedicamento NUMBER(2),
    clvInter NUMBER(4),
    CONSTRAINT fkInter_ClvMedic FOREIGN KEY(clvMedicamento) REFERENCES MEDICAMENTO,
    CONSTRAINT fkCons_ClvInter FOREIGN KEY(clvInter) REFERENCES DATOS_INTERNAMIENTO,
    CONSTRAINT pkInter_Medi PRIMARY KEY(clvMedicamento, clvInter)
);

/* ============================================================================================== */
/* PROCEDIMIENTOS DE INSERCIÓN */
/* TODO: FALTA POR AÑADIR LOS PROCEDIMIENTOS PARA EVITAR TANTO PROBLEMA CON LA INSERCIÓN DE DATOS */
/* ============================================================================================== */

-- *****************************************************
-- Creamos las secuencias para las claves de las tablas
-- *****************************************************
DROP SEQUENCE SQ_CLAVEPROPIETARIO;
CREATE SEQUENCE SQ_CLAVEPROPIETARIO
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVE_SERVICIO;
CREATE SEQUENCE SQ_CLAVE_SERVICIO
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVE_CONSULTA;
CREATE SEQUENCE SQ_CLAVE_CONSULTA
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVE_VACUNA;
CREATE SEQUENCE SQ_CLAVE_VACUNA
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVE_DESP;
CREATE SEQUENCE SQ_CLAVE_DESP
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVEINTER;
CREATE SEQUENCE SQ_CLAVEINTER
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVEEMP;
CREATE SEQUENCE SQ_CLAVEEMP
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVECUI;
CREATE SEQUENCE SQ_CLAVECUI
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_FOLIO;
CREATE SEQUENCE SQ_FOLIO
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_NUMPAGO;
CREATE SEQUENCE SQ_NUMPAGO
MINVALUE 0
START WITH 0
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVE_MASCOTA;
CREATE SEQUENCE SQ_CLAVE_MASCOTA
MINVALUE 0
START WITH 0
INCREMENT BY 1;

-- ******************************
-- DML -- AÑADIENDO DATOS A LAS TABLAS
-- ******************************
INSERT INTO CATALOGO VALUES (1, 'CONSULTA', 500);
INSERT INTO CATALOGO VALUES (2, 'VACUNACION', 100);
INSERT INTO CATALOGO VALUES (3, 'DESPARACITACION', 200);
INSERT INTO CATALOGO VALUES (4, 'INTERNAMIENTO', 800);

-- **** Primero creamos a EMPLEADO Y SUS SUBCLASES ****
-- 2 doctores y 2 cuidadores
INSERT INTO EMPLEADO ( claveEmp, nomEmp, apPatEmp, apMatEmp, horarioInicioServ, horarioFinServ ) VALUES ( SQ_CLAVEEMP.NEXTVAL, 'Mariano', 'Anaya', 'Paniagua', 09, 17 );
INSERT INTO EMPLEADO ( claveEmp, nomEmp, apPatEmp, apMatEmp, horarioInicioServ, horarioFinServ ) VALUES ( SQ_CLAVEEMP.NEXTVAL, 'Nayara', 'Villena', 'Camino', 18, 01 );
INSERT INTO EMPLEADO ( claveEmp, nomEmp, apPatEmp, apMatEmp, horarioInicioServ, horarioFinServ ) VALUES ( SQ_CLAVEEMP.NEXTVAL, 'María', 'Cristina', 'Lumbreras', 02, 09 );
INSERT INTO EMPLEADO ( claveEmp, nomEmp, apPatEmp, apMatEmp, horarioInicioServ, horarioFinServ ) VALUES ( SQ_CLAVEEMP.NEXTVAL, 'Lina', 'Felicia', 'Barros', 10, 16 );
INSERT INTO EMPLEADO ( claveEmp, nomEmp, apPatEmp, apMatEmp, horarioInicioServ, horarioFinServ ) VALUES ( SQ_CLAVEEMP.NEXTVAL, 'Carlos', 'Gomez', 'Perez', 09, 17 );
INSERT INTO EMPLEADO ( claveEmp, nomEmp, apPatEmp, apMatEmp, horarioInicioServ, horarioFinServ ) VALUES ( SQ_CLAVEEMP.NEXTVAL, 'Camila', 'Esparza', 'Miranda', 09, 17 );

INSERT INTO DATOS_MED (claveMedico, cedulaProf, especialidad) VALUES ( 1234, '312-ASDQD-21', 'EMERGENCIAS' );
INSERT INTO DATOS_MED (claveMedico, cedulaProf, especialidad) VALUES ( 4523, '121-MKMFD-09', 'GENERAL' );
INSERT INTO MEDICO ( claveEmp, claveMedico ) VALUES ( 1, 1234 );
INSERT INTO MEDICO ( claveEmp, claveMedico ) VALUES ( 2, 4523 );
INSERT INTO MEDICO ( claveEmp, claveMedico ) VALUES ( 5, 1234 );

INSERT INTO DATOS_CUI ( claveCui, colCui, delCui, calleCuidador, areaClinica ) VALUES ( SQ_CLAVECUI.NEXTVAL, 'CENTRO', 'CARR. NACIONAL', 'Montemorenos 123', 'INTENSIVOS');
INSERT INTO DATOS_CUI ( claveCui, colCui, delCui, calleCuidador, areaClinica ) VALUES ( SQ_CLAVECUI.NEXTVAL, 'Benito  Juarez', 'CDMX', 'Heriberto 920', 'REVISION');
INSERT INTO DATOS_CUI ( claveCui, colCui, delCui, calleCuidador, areaClinica ) VALUES ( SQ_CLAVECUI.NEXTVAL, 'Tlalpan', 'CDMX', 'Mañanitas 485', 'INTENSIVOS');
INSERT INTO CUIDADOR ( claveEmp, claveCui ) VALUES ( 3, 1);
INSERT INTO CUIDADOR ( claveEmp, claveCui ) VALUES ( 4, 2);
INSERT INTO CUIDADOR ( claveEmp, claveCui ) VALUES ( 6, 3);
INSERT INTO TELEFONO_CUIDADOR (claveEmp, telefonoEmp) VALUES (3, 5531759469);
INSERT INTO TELEFONO_CUIDADOR (claveEmp, telefonoEmp) VALUES (4, 5934266179);
INSERT INTO TELEFONO_CUIDADOR (claveEmp, telefonoEmp) VALUES (6, 5554102211);

-- Desparacitaciones
INSERT INTO DESC_DESPARACITANTE(claveDesp,nombreDesparacitante) VALUES (SQ_CLAVE_DESP.NEXTVAL, 'PULGAS');

-- vacunas
INSERT INTO DESC_VACUNACION(claveVac,nombreVacuna) VALUES (SQ_CLAVE_VACUNA.NEXTVAL,'MOQUILLO');

-- **Creamos al propietario 1 que contrata una consulta para su mascota **
INSERT INTO PROPIETARIO (claveProp, nomProp, apPatProp, apMatProp, colProp, numCalleProp, calleProp, delegProp)
VALUES (SQ_CLAVEPROPIETARIO.NEXTVAL, 'Lope', 'Jódar', 'Valentín', 'Molino de rosas',120 ,'Rosa trepadora', 'Molino');
INSERT INTO TELEFONOPROP (claveProp, telefono) VALUES ( SQ_CLAVEPROPIETARIO.currval, 5511488671  );
INSERT INTO MASCOTA (claveMascota, claveProp, nomMascota, colorMascota, especieMascota, razaMascota, edadMascota)
VALUES (SQ_CLAVE_MASCOTA.NEXTVAL, SQ_CLAVEPROPIETARIO.currval, 'Mesler', 'cafe', 'Canina', 'Pastor Belga', 5);
INSERT INTO SERVICIO (claveServ, claveProp, claveMascota,  tipoServ, numPagos) VALUES ( SQ_CLAVE_SERVICIO.nextval, SQ_CLAVEPROPIETARIO.currval, SQ_CLAVE_MASCOTA.currval,1, 1 );

-- Cambia dependiendo del servicio
INSERT INTO CLAVECONSULTA (claveConsulta, claveEmp, diagnostico) VALUES (SQ_CLAVE_CONSULTA.nextval, 1, 'Falta de vitaminas');
INSERT INTO CONSULTA (claveServ, CLAVECONSULTA) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_CLAVE_CONSULTA.currval);
INSERT INTO MEDICAMENTOS_CONSULTA (claveConsulta, medicamento) VALUES ( SQ_CLAVE_CONSULTA.currval, 'Ributin' );

-- se mantiene
INSERT INTO RECIBOFOLIO (folio) VALUES ( SQ_FOLIO.nextval);
INSERT INTO RECIBO (folio, claveProp) VALUES (SQ_FOLIO.currval, SQ_CLAVEPROPIETARIO.currval);
INSERT INTO PAGO (claveServ, folio, numPago, tipoServ) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_FOLIO.currval, SQ_numPago.nextval, 1);
INSERT INTO CLAVE_SERVICIO (claveServ, conceptoPago) VALUES ( SQ_CLAVE_SERVICIO.currval, 'UNICO' );

-- INSERTS CLARA
INSERT INTO PROPIETARIO (claveProp, nomProp, apPatProp, apMatProp, colProp, numCalleProp, calleProp, delegProp)
VALUES (SQ_CLAVEPROPIETARIO.NEXTVAL, 'Carlota', 'Díaz', 'Mar', 'Jazmin',850 ,'Rosio', 'Tlahuac');
INSERT INTO TELEFONOPROP (claveProp, telefono) VALUES ( SQ_CLAVEPROPIETARIO.currval, 8896542553);

-- Añadimos un cliente 2
INSERT INTO RECIBOFOLIO (folio) VALUES ( SQ_FOLIO.nextval);
INSERT INTO RECIBO (folio, claveProp) VALUES (SQ_FOLIO.currval, SQ_CLAVEPROPIETARIO.currval);
-- mascota 1
INSERT INTO MASCOTA (claveMascota, claveProp, nomMascota, colorMascota, especieMascota, razaMascota, edadMascota)
VALUES (SQ_CLAVE_MASCOTA.NEXTVAL, SQ_CLAVEPROPIETARIO.currval, 'Mia', 'Gris', 'Canina', 'Pastor Ingles', 6);

-- consulta m1
INSERT INTO SERVICIO (claveServ, claveProp, claveMascota,  tipoServ, numPagos) VALUES ( SQ_CLAVE_SERVICIO.nextval, SQ_CLAVEPROPIETARIO.currval, SQ_CLAVE_MASCOTA.currval,1,1);
INSERT INTO CLAVECONSULTA (claveConsulta, claveEmp, diagnostico) VALUES (SQ_CLAVE_CONSULTA.nextval, 1, 'Moquillo');
INSERT INTO CONSULTA (claveServ, CLAVECONSULTA) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_CLAVE_CONSULTA.currval);
INSERT INTO MEDICAMENTOS_CONSULTA (claveConsulta, medicamento) VALUES ( SQ_CLAVE_CONSULTA.currval, 'Paracetamol' );
-- VACUNA M1
INSERT INTO SERVICIO (claveServ, claveProp, claveMascota,  tipoServ, numPagos) VALUES ( SQ_CLAVE_SERVICIO.nextval, SQ_CLAVEPROPIETARIO.currval, SQ_CLAVE_MASCOTA.currval,2,1);
INSERT INTO VACUNACION(claveServ,claveVac) VALUES (SQ_CLAVE_SERVICIO.currval,1);
INSERT INTO PAGO (claveServ, folio, numPago, tipoServ) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_FOLIO.currval, SQ_numPago.nextval, 2);
INSERT INTO CLAVE_SERVICIO (claveServ, conceptoPago) VALUES ( SQ_CLAVE_SERVICIO.currval, 'UNICO' );
-- mascota 2
INSERT INTO MASCOTA (claveMascota, claveProp, nomMascota, colorMascota, especieMascota, razaMascota, edadMascota)
VALUES (SQ_CLAVE_MASCOTA.NEXTVAL, SQ_CLAVEPROPIETARIO.currval, 'Bonita', 'Blanco', 'Gato', 'Egipcio', 2);
-- DESP M2
INSERT INTO SERVICIO (claveServ, claveProp, claveMascota,  tipoServ, numPagos) VALUES ( SQ_CLAVE_SERVICIO.nextval, SQ_CLAVEPROPIETARIO.currval, SQ_CLAVE_MASCOTA.currval,3,1);
INSERT INTO DESPARACITACION(claveServ,claveDesp) VALUES (SQ_CLAVE_SERVICIO.currval,1);
INSERT INTO PAGO (claveServ, folio, numPago, tipoServ) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_FOLIO.currval, SQ_numPago.nextval, 3);
INSERT INTO CLAVE_SERVICIO (claveServ, conceptoPago) VALUES ( SQ_CLAVE_SERVICIO.currval, 'UNICO' );

INSERT INTO PROPIETARIO (claveProp, nomProp, apPatProp, apMatProp, colProp, numCalleProp, calleProp, delegProp)
VALUES (SQ_CLAVEPROPIETARIO.NEXTVAL, 'Diego', 'Camarena', 'Ruiz', 'Zacatenco',872,'Acueducto', 'Gustavo A. Madero');

INSERT INTO TELEFONOPROP (claveProp, telefono) VALUES ( SQ_CLAVEPROPIETARIO.currval, 5527767450);

INSERT INTO MASCOTA (claveMascota, claveProp, nomMascota, colorMascota, especieMascota, razaMascota, edadMascota)
VALUES (SQ_CLAVE_MASCOTA.NEXTVAL, SQ_CLAVEPROPIETARIO.currval, 'Lulo', 'Cafe', 'Canina', 'Daschund', 9);

INSERT INTO MASCOTA (claveMascota, claveProp, nomMascota, colorMascota, especieMascota, razaMascota, edadMascota)
VALUES (SQ_CLAVE_MASCOTA.NEXTVAL, SQ_CLAVEPROPIETARIO.currval, 'Iguro', 'Negro', 'Canina', 'Daschund', 1);

-- AÑADIMOS UN INTERNAMIENTO
INSERT INTO SERVICIO (claveServ, claveProp, claveMascota,  tipoServ, numPagos) VALUES ( SQ_CLAVE_SERVICIO.nextval, SQ_CLAVEPROPIETARIO.currval, SQ_CLAVE_MASCOTA.currval,4,1);
INSERT INTO DESC_INTERNAMIENTO (claveInternamiento, finInternamiento) VALUES (SQ_CLAVEINTER.NEXTVAL,'05-AUG-21');
INSERT INTO INTERNAMIENTO (claveServ, claveInternamiento) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_CLAVEINTER.currval);
INSERT INTO CUIDADORINTER (claveServ, claveCui) VALUES (SQ_CLAVE_SERVICIO.currval,3);

INSERT INTO RECIBOFOLIO (folio) VALUES ( SQ_FOLIO.nextval);
INSERT INTO RECIBO (folio, claveProp) VALUES (SQ_FOLIO.currval, SQ_CLAVEPROPIETARIO.currval);
INSERT INTO PAGO (claveServ, folio, numPago, tipoServ) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_FOLIO.currval, SQ_numPago.nextval, 4);
INSERT INTO CLAVE_SERVICIO (claveServ, conceptoPago) VALUES ( SQ_CLAVE_SERVICIO.currval, 'UNICO');

-- AÑADIMOS UNA CONSULTA
INSERT INTO SERVICIO (claveServ, claveProp, claveMascota,  tipoServ, numPagos) VALUES ( SQ_CLAVE_SERVICIO.nextval, SQ_CLAVEPROPIETARIO.currval, SQ_CLAVE_MASCOTA.currval,1,1);
INSERT INTO CLAVECONSULTA (claveConsulta, claveEmp, diagnostico) VALUES (SQ_CLAVE_CONSULTA.nextval, 5, 'Dolor de pamza');
INSERT INTO CONSULTA (claveServ, CLAVECONSULTA) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_CLAVE_CONSULTA.currval);
INSERT INTO MEDICAMENTOS_CONSULTA (claveConsulta, medicamento) VALUES ( SQ_CLAVE_CONSULTA.currval, 'Paracetamol' );

INSERT INTO RECIBOFOLIO (folio) VALUES ( SQ_FOLIO.nextval);
INSERT INTO RECIBO (folio, claveProp) VALUES (SQ_FOLIO.currval, SQ_CLAVEPROPIETARIO.currval);
INSERT INTO PAGO (claveServ, folio, numPago, tipoServ) VALUES (SQ_CLAVE_SERVICIO.currval, SQ_FOLIO.currval, SQ_numPago.nextval, 1);
INSERT INTO CLAVE_SERVICIO (claveServ, conceptoPago) VALUES ( SQ_CLAVE_SERVICIO.currval, 'UNICO' );
