-- Borrando las tablas de usuario
-- https://stackoverflow.com/questions/18030140/drop-all-tables-sql-developer/18030453
create or replace procedure sp_dropAllTables
IS
v_numTables NUMBER(10);
BEGIN
    select count(table_name)
    into v_numtables
    from user_tables;

    -- obtenemos
    for tbl in ( select table_name from user_tables ) loop
        EXECUTE IMMEDIATE 'drop table '|| tbl.table_name ||' CASCADE CONSTRAINTS ';
    end loop;

END sp_dropAllTables;
/

exec sp_dropAllTables;


/* ======================================================== */
/* INSERCIÓN DE DATOS */
/* ======================================================== */
DROP SEQUENCE SQ_CLAVEPROPIETARIO;
CREATE SEQUENCE SQ_CLAVEPROPIETARIO
MINVALUE 1
START WITH 1
INCREMENT BY 1;

/* -- CREANDO UN PROPIETARIO -- */
/* No se revisa si el usuario existe previamente debido a que las claves se generan */
/* automaticamente. */
CREATE OR REPLACE procedure SP_addPropietario(
    p_nomProp propietario.nomProp%TYPE,
    p_apPatProp propietario.apPatProp%TYPE,
    p_apMatProp propietario.apMatProp%TYPE,
    p_colProp propietario.colProp%TYPE,
    p_numCalleProp propietario.numCalleProp%TYPE,
    p_calleProp propietario.calleProp%TYPE,
    p_delegProp propietario.delegProp%TYPE,
    p_telefono telefonoprop.telefono%TYPE
)
IS
/* Declaración de variable */
BEGIN
    INSERT INTO PROPIETARIO VALUES (
        SQ_CLAVEPROPIETARIO.NEXTVAL,
        p_nomProp,
        p_apPatProp,
        p_apMatProp,
        p_colProp,
        p_numCalleProp,
        p_calleProp,
        p_delegProp
    );

    INSERT INTO TELEFONOPROP VALUES (
        SQ_CLAVEPROPIETARIO.CURRVAL,
        p_telefono
    );

    DBMS_OUTPUT.PUT_LINE('Se añadio al propietario exitosamente con la clave: '||SQ_CLAVEPROPIETARIO.CURRVAL);
END SP_addPropietario;
/

exec SP_addPropietario('Erik', 'Zárate', 'Bravo', 'Colonia 1', '1', 'Calle 1', 'deleg 1', 5524718650);

DROP SEQUENCE SQ_CLAVE_MASCOTA;
CREATE SEQUENCE SQ_CLAVE_MASCOTA
MINVALUE 1
START WITH 1
INCREMENT BY 1;

/* -- AÑADIR UNA MASCOTA Y RELACIONARLA CON EL PROPIETARIO DADA SU CLVPROP -- */
CREATE OR REPLACE PROCEDURE SP_ADDMASCOTA (
    p_claveProp mascota.claveProp%TYPE,
    p_nomMascota mascota.nomMascota%TYPE,
    p_colorMascota mascota.colorMascota%TYPE,
    p_especieMascota mascota.especieMascota%TYPE,
    p_razaMascota mascota.razaMascota%TYPE,
    p_edadMascota mascota.edadMascota%TYPE
)
IS
BEGIN
    INSERT INTO MASCOTA (
        claveMascota,
        claveProp,
        nomMascota,
        colorMascota,
        especieMascota,
        razaMascota,
        edadMascota
        ) VALUES ( 
        SQ_CLAVE_MASCOTA.NEXTVAL, 
        p_claveProp, 
        p_nomMascota, 
        p_colorMascota, 
        p_especieMascota, 
        p_razaMascota, 
        p_edadMascota
    );

    DBMS_OUTPUT.PUT_LINE('Se agrego la mascota con clave: '||SQ_CLAVE_MASCOTA.CURRVAL);
END SP_ADDMASCOTA;
/
show errors;

exec SP_ADDMASCOTA(1, 'Mesler', 'Cafe', 'Perro', 'Mastin Ingles', 5);


DROP SEQUENCE SQ_CLAVE_SERVICIO;
CREATE SEQUENCE SQ_CLAVE_SERVICIO
MINVALUE 1
START WITH 1
INCREMENT BY 1;

/* -- AÑADIR UN SERVICIO-- */
CREATE OR REPLACE PROCEDURE SP_ADDSERVICIO(
    P_TIPOSERV servicio.tipoServ%TYPE,
    P_DESCRIPCIONSERV servicio.descripcionServ%TYPE,
    P_COSTOSERV servicio.costoServ%TYPE
)
IS
BEGIN
    INSERT INTO SERVICIO VALUES (
        SQ_CLAVE_SERVICIO.NEXTVAL,
        P_TIPOSERV,
        P_DESCRIPCIONSERV,
        P_COSTOSERV
    );

    DBMS_OUTPUT.PUT_LINE('Se creo el servicio con clave: '||SQ_CLAVE_SERVICIO.CURRVAL);
