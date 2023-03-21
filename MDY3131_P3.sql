--CASO 1
DECLARE    
    v_nro_cliente VARCHAR2(2);
    v_run_cliente VARCHAR2(13);
    v_nombre_cliente VARCHAR2(60);
    v_tipo_cliente tipo_cliente.nombre_tipo_cliente%TYPE;
    v_monto_solic_creditos NUMBER(10);
    v_monto_pesos_todosuma NUMBER(10);
    
    TYPE t_clientes IS VARRAY(5) OF NUMBER(8);
    ar_clientes t_clientes:= t_clientes(21242003, 22176845, 18858542, 21300628, 22558061);
    
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE cliente_todosuma';
    FOR l_index IN ar_clientes.FIRST ..ar_clientes.LAST LOOP
        SELECT
            c.nro_cliente,
            TO_CHAR(c.numrun,'99G999G999')||'-'||UPPER(c.dvrun) RUN_CLIENTE,
            UPPER(c.pnombre||' '||c.snombre||' '||c.apmaterno||' '||c.apmaterno) NOMBRE_CLIENTE,
            tc.nombre_tipo_cliente TIPO_CLIENTE,
            SUM(cc.monto_solicitado) MONTO_SOLIC_CREDITOS
                INTO v_nro_cliente, v_run_cliente, v_nombre_cliente, v_tipo_cliente, 
                    v_monto_solic_creditos
        FROM cliente c
            JOIN tipo_cliente tc ON (c.cod_tipo_cliente = tc.cod_tipo_cliente)
            JOIN credito_cliente cc ON (c.nro_cliente = cc.nro_cliente)
                AND EXTRACT(YEAR FROM cc.fecha_otorga_cred) = EXTRACT(YEAR FROM SYSDATE)-1
            WHERE c.numrun = ar_clientes(l_index)
            --WHERE c.numrun = 21242003
            GROUP BY c.nro_cliente, c.numrun, c.dvrun, c.pnombre, c.snombre, c.apmaterno, 
                c.apmaterno,tc.nombre_tipo_cliente
            ORDER BY 5 DESC;
            
            IF v_tipo_cliente = 'Trabajadores independientes' 
                THEN
                    IF v_monto_solic_creditos < 1000000
                        THEN v_monto_pesos_todosuma:= TRUNC(v_monto_solic_creditos/100000)*1300;
                    ELSIF v_monto_solic_creditos BETWEEN 1000001 AND 3000000 
                        THEN v_monto_pesos_todosuma:= TRUNC(v_monto_solic_creditos/100000)*1500;
                    ELSIF v_monto_solic_creditos > 3000000
                        THEN v_monto_pesos_todosuma:= TRUNC(v_monto_solic_creditos/100000)*1750;
                    END IF;
            ELSE v_monto_pesos_todosuma:= TRUNC(v_monto_solic_creditos/100000)*1200;
            END IF;
            
            INSERT INTO cliente_todosuma VALUES(v_nro_cliente, v_run_cliente, v_nombre_cliente, v_tipo_cliente, 
                    v_monto_solic_creditos, v_monto_pesos_todosuma);
                    
            DBMS_OUTPUT.PUT_LINE('v_nro_cliente :'||v_nro_cliente);
            DBMS_OUTPUT.PUT_LINE('v_run_cliente :'||v_run_cliente);
            DBMS_OUTPUT.PUT_LINE('v_nombre_cliente :'||v_nombre_cliente);
            DBMS_OUTPUT.PUT_LINE('v_tipo_cliente :'||v_tipo_cliente);
            DBMS_OUTPUT.PUT_LINE('v_monto_solic_creditos :'||v_monto_solic_creditos);
            DBMS_OUTPUT.PUT_LINE('v_monto_pesos_todosuma :'||v_monto_pesos_todosuma);
            DBMS_OUTPUT.PUT_LINE('**********');
        END LOOP;
    COMMIT;
