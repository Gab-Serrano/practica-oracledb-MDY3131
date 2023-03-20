SET SERVEROUTPUT ON 
-- Caso 1
VAR b_bonificacion NUMBER;
VAR b_nombre_empleado VARCHAR2;
EXEC :b_bonificacion:= 40;
EXEC :b_nombre_empleado:= 'MARCO OGAZ VARAS';

DECLARE
    v_nom_emp VARCHAR2(40);
    v_run_emp VARCHAR2(10);
    v_sueldo empleado.sueldo_emp%TYPE;
    v_sueldo_bonif empleado.sueldo_emp%TYPE;
BEGIN
    SELECT nombre_emp||' '||appaterno_emp||' '||apmaterno_emp,
            numrut_emp||'-'||dvrut_emp,
            sueldo_emp,
            sueldo_emp*(:b_bonificacion/100)
        INTO v_nom_emp, v_run_emp, v_sueldo, v_sueldo_bonif
    FROM empleado
    WHERE nombre_emp||' '||appaterno_emp||' '||apmaterno_emp = :b_nombre_empleado;
    
    DBMS_OUTPUT.PUT_LINE('DATOS CALCULO BONIFICACION EXTRA DEL '||:b_bonificacion||'% DEL SUELDO');
    DBMS_OUTPUT.PUT_LINE('Nombre Empleado: '||v_nom_emp);
    DBMS_OUTPUT.PUT_LINE('RUN: '||v_run_emp);
    DBMS_OUTPUT.PUT_LINE('Sueldo: '||v_sueldo);
    DBMS_OUTPUT.PUT_LINE('Bomnificación extra: '||v_sueldo_bonif);
END;



--CASO 2
DESC cliente;
DESC estado_civil;

VAR b_numrut number;
EXEC :b_numrut:= 12487147;

DECLARE
    v_nom_cli VARCHAR2(40);
    v_run_cli VARCHAR2(10);
    v_estado_civil estado_civil.desc_estcivil%TYPE;
    v_renta VARCHAR2(12);
    
BEGIN
    SELECT c.nombre_cli||' '||c.appaterno_cli||' '||c.apmaterno_cli,
            c.numrut_cli||'-'||c.dvrut_cli,
            e.desc_estcivil,
            TO_CHAR(c.renta_cli,'$9G999G999')
        INTO v_nom_cli, v_run_cli, v_estado_civil, v_renta
    FROM cliente c JOIN estado_civil e USING (id_estcivil)
    WHERE c.numrut_cli = :b_numrut;
    
    DBMS_OUTPUT.PUT_LINE('DATOS DEL CLIENTE');
    DBMS_OUTPUT.PUT_LINE('-------------------------');
    DBMS_OUTPUT.PUT_LINE('Nombre: '||v_nom_cli);
    DBMS_OUTPUT.PUT_LINE('RUN: '||v_run_cli);
    DBMS_OUTPUT.PUT_LINE('Estado Civil: '||v_estado_civil);
    DBMS_OUTPUT.PUT_LINE('Renta: '||v_renta);
END;

DESC empleado;

--CASO 3
VAR b_numrut NUMBER;
VAR b_simulacion_1 NUMBER;
VAR b_simulacion_2 NUMBER;
VAR b_rango_1 NUMBER;
var b_rango_2 NUMBER;
EXEC :b_numrut:= 12260812;
EXEC :b_simulacion_1:= 8.5;
EXEC :b_simulacion_2:= 20;
EXEC :b_rango_1:= 200000;
EXEC :b_rango_2:= 400000;

DECLARE
    v_nom_emp VARCHAR2(40);
    v_run_emp VARCHAR2(10);
    v_sueldo_emp empleado.sueldo_emp%TYPE;
    v_sueldo_reajustado_1 empleado.sueldo_emp%TYPE;
    v_sueldo_reajustado_2 empleado.sueldo_emp%TYPE;
    v_reajuste_1 empleado.sueldo_emp%TYPE;
    v_reajuste_2 empleado.sueldo_emp%TYPE;
    
