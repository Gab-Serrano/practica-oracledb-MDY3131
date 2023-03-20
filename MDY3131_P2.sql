-- CASO 1
DECLARE
    v_anno_proceso VARCHAR2(4);
    v_numrun_emp empleado.numrun_emp%TYPE;
    v_dvrun_emp empleado.dvrun_emp%TYPE;
    v_nombre_empleado VARCHAR(50);
    v_sueldo_base empleado.sueldo_base%TYPE;
    v_porc_movil_normal NUMBER(2);
    v_valor_movil_normal NUMBER(6);
    v_valor_movil_adic NUMBER(6);
    v_valor_total_movil NUMBER(6);
    
    v_id_comuna NUMBER(3);
    v_numrun_loop v_numrun_emp%TYPE;
    
    TYPE bono_comunas_t IS TABLE OF NUMBER 
        INDEX BY VARCHAR2(3);
    monto_bono bono_comunas_t;
    id_comuna VARCHAR2(3);
    
    TYPE t_empleados IS VARRAY(5) OF NUMBER(8);
    empleados_va t_empleados:= t_empleados(11846972, 12272880, 12113369, 11999100, 12868553);

BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE proy_movilizacion';
    FOR l_index IN 1..5 LOOP
            v_numrun_loop:= empleados_va(l_index);
        
            monto_bono('117'):= 20000;
            monto_bono('118'):= 25000;
            monto_bono('119'):= 30000;
            monto_bono('120'):= 35000;
            monto_bono('121'):= 40000;
            
            SELECT
                EXTRACT(YEAR FROM SYSDATE) ANNO_PROCESO,
                numrun_emp,
                dvrun_emp,
                pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp NOMBRE_EMPLEADO,
                sueldo_base,
                TRUNC(sueldo_base/100000) PORC_MOVIL_NORMAL,
                ROUND(sueldo_base*(TRUNC(sueldo_base/100000)/100),0) VALOR_MOVIL_NORMAL,
                id_comuna
                    INTO v_anno_proceso, v_numrun_emp, v_dvrun_emp, v_nombre_empleado, v_sueldo_base, 
                    v_porc_movil_normal, v_valor_movil_normal, v_id_comuna
            FROM empleado
            WHERE numrun_emp = v_numrun_loop;
            /*
            DBMS_OUTPUT.PUT_LINE(v_anno_proceso);
            DBMS_OUTPUT.PUT_LINE(v_numrun_emp); 
            DBMS_OUTPUT.PUT_LINE(v_dvrun_emp); 
            DBMS_OUTPUT.PUT_LINE(v_nombre_empleado);
            DBMS_OUTPUT.PUT_LINE(v_sueldo_base);
            DBMS_OUTPUT.PUT_LINE(v_porc_movil_normal);
            DBMS_OUTPUT.PUT_LINE(v_valor_movil_normal); 
            DBMS_OUTPUT.PUT_LINE(v_id_comuna);
            DBMS_OUTPUT.PUT_LINE('*******');
            */
            
            id_comuna:= monto_bono.FIRST;
            WHILE id_comuna IS NOT NULL LOOP
                IF v_id_comuna = id_comuna THEN
                    v_valor_movil_adic:= monto_bono(id_comuna);
                    EXIT;
                ELSE
                    v_valor_movil_adic:=0;
                END IF;
                id_comuna:= monto_bono.NEXT(id_comuna);
            END LOOP;

            v_valor_total_movil:= v_valor_movil_normal + v_valor_movil_adic;
            
            DBMS_OUTPUT.PUT_LINE('Año proceso: '||v_anno_proceso);
            DBMS_OUTPUT.PUT_LINE('NumRut: '||v_numrun_emp); 
            DBMS_OUTPUT.PUT_LINE('DV RUT: '||v_dvrun_emp); 
            DBMS_OUTPUT.PUT_LINE('Nombre : '||v_nombre_empleado);
            DBMS_OUTPUT.PUT_LINE('Comuna : '||v_id_comuna);
            DBMS_OUTPUT.PUT_LINE('Sueldo base: '||v_sueldo_base);
            DBMS_OUTPUT.PUT_LINE('Porcentaje mov normal: '||v_porc_movil_normal);
            DBMS_OUTPUT.PUT_LINE('Valor Movil Normal: '||v_valor_movil_normal); 
            DBMS_OUTPUT.PUT_LINE('Valor movil adicional: '||v_valor_movil_adic);
            DBMS_OUTPUT.PUT_LINE('Valor movil TOTAL: '||v_valor_total_movil);
            DBMS_OUTPUT.PUT_LINE('*******');
            
            INSERT INTO proy_movilizacion VALUES(v_anno_proceso, v_numrun_emp, v_dvrun_emp, v_nombre_empleado,
                        v_sueldo_base, v_porc_movil_normal, v_valor_movil_normal,
                        v_valor_movil_adic, v_valor_total_movil);
    END LOOP;
    
END;
/

SELECT * FROM proy_movilizacion;

