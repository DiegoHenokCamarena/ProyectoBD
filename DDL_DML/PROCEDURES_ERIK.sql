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

DROP SEQUENCE SQ_CLAVE_MASCOTA;
CREATE SEQUENCE SQ_CLAVE_MASCOTA
MINVALUE 1
START WITH 1
INCREMENT BY 1;

DROP SEQUENCE SQ_CLAVE_SERVICIO;
CREATE SEQUENCE SQ_CLAVE_SERVICIO
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

exec SP_ADDMASCOTA(1, 'Mesler', 'Cafe', 'Perro', 'Mastin Ingles', 5);

/* -- AÑADIR UN SERVICIO-- */
/* Cada servicio tiene clave unica */
CREATE OR REPLACE PROCEDURE SP_ADD_SERVICIO(
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
END SP_ADD_SERVICIO;
/

exec SP_ADD_SERVICIO( 1, 'CONSULTA', 500 );

/* -- REGISTRA UN SERVICIO BRINDADO A UNA MASCOTA -- */
CREATE OR REPLACE PROCEDURE SP_ADD_MASCOTA_SERVICIO (
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
END SP_ADD_MASCOTA_SERVICIO;
/

exec SP_ADD_MASCOTA_SERVICIO(1, 1);

/* =========================================== */
/* Borrado de datos */
/* =========================================== */
CREATE OR REPLACE PROCEDURE SP_drop_Propietario(
    p_claveProp propietario.claveProp%TYPE
)
IS
BEGIN
    -- borramos el registro del propietario y de forma automatica el registro de
    -- telefonoprop
    DELETE FROM PROPIETARIO
    WHERE CLAVEPROP = P_CLAVEPROP;

    DBMS_OUTPUT.PUT_LINE('Se borro al propietario con clave: '||p_claveProp);
END SP_drop_Propietario;
/

-- Elimina una mascota dada su clave
CREATE OR REPLACE PROCEDURE SP_DROP_MASCOTA (
    P_CLAVEMASCOTA mascota.claveMascota%TYPE
)
IS
BEGIN
    -- Cuando se borra la mascota se borran los servicios que esta recibio
    DELETE FROM MASCOTA
    WHERE CLAVEMASCOTA = P_CLAVEMASCOTA;
    DBMS_OUTPUT.PUT_LINE('Se borro la mascota con clave: '||p_claveMascota);
END SP_DROP_MASCOTA;
/

-- Elimina un servicio dada su clave
CREATE OR REPLACE PROCEDURE SP_DROP_SERVICIO(
    p_claveServ servicio.claveServ%TYPE
)
IS
    v_claveServ servicio.claveServ%TYPE;
BEGIN
    select claveServ 
    into v_claveServ
    from servicio
    where claveServ = p_claveServ;

    DELETE FROM SERVICIO
    WHERE CLAVESERV = P_CLAVESERV;

    -- borra de forma automatica a la relación entre propietario y mascota
    DBMS_OUTPUT.PUT_LINE('Se borro el servicio con clave: '||p_claveServ);

    EXCEPTION
        when NO_DATA_FOUND then
            DBMS_OUTPUT.PUT_LINE('ERROR: No existe el servicio.');

END SP_DROP_SERVICIO;
/

exec SP_DROP_SERVICIO(3);

-- Elimina la relación entre una mascota y un servicio dadas sus claves
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
-- Procedimiento para cambiar el nombre del propietario
CREATE OR REPLACE PROCEDURE SP_UPD_PROP_NOMBRE(
    p_claveProp propietario.claveProp%TYPE,
    p_nomProp propietario.nomProp%TYPE,
    p_apPatProp propietario.apPatProp%TYPE,
    p_apMatProp propietario.apMatProp%TYPE
)
IS
    v_claveProp propietario.claveProp%TYPE;
BEGIN
    -- Revisamos que exista el propietario
    select claveProp into v_claveProp
    from propietario where claveProp = p_claveProp;

    update PROPIETARIO
    set nomProp = p_nomProp,
        apPatProp = p_apPatProp,
        apMatProp = p_apMatProp
    where claveProp = p_claveProp;

    DBMS_OUTPUT.PUT_LINE('Se cambio el nombre del propietario con clave: '||p_claveProp);

    -- manejo de exepciones
    EXCEPTION
        when NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: No existe el Propietario con clave: '||p_claveProp);

END SP_UPD_PROP_NOMBRE;
/

exec SP_UPD_PROP_NOMBRE(1, 'Manuel', 'Alejandor', 'Bravo');
exec SP_UPD_PROP_NOMBRE(2, 'Manuel', 'Alejandor', 'Bravo');

-- Procedimiento para cambiar la dirección del propietario
CREATE OR REPLACE PROCEDURE SP_UPD_PROP_DIR(
    p_claveProp propietario.claveProp%TYPE,
    p_colProp propietario.colProp%TYPE,
    p_numCalleProp propietario.numCalleProp%TYPE,
    p_calleProp propietario.calleProp%TYPE,
    p_delegProp propietario.delegProp%TYPE
)
IS
    v_claveProp propietario.claveProp%TYPE;
BEGIN
    -- Revisamos que exista el propietario
    select claveProp into v_claveProp
    from propietario where claveProp = p_claveProp;

    update PROPIETARIO
    set 
        colProp = p_colProp,
        numCalleProp = p_numCalleProp,
        calleProp = p_calleProp,
        delegProp = p_delegProp
    where claveProp = p_claveProp;

    DBMS_OUTPUT.PUT_LINE('Se cambio la dirección del propietario con clave: '||p_claveProp);

    -- manejo de exepciones
    EXCEPTION
        when NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: No existe el Propietario con clave: '||p_claveProp);

END SP_UPD_PROP_DIR;
/

exec SP_UPD_PROP_DIR(2, 'Colonia 12', 12, 'Calle 12', 'Deleg 12');

CREATE OR REPLACE PROCEDURE SP_UPD_PROP_TEL(
    p_claveProp TELEFONOPROP.claveProp%TYPE,
    p_telefono TELEFONOPROP.telefono%TYPE
)
IS
    v_claveProp propietario.claveProp%TYPE;
BEGIN
    -- Revisamos que exista el propietario
    SELECT CLAVEPROP INTO V_CLAVEPROP
    FROM PROPIETARIO WHERE CLAVEPROP = P_CLAVEPROP;

    update TELEFONOPROP
    set 
        telefono = p_telefono
    where claveProp = p_claveProp;

    DBMS_OUTPUT.PUT_LINE('Se cambio el telefono del propietario con clave: '||p_claveProp);

    -- manejo de exepciones
    EXCEPTION
        when NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: No existe el Propietario con clave: '||p_claveProp);

END SP_UPD_PROP_TEL;
/

-- Actualiza el tipo de servicio, por consecuente se modifica la descripcionServ y el costo.
CREATE OR REPLACE PROCEDURE SP_UPDATE_SERVICIO(
	P_CLAVESERV SERVICIO.CLAVESERV%TYPE,
	P_TIPOSERV SERVICIO.TIPOSERV%TYPE,
	P_DESCRIPCIONSERV SERVICIO.DESCRIPCIONSERV%TYPE,
	P_COSTOSERV SERVICIO.COSTOSERV%TYPE
)
IS
    v_claveServ servicio.claveServ%TYPE;
BEGIN
    select claveServ into v_claveServ
    from servicio where claveServ = p_claveServ;


	UPDATE SERVICIO
	SET 
		TIPOSERV = P_TIPOSERV,
		DESCRIPCIONSERV = P_DESCRIPCIONSERV,
		COSTOSERV  = P_COSTOSERV
	WHERE CLAVESERV = P_CLAVESERV;

	DBMS_OUTPUT.PUT_LINE('Se modifico el servicio con clave '||p_claveServ);

    EXCEPTION
        when NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: No existe el Servicio con clave: '||p_claveServ);

END SP_UPDATE_SERVICIO;
/

/* TODO: MASCOTA-SERVICIO se puede modificar???  */
