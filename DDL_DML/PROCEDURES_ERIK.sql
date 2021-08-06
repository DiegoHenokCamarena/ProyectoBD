DROP SEQUENCE SQ_CLAVEPROPIETARIO;
CREATE SEQUENCE SQ_CLAVEPROPIETARIO
MINVALUE 1
START WITH 1
INCREMENT BY 1;

/* -- CREANDO UN PROPIETARIO -- */
CREATE OR REPLACE SP_addPropietario(
    p_nomProp propietario.nomProp%TYPE,
    p_apPatProp propietario.apPatProp%TYPE,
    p_apMatProp propietario.apMatProp%TYPE,
    p_colProp propietario.colProp%TYPE,
    p_numCalleProp propietario.numCalleProp%TYPE,
    p_calleProp propietario.calleProp%TYPE,
    p_delegProp propietario.delegProp%TYPE
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

    DBMS_OUTPUT.PUT_LINE(
        'Se añadio al propietario exitosamente con la clave: '||SQ_CLAVEPROPIETARIO.CURRVAL
    );
END SP_addPropietario;
/

DROP SEQUENCE SQ_CLAVE_MASCOTA;
CREATE SEQUENCE SQ_CLAVE_MASCOTA
MINVALUE 1
START WITH 1
INCREMENT BY 1;

/* -- AÑADIR UNA MASCOTA Y RELACIONARLA CON EL PROPIETARIO DADA SU CLVPROP -- */
CREATE OR REPLACE PROCEDURE sP_ADDMASCOTA(
    p_claveProp propietario.claveProp%TYPE,
    p_nomMascota mascota.nomMascota%TYPE,
    p_colorMascota mascota.colorMascota%TYPE,
    p_especieMascota mascota.especieMascota%TYPE,
    p_razaMascota mascota.razaMascota%TYPE,
    p_edadMascota mascota.edadMascota%TYPE
)
IS
BEGIN
    INSERT INTO MASCOTA VALUES ( 
        SQ_CLAVE_MASCOTA.NEXTVAL,
        v_claveProp,
        v_nomMascota,
        v_colorMascota,
        v_especieMascota,
        v_razaMascota,
        v_edadMascota
    );
END SP_ADDMASCOTA;
/

DROP SEQUENCE SQ_CLAVE_SERVICIO;
CREATE SEQUENCE SQ_CLAVE_SERVICIO
MINVALUE 1
START WITH 1
INCREMENT BY 1;

/* -- AÑADIR UN SERVICIO-- */
CREATE OR REPLACE SP_ADDSERVICIO(
    P_TIPOSERV,
    P_DESCRIPCIÓNSERV,
    P_COSTOSERV
)
IS
BEGIN
    INSERT INTO SERVICIO VALUES (
        SQ_CLAVE_SERVICIO.NEXTVAL,
        P_TIPOSERV,
        P_DESCRIPCIONSERV,
        P_COSTOSERV
    );
END SP_ADDSERVICIO;
/

/* -- REGISTRA UN SERVICIO BRINDADO A UNA MASCOTA -- */
CREATE OR REPLACE SP_MASCOTA_SERVICIO (
    p_claveServ SERVICIO.claveServ%TYPE,
    p_claveMascota MASCOTA.claveMascota%TYPE
)
IS
BEGIN
    insert into MASCOTA_SERVICIO VALUES (
        p_claveServ,
        p_claveMascota,
        SYSDATE
    );
END SP_MASCOTA_SERVICIO;
/