BEGIN
    SELECT nombre_emp||' '||appaterno_emp||' '||apmaterno_emp,
            numrut_emp||'-'||dvrut_emp,
            sueldo_emp,
            sueldo_emp+(sueldo_emp*(:b_simulacion_1/100)),
            sueldo_emp*(:b_simulacion_1/100)
        INTO v_nom_emp, v_run_emp, v_sueldo_emp, v_sueldo_reajustado_1, v_reajuste_1
    FROM empleado
    WHERE numrut_emp = :b_numrut;
    
    DBMS_OUTPUT.PUT_LINE('NOMBRE DEL EMPLEADO: '||v_nom_emp);
    DBMS_OUTPUT.PUT_LINE('RUN: '||v_run_emp);
    DBMS_OUTPUT.PUT_LINE('SIMULACION 1: Aumentar en '||:b_simulacion_1||'% el salario de todos los empleados');
    DBMS_OUTPUT.PUT_LINE('Sueldo actual: '||v_sueldo_emp);
    DBMS_OUTPUT.PUT_LINE('Sueldo reajustado: '||v_sueldo_reajustado_1);
    DBMS_OUTPUT.PUT_LINE('Reajuste: '||v_reajuste_1);
    
    SELECT nombre_emp||' '||appaterno_emp||' '||apmaterno_emp,
            numrut_emp||'-'||dvrut_emp,
            sueldo_emp,
            sueldo_emp+(sueldo_emp*(:b_simulacion_2/100)),
            sueldo_emp*(:b_simulacion_2/100)
        INTO v_nom_emp, v_run_emp, v_sueldo_emp, v_sueldo_reajustado_2, v_reajuste_2
    FROM empleado
    WHERE numrut_emp = :b_numrut AND sueldo_emp BETWEEN :b_rango_1 AND :b_rango_2;
    DBMS_OUTPUT.PUT_LINE('SIMULACIÓN 2: Aumentar en '||:b_simulacion_2||'% el salario de los empleados que poseen salarios entre ');
    DBMS_OUTPUT.PUT_LINE('Sueldo actual: '||v_sueldo_emp);
    DBMS_OUTPUT.PUT_LINE('Sueldo reajustado: '||v_sueldo_reajustado_2);
    DBMS_OUTPUT.PUT_LINE('Reajuste: '||v_reajuste_2);
END;

-- CASO 4

DECLARE
    v_desc_tipo_propiedad tipo_propiedad.desc_tipo_propiedad%TYPE;
    v_total_propiedades NUMBER(2);
    v_valor_arriendo VARCHAR2(12);
    v_id_tipo_propiedad tipo_propiedad.id_tipo_propiedad%TYPE;
    
    CURSOR c_tipo_propiedad IS SELECT id_tipo_propiedad FROM tipo_propiedad;
    
BEGIN
    OPEN c_tipo_propiedad;
    LOOP
        FETCH c_tipo_propiedad INTO v_id_tipo_propiedad;
        EXIT WHEN c_tipo_propiedad%NOTFOUND;
    SELECT tp.desc_tipo_propiedad, COUNT(tp.desc_tipo_propiedad), TO_CHAR(SUM(p.valor_arriendo),'$99G999G999')
        INTO v_desc_tipo_propiedad, v_total_propiedades, v_valor_arriendo
    FROM propiedad p JOIN tipo_propiedad tp 
    ON p.id_tipo_propiedad = tp.id_tipo_propiedad AND tp.id_tipo_propiedad = v_id_tipo_propiedad
    GROUP BY desc_tipo_propiedad;
    
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '||v_desc_tipo_propiedad);
    DBMS_OUTPUT.PUT_LINE('Total de propiedades: '||v_total_propiedades);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '||v_valor_arriendo);
    DBMS_OUTPUT.PUT_LINE('');
    
    END LOOP;
END;