drop table destino cascade constraints;
drop table historico_localizacao cascade constraints;
drop table navio cascade constraints;
drop table operacao_lastro cascade constraints;
drop table tipo_navio cascade constraints;
drop table tipo_operacao cascade constraints;

CREATE TABLE destino (
    id_porto  NUMBER NOT NULL,
    nome      VARCHAR2(30),
    latitude  NUMBER,
    longitude NUMBER
);

ALTER TABLE destino ADD CONSTRAINT destino_pk PRIMARY KEY ( id_porto );

CREATE TABLE historico_localizacao (
    id_historico                NUMBER NOT NULL,
    historico_timestamp         TIMESTAMP WITH LOCAL TIME ZONE,
    operacao_lastro_id_operacao NUMBER NOT NULL,
    operecao_timestamp          TIMESTAMP WITH LOCAL TIME ZONE,
    id_navio                    NUMBER NOT NULL,
    quantidade_agua             NUMBER,
    id_tipooperacao             NUMBER NOT NULL,
    id_porto                    NUMBER NOT NULL,
    latitude                    NUMBER,
    longitude                   NUMBER
);

ALTER TABLE historico_localizacao ADD CONSTRAINT historico_localizacao_pk PRIMARY KEY ( id_historico );

CREATE TABLE navio (
    id_navio                NUMBER NOT NULL,
    nome                    VARCHAR2(30),
    capacidade_lastro       NUMBER,
    tipo_navio_id_tiponavio NUMBER NOT NULL
);

ALTER TABLE navio ADD CONSTRAINT navio_pk PRIMARY KEY ( id_navio );

CREATE TABLE operacao_lastro (
    id_operacao                   NUMBER NOT NULL,
    quantidade_agua               NUMBER,
    operecao_timestamp            TIMESTAMP WITH LOCAL TIME ZONE,
    navio_id_navio                NUMBER NOT NULL,
    tipo_operacao_id_tipooperacao NUMBER NOT NULL,
    destino_id_porto              NUMBER NOT NULL,
    latitude                      NUMBER,
    longitude                     NUMBER
);

CREATE UNIQUE INDEX operacao_lastro__idx ON
    operacao_lastro (
        destino_id_porto
    ASC );

ALTER TABLE operacao_lastro ADD CONSTRAINT operacao_lastro_pk PRIMARY KEY ( id_operacao );

CREATE TABLE tipo_navio (
    id_tiponavio NUMBER NOT NULL,
    tiponome     VARCHAR2(30)
);

ALTER TABLE tipo_navio ADD CONSTRAINT tipo_navio_pk PRIMARY KEY ( id_tiponavio );

CREATE TABLE tipo_operacao (
    id_tipooperacao NUMBER NOT NULL,
    nomeoperacao    VARCHAR2(30) 
);

ALTER TABLE tipo_operacao ADD CONSTRAINT tipo_operacao_pk PRIMARY KEY ( id_tipooperacao );


ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_operacao_lastro_fk FOREIGN KEY ( operacao_lastro_id_operacao )
        REFERENCES operacao_lastro ( id_operacao );

ALTER TABLE navio
    ADD CONSTRAINT navio_tipo_navio_fk FOREIGN KEY ( tipo_navio_id_tiponavio )
        REFERENCES tipo_navio ( id_tiponavio );

ALTER TABLE operacao_lastro
    ADD CONSTRAINT operacao_lastro_destino_fk FOREIGN KEY ( destino_id_porto )
        REFERENCES destino ( id_porto );

ALTER TABLE operacao_lastro
    ADD CONSTRAINT operacao_lastro_navio_fk FOREIGN KEY ( navio_id_navio )
        REFERENCES navio ( id_navio );


ALTER TABLE operacao_lastro
    ADD CONSTRAINT operacao_lastro_tipo_operacao_fk FOREIGN KEY ( tipo_operacao_id_tipooperacao )
        REFERENCES tipo_operacao ( id_tipooperacao );
                                     
-------------------------------------------------  
commit;