END;
/

SELECT * FROM cliente_todosuma;

-- CASO 2
DECLARE
    v_nro_cliente cliente.nro_cliente%TYPE;
    v_run_cliente VARCHAR2(13);
    v_nombre_cliente VARCHAR2(60);
    v_profesion_oficio profesion_oficio.nombre_prof_ofic%TYPE;
    --v_dia_cumpleano VARCHAR(20);
    v_dia_cumpleano DATE;
    v_monto_giftcard NUMBER(9);
    v_observacion VARCHAR2(60);
    v_monto_total_ahorrado NUMBER(9);
    
    v_mes_cumpleaños VARCHAR2(2);
    v_mes_bd VARCHAR2(2);
    
    TYPE t_clientes IS VARRAY(5) OF NUMBER;
    arr_clientes t_clientes:= t_clientes(12362093,7455786,6604005,8925537,24617341);
    
BEGIN

    EXECUTE IMMEDIATE 'TRUNCATE TABLE cumpleanno_cliente';
    FOR l_indx IN arr_clientes.FIRST .. arr_clientes.LAST LOOP
        SELECT
             c.nro_cliente,
             TO_CHAR(c.numrun,'99G999G999')||'-'||c.dvrun RUN_CLIENTE,
             c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno NOMBRE_CLIENTE,
             po.nombre_prof_ofic PROFESION_OFICIO,
             --TO_CHAR(c.fecha_nacimiento,'DD " de " Month') DIA_CUMPLEANO,
             c.fecha_nacimiento DIA_CUMPLEANO,
             SUM(pic.monto_total_ahorrado) MONTO_TOTAL_AHORRADO
        INTO v_nro_cliente,
             v_run_cliente,
             v_nombre_cliente,
             v_profesion_oficio,
             v_dia_cumpleano,
             v_monto_total_ahorrado
        FROM cliente c 
             JOIN profesion_oficio po ON (c.cod_prof_ofic = po.cod_prof_ofic)
             LEFT JOIN producto_inversion_cliente pic ON (c.nro_cliente = pic.nro_cliente)
        GROUP BY c.nro_cliente, c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno, po.nombre_prof_ofic, c.fecha_nacimiento
        HAVING c.numrun = arr_clientes(l_indx);
        
        IF v_monto_total_ahorrado BETWEEN 0 AND 900000 THEN v_monto_giftcard:= 0;
            ELSIF v_monto_total_ahorrado BETWEEN 900001 AND 2000000 THEN v_monto_giftcard:= 50000;
            ELSIF v_monto_total_ahorrado BETWEEN 2000001 AND 5000000 THEN v_monto_giftcard:= 100000;
            ELSIF v_monto_total_ahorrado BETWEEN 5000001 AND 8000000 THEN v_monto_giftcard:= 200000;
            ELSIF v_monto_total_ahorrado BETWEEN 8000001 AND 15000000 THEN v_monto_giftcard:= 300000;
        END IF;
            
        v_mes_cumpleaños:= TO_CHAR(v_dia_cumpleano,'MM');
        v_mes_bd:= TO_CHAR(ADD_MONTHS(SYSDATE,1),'MM');
        
        DBMS_OUTPUT.PUT_LINE(arr_clientes(l_indx)||' '||v_mes_cumpleaños||' '||v_mes_bd);
            
        IF v_mes_cumpleaños != v_mes_bd THEN v_observacion:= 'El cliente no está de cumpleaños en el mes procesado';
        ELSE v_observacion:= NULL;
        END IF;
        
        INSERT INTO cumpleanno_cliente
            VALUES(v_nro_cliente,
                   v_run_cliente,
                   v_nombre_cliente,
                   v_profesion_oficio,
                   TO_CHAR(v_dia_cumpleano,'DD " de " Month'),
                   v_monto_giftcard,
                   v_observacion);
    END LOOP;
END;
/

SELECT * FROM cumpleanno_cliente;