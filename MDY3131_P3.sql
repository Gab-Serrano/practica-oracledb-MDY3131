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