CREATE OR REPLACE PROCEDURE manage_tipo_navio (
    p_operation IN VARCHAR2,
    p_id_tiponavio IN NUMBER,
    p_tiponome IN VARCHAR2
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new tipo_navio
        INSERT INTO tipo_navio (id_tiponavio, tiponome)
        VALUES (p_id_tiponavio, p_tiponome);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing tipo_navio
        UPDATE tipo_navio
        SET tiponome = p_tiponome
        WHERE id_tiponavio = p_id_tiponavio;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_tiponavio não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a tipo_navio
        DELETE FROM tipo_navio
        WHERE id_tiponavio = p_id_tiponavio;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_tiponavio não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            INSERT INTO log_erros (codigo_erro, mensagem_erro, data_ocorrencia, usuario)
            VALUES (-20001, 'Erro ao manipular a tabela tipo_navio', SYSDATE, USER);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Evita loop de exceções caso a inserção no log falhe
        END;
        ROLLBACK;
        RAISE;
END manage_tipo_navio;
/
EXEC manage_tipo_navio('INSERT', 1, 'Navio de Carga');
EXEC manage_tipo_navio('UPDATE', 1, 'Navio de Passageiros');
EXEC manage_tipo_navio('DELETE', 1, NULL);


CREATE OR REPLACE PROCEDURE manage_tipo_operacao (
    p_operation IN VARCHAR2,
    p_id_tipooperacao IN NUMBER,
    p_nomeoperacao IN VARCHAR2
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new tipo_operacao
        INSERT INTO tipo_operacao (id_tipooperacao, nomeoperacao)
        VALUES (p_id_tipooperacao, p_nomeoperacao);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing tipo_operacao
        UPDATE tipo_operacao
        SET nomeoperacao = p_nomeoperacao
        WHERE id_tipooperacao = p_id_tipooperacao;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_tipooperacao não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a tipo_operacao
        DELETE FROM tipo_operacao
        WHERE id_tipooperacao = p_id_tipooperacao;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_tipooperacao não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            INSERT INTO log_erros (codigo_erro, mensagem_erro, data_ocorrencia, usuario)
            VALUES (-20001, 'Erro ao manipular a tabela tipo_operacao', SYSDATE, USER);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Evita loop de exceções caso a inserção no log falhe
        END;
        ROLLBACK;
        RAISE;
END manage_tipo_operacao;
/
EXEC manage_tipo_operacao('INSERT', 1, 'Operação de Carga');
EXEC manage_tipo_operacao('UPDATE', 1, 'Operação de Descarga');
EXEC manage_tipo_operacao('DELETE', 1, NULL);


CREATE OR REPLACE PROCEDURE manage_destino (
    p_operation IN VARCHAR2,
    p_id_porto IN NUMBER,
    p_nome VARCHAR2 DEFAULT NULL,
    p_latitude NUMBER DEFAULT NULL,
    p_longitude NUMBER DEFAULT NULL
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new destino
        INSERT INTO destino (id_porto, nome, latitude, longitude)
        VALUES (p_id_porto, p_nome, p_latitude, p_longitude);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing destino
        UPDATE destino
        SET nome = p_nome,
            latitude = p_latitude,
            longitude = p_longitude
        WHERE id_porto = p_id_porto;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21003, 'Id_porto não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a destino
        DELETE FROM destino
        WHERE id_porto = p_id_porto;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_porto não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            INSERT INTO log_erros (codigo_erro, mensagem_erro, data_ocorrencia, usuario)
            VALUES (-20001, 'Erro ao manipular a tabela destino', SYSDATE, USER);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Evita loop de exceções caso a inserção no log falhe
        END;
        ROLLBACK;
        RAISE;
END manage_destino;
/

EXEC manage_destino('INSERT', 1, 'Porto A', 100, 200);
EXEC manage_destino('UPDATE', 1, 'Porto B', 110, 210);
EXEC manage_destino('DELETE', 1);

CREATE OR REPLACE PROCEDURE manage_navio (
    p_operation IN VARCHAR2,
    p_id_navio IN NUMBER,
    p_nome VARCHAR2,
    p_capacidade_lastro IN NUMBER,
    p_tipo_navio_id_tiponavio IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new navio
        INSERT INTO navio (id_navio, nome, capacidade_lastro, tipo_navio_id_tiponavio)
        VALUES (p_id_navio, p_nome, p_capacidade_lastro, p_tipo_navio_id_tiponavio);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing navio
        UPDATE navio
        SET nome = p_nome,
            capacidade_lastro = p_capacidade_lastro,
            tipo_navio_id_tiponavio = p_tipo_navio_id_tiponavio
        WHERE id_navio = p_id_navio;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_navio não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a navio
        DELETE FROM navio
        WHERE id_navio = p_id_navio;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_navio não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            INSERT INTO log_erros (codigo_erro, mensagem_erro, data_ocorrencia, usuario)
            VALUES (-20001, 'Erro ao manipular a tabela navio', SYSDATE, USER);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Evita loop de exceções caso a inserção no log falhe
        END;
        ROLLBACK;
        RAISE;
END manage_navio;
/
EXEC manage_navio('INSERT', 1, 'Navio A', 5000, 1);
EXEC manage_navio('UPDATE', 1, 'Navio B', 6000, 1);
EXEC manage_navio('DELETE', 1, NULL, NULL, NULL);



CREATE OR REPLACE PROCEDURE manage_operacao_lastro (
    p_operation IN VARCHAR2,
    p_id_operacao IN NUMBER,
    p_quantidade_agua IN NUMBER,
    p_operecao_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_navio_id_navio IN NUMBER,
    p_tipo_operacao_id_tipooperacao IN NUMBER,
    p_destino_id_porto IN NUMBER,
    p_latitude IN NUMBER,
    p_longitude IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new operacao_lastro
        INSERT INTO operacao_lastro (id_operacao, quantidade_agua, operecao_timestamp, navio_id_navio, tipo_operacao_id_tipooperacao, destino_id_porto, latitude, longitude)
        VALUES (p_id_operacao, p_quantidade_agua, p_operecao_timestamp, p_navio_id_navio, p_tipo_operacao_id_tipooperacao, p_destino_id_porto, p_latitude, p_longitude);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing operacao_lastro
        UPDATE operacao_lastro
        SET quantidade_agua = p_quantidade_agua,
            operecao_timestamp = p_operecao_timestamp,
            navio_id_navio = p_navio_id_navio,
            tipo_operacao_id_tipooperacao = p_tipo_operacao_id_tipooperacao,
            destino_id_porto = p_destino_id_porto,
            latitude = p_latitude,
            longitude = p_longitude
        WHERE id_operacao = p_id_operacao;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21003, 'Id_operacao não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete an operacao_lastro
        DELETE FROM operacao_lastro
        WHERE id_operacao = p_id_operacao;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_operacao não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-21007, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END manage_operacao_lastro;
/

EXEC manage_operacao_lastro('INSERT', 1, 1000, SYSTIMESTAMP, 1, 1, 1, 450, 120);
EXEC manage_operacao_lastro('UPDATE', 1, 2000, SYSTIMESTAMP, 1, 1, 1, 460, 130);
EXEC manage_operacao_lastro('DELETE', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


CREATE OR REPLACE PROCEDURE manage_historico_localizacao (
    p_operation IN VARCHAR2,
    p_id_historico IN NUMBER,
    p_historico_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_operacao_lastro_id_operacao IN NUMBER,
    p_operecao_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_id_navio IN NUMBER,
    p_quantidade_agua IN NUMBER,
    p_id_tipooperacao IN NUMBER,
    p_id_porto IN NUMBER,
    p_latitude IN NUMBER,
    p_longitude IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new historico_localizacao
        INSERT INTO historico_localizacao (id_historico, historico_timestamp, operacao_lastro_id_operacao, operecao_timestamp, id_navio, quantidade_agua, id_tipooperacao, id_porto, latitude, longitude)
        VALUES (p_id_historico, p_historico_timestamp, p_operacao_lastro_id_operacao, p_operecao_timestamp, p_id_navio, p_quantidade_agua, p_id_tipooperacao, p_id_porto, p_latitude, p_longitude);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing historico_localizacao
        UPDATE historico_localizacao
        SET historico_timestamp = p_historico_timestamp,
            operacao_lastro_id_operacao = p_operacao_lastro_id_operacao,
            operecao_timestamp = p_operecao_timestamp,
            id_navio = p_id_navio,
            quantidade_agua = p_quantidade_agua,
            id_tipooperacao = p_id_tipooperacao,
            id_porto = p_id_porto,
            latitude = p_latitude,
            longitude = p_longitude
        WHERE id_historico = p_id_historico;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21003, 'Id_historico não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a historico_localizacao
        DELETE FROM historico_localizacao
        WHERE id_historico = p_id_historico;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_historico não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-21007, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END manage_historico_localizacao;
/
EXEC manage_historico_localizacao('INSERT', 1, SYSTIMESTAMP, 1, SYSTIMESTAMP, 1, 500, 1, 1, 450, 120);
EXEC manage_historico_localizacao('UPDATE', 1, SYSTIMESTAMP, 1, SYSTIMESTAMP, 1, 600, 1, 1, 460, 130);
EXEC manage_historico_localizacao('DELETE', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


commit;
select * from historico_localizacao;
------------------------------------------------------
--Relatorios
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE relatorio_historico_localizacao
IS
    CURSOR c_historico IS
        SELECT 
            h.id_historico,
            h.historico_timestamp,
            h.operacao_lastro_id_operacao,
            o.operecao_timestamp AS operacao_timestamp,
            n.nome AS nome_navio,
            t.tiponome AS tipo_navio,
            h.quantidade_agua,
            tp.nomeoperacao AS tipo_operacao,
            d.nome AS destino,
            h.latitude,
            h.longitude
        FROM 
            historico_localizacao h
        JOIN 
            operacao_lastro o ON h.operacao_lastro_id_operacao = o.id_operacao
        JOIN 
            navio n ON h.id_navio = n.id_navio
        JOIN 
            tipo_navio t ON n.tipo_navio_id_tiponavio = t.id_tiponavio
        JOIN 
            tipo_operacao tp ON h.id_tipooperacao = tp.id_tipooperacao
        JOIN 
            destino d ON h.id_porto = d.id_porto
        ORDER BY 
            h.historico_timestamp;

BEGIN
    DBMS_OUTPUT.PUT_LINE('ID_HISTORICO | HISTORICO_TIMESTAMP | OPERACAO_ID | OPERACAO_TIMESTAMP | NOME_NAVIO | TIPO_NAVIO | QUANTIDADE_AGUA | TIPO_OPERACAO | DESTINO | LATITUDE | LONGITUDE');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------------------------------------');

    FOR r IN c_historico LOOP
        DBMS_OUTPUT.PUT_LINE(r.id_historico || ' | ' || r.historico_timestamp || ' | ' || r.operacao_lastro_id_operacao || ' | ' || r.operacao_timestamp || ' | ' || r.nome_navio || ' | ' || r.tipo_navio || ' | ' || r.quantidade_agua || ' | ' || r.tipo_operacao || ' | ' || r.destino || ' | ' || r.latitude || ' | ' || r.longitude);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE relatorio_operacao_lastro
IS
    CURSOR c_operacao IS
        SELECT 
            o.id_operacao,
            o.operecao_timestamp,
            n.nome AS nome_navio,
            t.tiponome AS tipo_navio,
            o.quantidade_agua,
            tp.nomeoperacao AS tipo_operacao,
            d.nome AS destino,
            o.latitude,
            o.longitude
        FROM 
            operacao_lastro o
        JOIN 
            navio n ON o.navio_id_navio = n.id_navio
        JOIN 
            tipo_navio t ON n.tipo_navio_id_tiponavio = t.id_tiponavio
        JOIN 
            tipo_operacao tp ON o.tipo_operacao_id_tipooperacao = tp.id_tipooperacao
        JOIN 
            destino d ON o.destino_id_porto = d.id_porto
        ORDER BY 
            o.operecao_timestamp;

BEGIN
    DBMS_OUTPUT.PUT_LINE('ID_OPERACAO | OPERACAO_TIMESTAMP | NOME_NAVIO | TIPO_NAVIO | QUANTIDADE_AGUA | TIPO_OPERACAO | DESTINO | LATITUDE | LONGITUDE');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------------------------------------');

    FOR r IN c_operacao LOOP
        DBMS_OUTPUT.PUT_LINE(r.id_operacao || ' | ' || r.operecao_timestamp || ' | ' || r.nome_navio || ' | ' || r.tipo_navio || ' | ' || r.quantidade_agua || ' | ' || r.tipo_operacao || ' | ' || r.destino || ' | ' || r.latitude || ' | ' || r.longitude);
    END LOOP;
END;
/

BEGIN
    relatorio_historico_localizacao;
     relatorio_operacao_lastro;
END;
/

-------------------------------------
--Trigger

CREATE TABLE log_alteracoes (
 id_log NUMBER GENERATED BY DEFAULT AS IDENTITY,
 nome_usuario VARCHAR2(50),
 tabela_afetada VARCHAR2(50),
 data_hora TIMESTAMP,
 dados_antigos CLOB,
 dados_novos CLOB,
 CONSTRAINT pk_log_alteracoes PRIMARY KEY (id_log)
);


CREATE OR REPLACE TRIGGER auditar_alteracoes_tipo_navio
AFTER INSERT OR UPDATE OR DELETE ON tipo_navio
FOR EACH ROW
DECLARE
    v_nome_usuario VARCHAR2(50);
    v_dados_antigos CLOB;
    v_dados_novos CLOB;
BEGIN
    v_nome_usuario := USER;

    IF DELETING OR UPDATING THEN
        v_dados_antigos := 'ID_TIPONAVIO: ' || :OLD.id_tiponavio || ', TIPONOME: ' || :OLD.tiponome;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_dados_novos := 'ID_TIPONAVIO: ' || :NEW.id_tiponavio || ', TIPONOME: ' || :NEW.tiponome;
    END IF;

    INSERT INTO log_alteracoes (nome_usuario, tabela_afetada, data_hora, dados_antigos, dados_novos)
    VALUES (v_nome_usuario, 'tipo_navio', SYSTIMESTAMP, v_dados_antigos, v_dados_novos);

EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Evita falha em caso de erro ao inserir no log
END;
/

ALTER TRIGGER auditar_alteracoes_tipo_navio ENABLE;

EXEC manage_tipo_navio('UPDATE', 1, 'Navio de Passageiros');

select * from log_alteracoes;

---------------------------------------------------


CREATE OR REPLACE PACKAGE ship_management_pkg IS
    PROCEDURE manage_tipo_navio(
        p_operation IN VARCHAR2,
        p_id_tiponavio IN NUMBER,
        p_tiponome IN VARCHAR2
    );
    PROCEDURE manage_tipo_operacao (
    p_operation IN VARCHAR2,
    p_id_tipooperacao IN NUMBER,
    p_nomeoperacao IN VARCHAR2
);
    PROCEDURE manage_destino (
    p_operation IN VARCHAR2,
    p_id_porto IN NUMBER,
    p_nome VARCHAR2 DEFAULT NULL,
    p_latitude NUMBER DEFAULT NULL,
    p_longitude NUMBER DEFAULT NULL
);
    PROCEDURE manage_navio (
    p_operation IN VARCHAR2,
    p_id_navio IN NUMBER,
    p_nome VARCHAR2,
    p_capacidade_lastro IN NUMBER,
    p_tipo_navio_id_tiponavio IN NUMBER
);
    PROCEDURE manage_operacao_lastro (
    p_operation IN VARCHAR2,
    p_id_operacao IN NUMBER,
    p_quantidade_agua IN NUMBER,
    p_operecao_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_navio_id_navio IN NUMBER,
    p_tipo_operacao_id_tipooperacao IN NUMBER,
    p_destino_id_porto IN NUMBER,
    p_latitude IN NUMBER,
    p_longitude IN NUMBER
);
    PROCEDURE manage_historico_localizacao (
    p_operation IN VARCHAR2,
    p_id_historico IN NUMBER,
    p_historico_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_operacao_lastro_id_operacao IN NUMBER,
    p_operecao_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_id_navio IN NUMBER,
    p_quantidade_agua IN NUMBER,
    p_id_tipooperacao IN NUMBER,
    p_id_porto IN NUMBER,
    p_latitude IN NUMBER,
    p_longitude IN NUMBER
);  

END ship_management_pkg;
/
CREATE OR REPLACE PACKAGE BODY ship_management_pkg IS

    PROCEDURE manage_tipo_navio(
        p_operation IN VARCHAR2,
        p_id_tiponavio IN NUMBER,
        p_tiponome IN VARCHAR2
    ) IS
    BEGIN
        IF p_operation = 'INSERT' THEN
            -- Insert a new tipo_navio
            INSERT INTO tipo_navio (id_tiponavio, tiponome)
            VALUES (p_id_tiponavio, p_tiponome);
            COMMIT;
        ELSIF p_operation = 'UPDATE' THEN
            -- Update an existing tipo_navio
            UPDATE tipo_navio
            SET tiponome = p_tiponome
            WHERE id_tiponavio = p_id_tiponavio;

            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Id_tiponavio não encontrado');
            END IF;
            COMMIT;
        ELSIF p_operation = 'DELETE' THEN
            -- Delete a tipo_navio
            DELETE FROM tipo_navio
            WHERE id_tiponavio = p_id_tiponavio;

            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_tiponavio não encontrado');
            END IF;
            COMMIT;
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                INSERT INTO log_erros (codigo_erro, mensagem_erro, data_ocorrencia, usuario)
                VALUES (-20001, 'Erro ao manipular a tabela tipo_navio', SYSDATE, USER);
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- Evita loop de exceções caso a inserção no log falhe
            END;
            ROLLBACK;
            RAISE;
    END manage_tipo_navio;
    PROCEDURE manage_tipo_operacao (
    p_operation IN VARCHAR2,
    p_id_tipooperacao IN NUMBER,
    p_nomeoperacao IN VARCHAR2
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new tipo_operacao
        INSERT INTO tipo_operacao (id_tipooperacao, nomeoperacao)
        VALUES (p_id_tipooperacao, p_nomeoperacao);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing tipo_operacao
        UPDATE tipo_operacao
        SET nomeoperacao = p_nomeoperacao
        WHERE id_tipooperacao = p_id_tipooperacao;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_tipooperacao não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a tipo_operacao
        DELETE FROM tipo_operacao
        WHERE id_tipooperacao = p_id_tipooperacao;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_tipooperacao não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            INSERT INTO log_erros (codigo_erro, mensagem_erro, data_ocorrencia, usuario)
            VALUES (-20001, 'Erro ao manipular a tabela tipo_operacao', SYSDATE, USER);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Evita loop de exceções caso a inserção no log falhe
        END;
        ROLLBACK;
        RAISE;
END manage_tipo_operacao;
    PROCEDURE manage_destino (
    p_operation IN VARCHAR2,
    p_id_porto IN NUMBER,
    p_nome VARCHAR2 DEFAULT NULL,
    p_latitude NUMBER DEFAULT NULL,
    p_longitude NUMBER DEFAULT NULL
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new destino
        INSERT INTO destino (id_porto, nome, latitude, longitude)
        VALUES (p_id_porto, p_nome, p_latitude, p_longitude);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing destino
        UPDATE destino
        SET nome = p_nome,
            latitude = p_latitude,
            longitude = p_longitude
        WHERE id_porto = p_id_porto;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21003, 'Id_porto não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a destino
        DELETE FROM destino
        WHERE id_porto = p_id_porto;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_porto não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            INSERT INTO log_erros (codigo_erro, mensagem_erro, data_ocorrencia, usuario)
            VALUES (-20001, 'Erro ao manipular a tabela destino', SYSDATE, USER);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Evita loop de exceções caso a inserção no log falhe
        END;
        ROLLBACK;
        RAISE;
END manage_destino;
    PROCEDURE manage_navio (
    p_operation IN VARCHAR2,
    p_id_navio IN NUMBER,
    p_nome VARCHAR2,
    p_capacidade_lastro IN NUMBER,
    p_tipo_navio_id_tiponavio IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new navio
        INSERT INTO navio (id_navio, nome, capacidade_lastro, tipo_navio_id_tiponavio)
        VALUES (p_id_navio, p_nome, p_capacidade_lastro, p_tipo_navio_id_tiponavio);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing navio
        UPDATE navio
        SET nome = p_nome,
            capacidade_lastro = p_capacidade_lastro,
            tipo_navio_id_tiponavio = p_tipo_navio_id_tiponavio
        WHERE id_navio = p_id_navio;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_navio não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a navio
        DELETE FROM navio
        WHERE id_navio = p_id_navio;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_navio não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            INSERT INTO log_erros (codigo_erro, mensagem_erro, data_ocorrencia, usuario)
            VALUES (-20001, 'Erro ao manipular a tabela navio', SYSDATE, USER);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Evita loop de exceções caso a inserção no log falhe
        END;
        ROLLBACK;
        RAISE;
END manage_navio;
    PROCEDURE manage_operacao_lastro (
    p_operation IN VARCHAR2,
    p_id_operacao IN NUMBER,
    p_quantidade_agua IN NUMBER,
    p_operecao_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_navio_id_navio IN NUMBER,
    p_tipo_operacao_id_tipooperacao IN NUMBER,
    p_destino_id_porto IN NUMBER,
    p_latitude IN NUMBER,
    p_longitude IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new operacao_lastro
        INSERT INTO operacao_lastro (id_operacao, quantidade_agua, operecao_timestamp, navio_id_navio, tipo_operacao_id_tipooperacao, destino_id_porto, latitude, longitude)
        VALUES (p_id_operacao, p_quantidade_agua, p_operecao_timestamp, p_navio_id_navio, p_tipo_operacao_id_tipooperacao, p_destino_id_porto, p_latitude, p_longitude);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing operacao_lastro
        UPDATE operacao_lastro
        SET quantidade_agua = p_quantidade_agua,
            operecao_timestamp = p_operecao_timestamp,
            navio_id_navio = p_navio_id_navio,
            tipo_operacao_id_tipooperacao = p_tipo_operacao_id_tipooperacao,
            destino_id_porto = p_destino_id_porto,
            latitude = p_latitude,
            longitude = p_longitude
        WHERE id_operacao = p_id_operacao;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21003, 'Id_operacao não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete an operacao_lastro
        DELETE FROM operacao_lastro
        WHERE id_operacao = p_id_operacao;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_operacao não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-21007, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END manage_operacao_lastro;
    PROCEDURE manage_historico_localizacao (
    p_operation IN VARCHAR2,
    p_id_historico IN NUMBER,
    p_historico_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_operacao_lastro_id_operacao IN NUMBER,
    p_operecao_timestamp IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_id_navio IN NUMBER,
    p_quantidade_agua IN NUMBER,
    p_id_tipooperacao IN NUMBER,
    p_id_porto IN NUMBER,
    p_latitude IN NUMBER,
    p_longitude IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new historico_localizacao
        INSERT INTO historico_localizacao (id_historico, historico_timestamp, operacao_lastro_id_operacao, operecao_timestamp, id_navio, quantidade_agua, id_tipooperacao, id_porto, latitude, longitude)
        VALUES (p_id_historico, p_historico_timestamp, p_operacao_lastro_id_operacao, p_operecao_timestamp, p_id_navio, p_quantidade_agua, p_id_tipooperacao, p_id_porto, p_latitude, p_longitude);
        COMMIT;
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing historico_localizacao
        UPDATE historico_localizacao
        SET historico_timestamp = p_historico_timestamp,
            operacao_lastro_id_operacao = p_operacao_lastro_id_operacao,
            operecao_timestamp = p_operecao_timestamp,
            id_navio = p_id_navio,
            quantidade_agua = p_quantidade_agua,
            id_tipooperacao = p_id_tipooperacao,
            id_porto = p_id_porto,
            latitude = p_latitude,
            longitude = p_longitude
        WHERE id_historico = p_id_historico;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21003, 'Id_historico não encontrado');
        END IF;
        COMMIT;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a historico_localizacao
        DELETE FROM historico_localizacao
        WHERE id_historico = p_id_historico;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_historico não encontrado');
        END IF;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-21007, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END manage_historico_localizacao;
    PROCEDURE relatorio_historico_localizacao
IS
    CURSOR c_historico IS
        SELECT 
            h.id_historico,
            h.historico_timestamp,
            h.operacao_lastro_id_operacao,
            o.operecao_timestamp AS operacao_timestamp,
            n.nome AS nome_navio,
            t.tiponome AS tipo_navio,
            h.quantidade_agua,
            tp.nomeoperacao AS tipo_operacao,
            d.nome AS destino,
            h.latitude,
            h.longitude
        FROM 
            historico_localizacao h
        JOIN 
            operacao_lastro o ON h.operacao_lastro_id_operacao = o.id_operacao
        JOIN 
            navio n ON h.id_navio = n.id_navio
        JOIN 
            tipo_navio t ON n.tipo_navio_id_tiponavio = t.id_tiponavio
        JOIN 
            tipo_operacao tp ON h.id_tipooperacao = tp.id_tipooperacao
        JOIN 
            destino d ON h.id_porto = d.id_porto
        ORDER BY 
            h.historico_timestamp;

BEGIN
    DBMS_OUTPUT.PUT_LINE('ID_HISTORICO | HISTORICO_TIMESTAMP | OPERACAO_ID | OPERACAO_TIMESTAMP | NOME_NAVIO | TIPO_NAVIO | QUANTIDADE_AGUA | TIPO_OPERACAO | DESTINO | LATITUDE | LONGITUDE');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------------------------------------');

    FOR r IN c_historico LOOP
        DBMS_OUTPUT.PUT_LINE(r.id_historico || ' | ' || r.historico_timestamp || ' | ' || r.operacao_lastro_id_operacao || ' | ' || r.operacao_timestamp || ' | ' || r.nome_navio || ' | ' || r.tipo_navio || ' | ' || r.quantidade_agua || ' | ' || r.tipo_operacao || ' | ' || r.destino || ' | ' || r.latitude || ' | ' || r.longitude);
    END LOOP;
END;
    PROCEDURE relatorio_operacao_lastro
IS
    CURSOR c_operacao IS
        SELECT 
            o.id_operacao,
            o.operecao_timestamp,
            n.nome AS nome_navio,
            t.tiponome AS tipo_navio,
            o.quantidade_agua,
            tp.nomeoperacao AS tipo_operacao,
            d.nome AS destino,
            o.latitude,
            o.longitude
        FROM 
            operacao_lastro o
        JOIN 
            navio n ON o.navio_id_navio = n.id_navio
        JOIN 
            tipo_navio t ON n.tipo_navio_id_tiponavio = t.id_tiponavio
        JOIN 
            tipo_operacao tp ON o.tipo_operacao_id_tipooperacao = tp.id_tipooperacao
        JOIN 
            destino d ON o.destino_id_porto = d.id_porto
        ORDER BY 
            o.operecao_timestamp;

BEGIN
    DBMS_OUTPUT.PUT_LINE('ID_OPERACAO | OPERACAO_TIMESTAMP | NOME_NAVIO | TIPO_NAVIO | QUANTIDADE_AGUA | TIPO_OPERACAO | DESTINO | LATITUDE | LONGITUDE');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------------------------------------');

    FOR r IN c_operacao LOOP
        DBMS_OUTPUT.PUT_LINE(r.id_operacao || ' | ' || r.operecao_timestamp || ' | ' || r.nome_navio || ' | ' || r.tipo_navio || ' | ' || r.quantidade_agua || ' | ' || r.tipo_operacao || ' | ' || r.destino || ' | ' || r.latitude || ' | ' || r.longitude);
    END LOOP;
END;
END ship_management_pkg;
/

EXEC manage_tipo_navio('INSERT', 1, 'Navio de Carga');
EXEC manage_tipo_navio('UPDATE', 1, 'Navio de Passageiros');
EXEC manage_tipo_navio('DELETE', 1, NULL);
EXEC manage_tipo_navio('INSERT', 1, 'Navio de Carga');

EXEC manage_tipo_operacao('INSERT', 1, 'Operação de Carga');
EXEC manage_tipo_operacao('UPDATE', 1, 'Operação de Descarga');
EXEC manage_tipo_operacao('DELETE', 1, NULL);
EXEC manage_tipo_operacao('INSERT', 1, 'Operação de Carga');

EXEC manage_destino('INSERT', 1, 'Porto A', 100, 200);
EXEC manage_destino('UPDATE', 1, 'Porto B', 110, 210);
EXEC manage_destino('DELETE', 1);
EXEC manage_destino('INSERT', 1, 'Porto A', 100, 200);

EXEC manage_navio('INSERT', 1, 'Navio A', 5000, 1);
EXEC manage_navio('UPDATE', 1, 'Navio B', 6000, 1);
EXEC manage_navio('DELETE', 1, NULL, NULL, NULL);
EXEC manage_navio('INSERT', 1, 'Navio A', 5000, 1);


EXEC manage_operacao_lastro('INSERT', 1, 1000, SYSTIMESTAMP, 1, 1, 1, 450, 120);
EXEC manage_operacao_lastro('UPDATE', 1, 2000, SYSTIMESTAMP, 1, 1, 1, 460, 130);
EXEC manage_operacao_lastro('DELETE', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
EXEC manage_operacao_lastro('INSERT', 1, 1000, SYSTIMESTAMP, 1, 1, 1, 450, 120);


EXEC manage_historico_localizacao('INSERT', 1, SYSTIMESTAMP, 1, SYSTIMESTAMP, 1, 500, 1, 1, 450, 120);
EXEC manage_historico_localizacao('UPDATE', 1, SYSTIMESTAMP, 1, SYSTIMESTAMP, 1, 600, 1, 1, 460, 130);
EXEC manage_historico_localizacao('DELETE', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
EXEC manage_historico_localizacao('INSERT', 1, SYSTIMESTAMP, 1, SYSTIMESTAMP, 1, 500, 1, 1, 450, 120);

BEGIN
    relatorio_historico_localizacao;
     relatorio_operacao_lastro;
END;