-- CASO 2
DECLARE
    v_mes_anno VARCHAR2(6);
    v_numrun_emp empleado.numrun_emp%TYPE;
    v_dvrun_emp empleado.dvrun_emp%TYPE;
    v_nombre_empleado VARCHAR(60);
    v_numbre_usuario VARCHAR(9);
    v_clave_usuario VARCHAR(20);
    
    TYPE t_empleados IS VARRAY(5) OF NUMBER(8);
    ar_empleados t_empleados:= t_empleados(12648200, 12260812, 12456905, 11649964, 12642309); 
BEGIN
    EXECUTE IMMEDIATE'TRUNCATE TABLE usuario_clave';
    FOR l_index IN ar_empleados.FIRST ..ar_empleados.LAST LOOP
        SELECT
            TO_CHAR(SYSDATE,'MM')||EXTRACT(YEAR FROM SYSDATE) MES_ANNO,
            numrun_emp,
            dvrun_emp,
            pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp NOMBRE_EMPLEADO,
            SUBSTR(pnombre_emp,0,3)||LENGTH(pnombre_emp)||'*'||SUBSTR(sueldo_base,-1)||dvrun_emp
                ||ROUND(MONTHS_BETWEEN(SYSDATE,fecha_contrato)/12)||
                CASE WHEN ROUND(MONTHS_BETWEEN(SYSDATE,fecha_contrato)/12) < 10 THEN 'X' END NUMBRE_USUARIO,
            SUBSTR(numrun_emp,3,1)||EXTRACT(YEAR FROM fecha_nac)+2||SUBSTR((sueldo_base-1),-3)||
                LOWER(CASE 
                    WHEN id_estado_civil IN (10, 60) THEN SUBSTR(appaterno_emp,0,2)
                    WHEN id_estado_civil IN (20, 30) THEN SUBSTR(appaterno_emp,0,1)||SUBSTR(appaterno_emp,-1)
                    WHEN id_estado_civil = 40 THEN SUBSTR(appaterno_emp,-3,2)
                    WHEN id_estado_civil = 50 THEN SUBSTR(appaterno_emp,-2)
                END)||
                TO_CHAR(SYSDATE,'MM')||EXTRACT(YEAR FROM SYSDATE)||SUBSTR(c.nombre_comuna,0,1) CLAVE_USUARIO
            INTO v_mes_anno, v_numrun_emp, v_dvrun_emp, v_nombre_empleado, v_numbre_usuario, v_clave_usuario
        FROM empleado JOIN comuna c ON empleado.id_comuna = c.id_comuna
        WHERE numrun_emp = ar_empleados(l_index)
        ORDER BY empleado.appaterno_emp;
        DBMS_OUTPUT.PUT_LINE('v_mes_anno :'||v_mes_anno);
        DBMS_OUTPUT.PUT_LINE('v_numrun_emp :'||v_numrun_emp);
        DBMS_OUTPUT.PUT_LINE('v_dvrun_emp :'||v_dvrun_emp);
        DBMS_OUTPUT.PUT_LINE('v_nombre_empleado :'||v_nombre_empleado);
        DBMS_OUTPUT.PUT_LINE('v_numbre_usuario :'||v_numbre_usuario);
        DBMS_OUTPUT.PUT_LINE('v_clave_usuario :'||v_clave_usuario);
        DBMS_OUTPUT.PUT_LINE('**********');
        
        INSERT INTO usuario_clave VALUES(v_mes_anno, v_numrun_emp, v_dvrun_emp, v_nombre_empleado, v_numbre_usuario, v_clave_usuario);
    END LOOP;
END;
/
SELECT * FROM usuario_clave;

-- CASO 3
VAR b_porc_rebaja NUMBER;
EXEC :b_porc_rebaja:= 22.5;

DECLARE
    v_anno_proceso VARCHAR(4);
    v_nro_patente camion.nro_patente%TYPE;
    v_valor_arriendo_dia camion.valor_arriendo_dia%TYPE;
    v_valor_garantia_dia camion.valor_garantia_dia%TYPE;
    v_total_veces_arrendado NUMBER(3);
    
    TYPE t_patentes IS VARRAY(5) OF VARCHAR2(6);
    arr_patentes t_patentes:= t_patentes('AHEW11', 'ASEZ11', 'BC1002', 'BT1002', 'VR1003');

BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE hist_arriendo_anual_camion';
    
    FOR l_index IN arr_patentes.FIRST ..arr_patentes.LAST LOOP
        SELECT
            EXTRACT(YEAR FROM SYSDATE)-1 ANNO_PROCESO,
            c.nro_patente,
            c.valor_arriendo_dia,
            c.valor_garantia_dia,
            COUNT(ac.nro_patente) TOTAL_VECES_ARRENDADO
                INTO v_anno_proceso, v_nro_patente, v_valor_arriendo_dia, v_valor_garantia_dia, v_total_veces_arrendado
        FROM camion c 
            LEFT JOIN arriendo_camion ac ON (c.nro_patente = ac.nro_patente)
            AND EXTRACT(YEAR FROM ac.fecha_ini_arriendo) = EXTRACT(YEAR FROM SYSDATE)-1
        GROUP BY c.nro_patente, c.valor_arriendo_dia, c.valor_garantia_dia
            HAVING c.nro_patente = arr_patentes(l_index)
        ORDER BY 2;
        
        INSERT INTO hist_arriendo_anual_camion 
            VALUES(v_anno_proceso,
                    v_nro_patente,
                    v_valor_arriendo_dia,
                    v_valor_garantia_dia,
                    v_total_veces_arrendado);
        COMMIT;
        
        UPDATE camion
            SET valor_arriendo_dia = ROUND(valor_arriendo_dia * (1-(:b_porc_rebaja/100)),0),
                valor_garantia_dia = ROUND(valor_garantia_dia * (1-(:b_porc_rebaja/100)),0)
            --SET valor_arriendo_dia = Trunc(valor_arriendo_dia / (1-(:b_porc_rebaja/100)),0),
              --  valor_garantia_dia = trunc(valor_garantia_dia / (1-(:b_porc_rebaja/100)),0)
            WHERE nro_patente = arr_patentes(l_index) AND (SELECT COUNT(ac.nro_patente)
                                                           FROM camion c 
                                                                LEFT JOIN arriendo_camion ac ON (c.nro_patente = ac.nro_patente)
                                                                AND EXTRACT(YEAR FROM ac.fecha_ini_arriendo) = EXTRACT(YEAR FROM SYSDATE)-1
                                                                GROUP BY c.nro_patente
                                                                HAVING c.nro_patente = arr_patentes(l_index)) <5;
        COMMIT;
    END LOOP;
END;
/

SELECT * FROM hist_arriendo_anual_camion;
SELECT * FROM camion WHERE nro_patente IN ('AHEW11', 'ASEZ11', 'BC1002', 'BT1002', 'VR1003');

--CASO 4
VAR b_monto_multa NUMBER;
EXEC :b_monto_multa:= 25000;

DECLARE
    v_anno_mes_proceso VARCHAR2(6);
    v_nro_patente camion.nro_patente%TYPE;
    v_fecha_ini_arriendo VARCHAR2(10);
    v_dias_solicitados arriendo_camion.dias_solicitados%TYPE;
    v_fecha_devolucion VARCHAR2(10);
    v_dias_atraso NUMBER(3);
    v_valor_multa NUMBER(8);
    
    TYPE t_nro_patentes IS VARRAY(5) OF VARCHAR(6);
    arr_nro_patentes t_nro_patentes:= t_nro_patentes('AA1001', 'AHEW11', 'ASEZ11', 'BT1002', 'VR1003');

BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE multa_arriendo';
    
    FOR l_index IN arr_nro_patentes.FIRST .. arr_nro_patentes.LAST LOOP
        SELECT
            TO_CHAR(SYSDATE,'MMYYYY') ANNO_MES_PROCESO,
            c.nro_patente,
            TO_CHAR(ac.fecha_ini_arriendo,'DD/MM/YYYY') FECHA_INI_ARRIENDO,
            ac.dias_solicitados,
            TO_CHAR(ac.fecha_devolucion,'DD/MM/YYYY') FECHA_DEVOLUCION
                INTO v_anno_mes_proceso, v_nro_patente, v_fecha_ini_arriendo, v_dias_solicitados, v_fecha_devolucion
        FROM camion c
            JOIN arriendo_camion ac ON (c.nro_patente = ac.nro_patente)
        WHERE EXTRACT(MONTH FROM ac.fecha_ini_arriendo)||EXTRACT(YEAR FROM ac.fecha_ini_arriendo) 
                        = (EXTRACT(MONTH FROM SYSDATE)-1)||EXTRACT(YEAR FROM SYSDATE)
                AND ac.fecha_devolucion - (ac.fecha_ini_arriendo + ac.dias_solicitados) > 0
                AND c.nro_patente = arr_nro_patentes(l_index)
        ORDER BY 2;
        
        v_dias_atraso:= TO_DATE(v_fecha_devolucion,'DD/MM/YYYY') - (TO_DATE(v_fecha_ini_arriendo,'DD/MM/YYYY') + v_dias_solicitados);
        v_valor_multa:= v_dias_atraso * :b_monto_multa;
        
        DBMS_OUTPUT.PUT_LINE('v_anno_mes_proceso :'||v_anno_mes_proceso);
        DBMS_OUTPUT.PUT_LINE('v_nro_patente :'||v_nro_patente);
        DBMS_OUTPUT.PUT_LINE('v_fecha_ini_arriendo :'||v_fecha_ini_arriendo);
        DBMS_OUTPUT.PUT_LINE('v_fecha_devolucion :'||v_fecha_devolucion);
        DBMS_OUTPUT.PUT_LINE('v_dias_atraso :'||v_dias_atraso);
        DBMS_OUTPUT.PUT_LINE('v_valor_multa :'||v_valor_multa);
        DBMS_OUTPUT.PUT_LINE('**********');
        
        INSERT INTO multa_arriendo
            VALUES(v_anno_mes_proceso, v_nro_patente, v_fecha_ini_arriendo, v_dias_solicitados, v_fecha_devolucion, v_dias_atraso, v_valor_multa);
        
        COMMIT;
        
    END LOOP;
END;
/