END SP_ADDSERVICIO;
/
show errors;

exec SP_ADDSERVICIO( 1, 'CONSULTA', 500 );

/* -- REGISTRA UN SERVICIO BRINDADO A UNA MASCOTA -- */
CREATE OR REPLACE PROCEDURE SP_MASCOTA_SERVICIO (
    p_claveServ SERVICIO.claveServ%TYPE,
    p_claveMascota MASCOTA.claveMascota%TYPE
)
IS
BEGIN
    INSERT INTO MASCOTA_SERVICIO VALUES (
        p_claveServ,
        p_claveMascota,
        SYSDATE
    );

    DBMS_OUTPUT.PUT_LINE('La mascota con clave '||p_claveMascota ||' contrato el servicio con clave '||p_claveServ);
END SP_MASCOTA_SERVICIO;
/

exec SP_MASCOTA_SERVICIO(1, 1);

/* =========================================== */
/* Borrado de datos */
/* =========================================== */
CREATE OR REPLACE PROCEDURE SP_dropPropietario(
    p_claveProp propietario.claveProp%TYPE
)
IS
BEGIN

    -- borramos el registro del propietario y de forma automatica el registro de
    -- telefonoprop
    DELETE FROM PROPIETARIO
    WHERE CLAVEPROP = P_CLAVEPROP;

    DBMS_OUTPUT.PUT_LINE('Se borro al propietario con clave: '||p_claveProp);
END SP_dropPropietario;
/

CREATE OR REPLACE PROCEDURE SP_DROPMASCOTA (
    P_CLAVEMASCOTA mascota.claveMascota%TYPE
)
IS
BEGIN

    -- Cuando se borra la mascota se borran los servicios que esta recibio
    DELETE FROM MASCOTA
    WHERE CLAVEMASCOTA = P_CLAVEMASCOTA;
    DBMS_OUTPUT.PUT_LINE('Se borro la mascota con clave: '||p_claveMascota);
END SP_DROPMASCOTA;
/

CREATE OR REPLACE PROCEDURE SP_DROP_SERVICIO(
    p_claveServ servicio.claveServ%TYPE
)
IS
BEGIN
    DELETE FROM SERVICIO
    WHERE CLAVESERV = P_CLAVESERV;

    DBMS_OUTPUT.PUT_LINE('Se borro el servicio con clave: '||p_claveServ);

END SP_DROP_SERVICIO;
/

CREATE OR REPLACE PROCEDURE SP_DROP_MASCOTA_SERVICIO(
    P_CLAVESERV MASCOTA_SERVICIO.CLAVESERV%TYPE,
    P_CLAVEMASCOTA MASCOTA_SERVICIO.CLAVEMASCOTA%TYPE
)
IS
BEGIN
    DELETE FROM MASCOTA_SERVICIO
    WHERE (CLAVESERV = P_CLAVESERV AND CLAVEMASCOTA = P_CLAVEMASCOTA);

    DBMS_OUTPUT.PUT_LINE('SE BORRO EL SERVICIO CON CLAVE '||P_CLAVESERV 
        || ' RECIBIDO POR LA MASCOTA CON CLAVE '
        ||P_CLAVEMASCOTA
    );

END SP_DROP_MASCOTA_SERVICIO;
/

/* =========================================== */
/* Actualización de datos */
/* =========================================== */
CREATE OR REPLACE PROCEDURE SP_UPDATE_PROPIETARIO(
    p_claveProp propietario.claveProp%TYPE,
    p_nomProp propietario.nomProp%TYPE,
    p_apPatProp propietario.apPatProp%TYPE,
    p_apMatProp propietario.apMatProp%TYPE,
    p_colProp propietario.colProp%TYPE,
    p_numCalleProp propietario.numCalleProp%TYPE,
    p_calleProp propietario.calleProp%TYPE,
    p_delegProp propietario.delegProp%TYPE,
    p_telefono telefonoprop.telefono%TYPE
)
IS
BEGIN
    update PROPIETARIO
    set nomProp = p_nomProp,
        apPatProp = p_apPatProp,
        apMatProp = p_apMatProp,
        colProp = p_colProp,
        numCalleProp = p_numCalleProp,
        calleProp = p_calleProp,
        delegProp = p_delegProp
    where claveProp = p_claveProp;

    update telefonoprop
    set telefono = p_telefono
    where claveProp = p_claveProp;

    DBMS_OUTPUT.PUT_LINE('Se modifico el propietario con clave '||P_CLAVEPROP);
END SP_UPDATE_PROPIETARIO;
/
