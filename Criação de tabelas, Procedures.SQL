CREATE TABLE destino (
    id_porto NUMBER NOT NULL,
    nome     VARCHAR2(30)
);

ALTER TABLE destino ADD CONSTRAINT destino_pk PRIMARY KEY ( id_porto );

CREATE TABLE historico_localizacao (
    id_historico                            NUMBER NOT NULL,
    historico_timestamp                     TIMESTAMP WITH LOCAL TIME ZONE, 
    monitoramento_operacao_id_monitoramento NUMBER NOT NULL,
    navio_id_navio                          NUMBER NOT NULL,
    localizacao_id_localizacao              NUMBER NOT NULL
);

CREATE UNIQUE INDEX historico_localizacao__idx ON
    historico_localizacao (
        navio_id_navio
    ASC );

ALTER TABLE historico_localizacao ADD CONSTRAINT historico_localizacao_pk PRIMARY KEY ( id_historico );

CREATE TABLE localizacao (
    id_localizacao   NUMBER NOT NULL,
    latitude         NUMBER,
    longitude        NUMBER,
    destino_id_porto NUMBER NOT NULL
);

CREATE UNIQUE INDEX localizacao__idx ON
    localizacao (
        destino_id_porto
    ASC );

ALTER TABLE localizacao ADD CONSTRAINT localizacao_pk PRIMARY KEY ( id_localizacao );

CREATE TABLE monitoramento_operacao (
    id_monitoramento            NUMBER NOT NULL,
    nome_metrica                VARCHAR2(30),
    valor_metrica               NUMBER,
    metrica_timestamp           TIMESTAMP WITH LOCAL TIME ZONE,
    operacao_lastro_id_operacao NUMBER NOT NULL
);

ALTER TABLE monitoramento_operacao ADD CONSTRAINT monitoramento_operacao_pk PRIMARY KEY ( id_monitoramento );

CREATE TABLE navio (
    id_navio                                NUMBER NOT NULL,
    nome                                    VARCHAR2(30),
    capacidade_lastro                       NUMBER, 
    monitoramento_operacao_id_monitoramento NUMBER NOT NULL
);

ALTER TABLE navio ADD CONSTRAINT navio_pk PRIMARY KEY ( id_navio );

CREATE TABLE operacao_lastro (
    id_operacao                NUMBER NOT NULL,
    quantidade_agua            NUMBER,
    operecao_timestamp         TIMESTAMP WITH LOCAL TIME ZONE,
    localizacao_id_localizacao NUMBER NOT NULL
);

ALTER TABLE operacao_lastro ADD CONSTRAINT operacao_lastro_pk PRIMARY KEY ( id_operacao );

CREATE TABLE relation_17 (
    operacao_lastro_id_operacao NUMBER NOT NULL,
    navio_id_navio              NUMBER NOT NULL
);

ALTER TABLE relation_17 ADD CONSTRAINT relation_17_pk PRIMARY KEY ( operacao_lastro_id_operacao,
                                                                    navio_id_navio );
CREATE TABLE relation_20 (
    destino_id_porto NUMBER NOT NULL,
    navio_id_navio   NUMBER NOT NULL
);

ALTER TABLE relation_20 ADD CONSTRAINT relation_20_pk PRIMARY KEY ( destino_id_porto,
                                                                    navio_id_navio );
CREATE TABLE tipo_navio (
    id_tiponavio   NUMBER NOT NULL,
    tiponome       VARCHAR2(30),
    navio_id_navio NUMBER NOT NULL
);

ALTER TABLE tipo_navio ADD CONSTRAINT tipo_navio_pk PRIMARY KEY ( id_tiponavio );

CREATE TABLE tipo_operacao (
    id_tipooperacao             NUMBER NOT NULL,
    nomeoperacao                VARCHAR2(30),
    operacao_lastro_id_operacao NUMBER NOT NULL
);

ALTER TABLE tipo_operacao ADD CONSTRAINT tipo_operacao_pk PRIMARY KEY ( id_tipooperacao );

ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_localizacao_fk FOREIGN KEY ( localizacao_id_localizacao )
        REFERENCES localizacao ( id_localizacao );

ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_monitoramento_operacao_fk FOREIGN KEY ( monitoramento_operacao_id_monitoramento )
        REFERENCES monitoramento_operacao ( id_monitoramento );

ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_navio_fk FOREIGN KEY ( navio_id_navio )
        REFERENCES navio ( id_navio );

ALTER TABLE localizacao
    ADD CONSTRAINT localizacao_destino_fk FOREIGN KEY ( destino_id_porto )
        REFERENCES destino ( id_porto );


ALTER TABLE monitoramento_operacao
    ADD CONSTRAINT monitoramento_operacao_operacao_lastro_fk FOREIGN KEY ( operacao_lastro_id_operacao )
        REFERENCES operacao_lastro ( id_operacao );

 
ALTER TABLE navio
    ADD CONSTRAINT navio_monitoramento_operacao_fk FOREIGN KEY ( monitoramento_operacao_id_monitoramento )
        REFERENCES monitoramento_operacao ( id_monitoramento );

ALTER TABLE operacao_lastro
    ADD CONSTRAINT operacao_lastro_localizacao_fk FOREIGN KEY ( localizacao_id_localizacao )
        REFERENCES localizacao ( id_localizacao );

ALTER TABLE relation_17
    ADD CONSTRAINT relation_17_navio_fk FOREIGN KEY ( navio_id_navio )
        REFERENCES navio ( id_navio );

ALTER TABLE relation_17
    ADD CONSTRAINT relation_17_operacao_lastro_fk FOREIGN KEY ( operacao_lastro_id_operacao )
        REFERENCES operacao_lastro ( id_operacao );

ALTER TABLE relation_20
    ADD CONSTRAINT relation_20_destino_fk FOREIGN KEY ( destino_id_porto )
        REFERENCES destino ( id_porto );

ALTER TABLE relation_20
    ADD CONSTRAINT relation_20_navio_fk FOREIGN KEY ( navio_id_navio )
        REFERENCES navio ( id_navio );

ALTER TABLE tipo_navio
    ADD CONSTRAINT tipo_navio_navio_fk FOREIGN KEY ( navio_id_navio )
        REFERENCES navio ( id_navio );


ALTER TABLE tipo_operacao
    ADD CONSTRAINT tipo_operacao_operacao_lastro_fk FOREIGN KEY ( operacao_lastro_id_operacao )
        REFERENCES operacao_lastro ( id_operacao );
                                     
-------------------------------------------------  
    
CREATE OR REPLACE PACKAGE meu_package AS
    PROCEDURE manage_destino (
        p_operation IN VARCHAR2,
        p_id_porto IN NUMBER,
        p_nome VARCHAR2 DEFAULT NULL
    );
     PROCEDURE manage_localizacao (
        p_operation IN VARCHAR2,
        p_id_localizacao IN NUMBER,
        p_latitude IN NUMBER DEFAULT NULL,
        p_longitude IN NUMBER DEFAULT NULL,
        p_destino_id_porto IN NUMBER DEFAULT NULL
    );
      PROCEDURE manage_operacao_lastro (
        p_operation IN VARCHAR2,
        p_id_operacao IN NUMBER,
        p_quantidade_agua IN NUMBER,
        p_operacao_timestamp IN TIMESTAMP WITH TIME ZONE,
        p_localizacao_id IN NUMBER
    );
    PROCEDURE manage_monitoramento_operacao (
    p_operation             IN VARCHAR2,
    p_id_monitoramento      IN NUMBER,
    p_nome_metrica          IN VARCHAR2,
    p_valor_metrica         IN NUMBER,
    p_operacao_lastro_id    IN NUMBER
);
    PROCEDURE manage_navio (
    p_operation             IN VARCHAR2,
    p_id_navio              IN NUMBER,
    p_nome                  IN VARCHAR2,
    p_capacidade_lastro     IN NUMBER,
    p_monitoramento_id      IN NUMBER
);
    PROCEDURE manage_tipo_navio (
    p_operation          IN VARCHAR2,
    p_id_tiponavio       IN NUMBER,
    p_tiponome           IN VARCHAR2,
    p_navio_id_navio     IN NUMBER
);
    PROCEDURE manage_tipo_operacao (
    p_operation             IN VARCHAR2,
    p_id_tipooperacao      IN NUMBER,
    p_nomeoperacao         IN VARCHAR2,
    p_operacao_lastro_id_operacao IN NUMBER
);
    PROCEDURE manage_historico_localizacao (
    p_operation                     IN VARCHAR2,
    p_id_historico                 IN NUMBER,
    p_historico_timestamp          IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_monitoramento_operacao_id    IN NUMBER,
    p_navio_id                     IN NUMBER,
    p_localizacao_id               IN NUMBER
);
    
    
END meu_package;
/

CREATE OR REPLACE PACKAGE BODY meu_package AS
    PROCEDURE manage_destino (
        p_operation IN VARCHAR2,
        p_id_porto IN NUMBER,
        p_nome VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        IF p_operation = 'INSERT' THEN
            -- Insert a new destino
            INSERT INTO DESTINO (id_porto, nome)
            VALUES (p_id_porto, p_nome);
            COMMIT;
        ELSIF p_operation = 'UPDATE' THEN
            -- Update an existing destino
            UPDATE DESTINO
            SET nome = p_nome
            WHERE id_porto = p_id_porto;
          
            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-21003, 'Id_porto não encontrado');
            END IF;
            COMMIT;
        ELSIF p_operation = 'DELETE' THEN
            -- Delete a destino
            DELETE FROM DESTINO
            WHERE id_porto = p_id_porto;
          
            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_porto não encontrado');
            END IF;
            COMMIT;
        ELSE
            RAISE_APPLICATION_ERROR(-21007, 'Operação inválida');
        END IF;
    END manage_destino;
    PROCEDURE manage_localizacao (
        p_operation IN VARCHAR2,
        p_id_localizacao IN NUMBER,
        p_latitude IN NUMBER DEFAULT NULL,
        p_longitude IN NUMBER DEFAULT NULL,
        p_destino_id_porto IN NUMBER DEFAULT NULL
    ) IS
    BEGIN
        IF p_operation = 'INSERT' THEN
            -- Insert a new localizacao
            INSERT INTO LOCALIZACAO (id_localizacao, latitude, longitude, destino_id_porto)
            VALUES (p_id_localizacao, p_latitude, p_longitude, p_destino_id_porto);
            COMMIT;
        ELSIF p_operation = 'UPDATE' THEN
            -- Update an existing localizacao
            UPDATE LOCALIZACAO
            SET latitude = p_latitude,
                longitude = p_longitude,
                destino_id_porto = p_destino_id_porto
            WHERE id_localizacao = p_id_localizacao;
    
            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-21003, 'Id_localizacao não encontrado');
            END IF;
            COMMIT;
        ELSIF p_operation = 'DELETE' THEN
            -- Delete a localizacao
            DELETE FROM LOCALIZACAO
            WHERE id_localizacao = p_id_localizacao;
    
            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_localizacao não encontrado');
            END IF;
            COMMIT;
        ELSE
            RAISE_APPLICATION_ERROR(-21007, 'Operação inválida');
        END IF;
    END manage_localizacao;
    PROCEDURE manage_operacao_lastro (
        p_operation IN VARCHAR2,
        p_id_operacao IN NUMBER,
        p_quantidade_agua IN NUMBER,
        p_operacao_timestamp IN TIMESTAMP WITH TIME ZONE,
        p_localizacao_id IN NUMBER
    ) IS
    BEGIN
        IF p_operation = 'INSERT' THEN
            -- Insert a new operacao_lastro
            INSERT INTO operacao_lastro (id_operacao, quantidade_agua, operecao_timestamp, localizacao_id_localizacao)
            VALUES (p_id_operacao, p_quantidade_agua, p_operacao_timestamp, p_localizacao_id);
            COMMIT;
        ELSIF p_operation = 'UPDATE' THEN
            -- Update an existing operacao_lastro
            UPDATE operacao_lastro
            SET quantidade_agua = p_quantidade_agua,
                operecao_timestamp = p_operacao_timestamp,
                localizacao_id_localizacao = p_localizacao_id
            WHERE id_operacao = p_id_operacao;
    
            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-21003, 'Id_operacao não encontrado');
            END IF;
            COMMIT;
        ELSIF p_operation = 'DELETE' THEN
            -- Delete a operacao_lastro
            DELETE FROM operacao_lastro
            WHERE id_operacao = p_id_operacao;
    
            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_operacao não encontrado');
            END IF;
            COMMIT;
        ELSE
            RAISE_APPLICATION_ERROR(-21007, 'Operação inválida');
        END IF;
    END manage_operacao_lastro;
    PROCEDURE manage_monitoramento_operacao (
    p_operation             IN VARCHAR2,
    p_id_monitoramento      IN NUMBER,
    p_nome_metrica          IN VARCHAR2,
    p_valor_metrica         IN NUMBER,
    p_operacao_lastro_id    IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new monitoramento_operacao
        INSERT INTO monitoramento_operacao (id_monitoramento, nome_metrica, valor_metrica, metrica_timestamp, operacao_lastro_id_operacao)
        VALUES (p_id_monitoramento, p_nome_metrica, p_valor_metrica, CURRENT_TIMESTAMP, p_operacao_lastro_id);
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing monitoramento_operacao
        UPDATE monitoramento_operacao
        SET nome_metrica = p_nome_metrica,
            valor_metrica = p_valor_metrica,
            metrica_timestamp = CURRENT_TIMESTAMP
        WHERE id_monitoramento = p_id_monitoramento;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21003, 'Id_monitoramento não encontrado');
        END IF;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a monitoramento_operacao
        DELETE FROM monitoramento_operacao
        WHERE id_monitoramento = p_id_monitoramento;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-21005, 'Nenhuma linha excluída, id_monitoramento não encontrado');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-21007, 'Operação inválida');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
    PROCEDURE manage_navio (
    p_operation             IN VARCHAR2,
    p_id_navio              IN NUMBER,
    p_nome                  IN VARCHAR2,
    p_capacidade_lastro     IN NUMBER,
    p_monitoramento_id      IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new navio
        INSERT INTO navio (id_navio, nome, capacidade_lastro, monitoramento_operacao_id_monitoramento)
        VALUES (p_id_navio, p_nome, p_capacidade_lastro, p_monitoramento_id);
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing navio
        UPDATE navio
        SET nome = p_nome,
            capacidade_lastro = p_capacidade_lastro,
            monitoramento_operacao_id_monitoramento = p_monitoramento_id
        WHERE id_navio = p_id_navio;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_navio não encontrado');
        END IF;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a navio
        DELETE FROM navio
        WHERE id_navio = p_id_navio;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_navio não encontrado');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
    PROCEDURE manage_tipo_navio (
    p_operation          IN VARCHAR2,
    p_id_tiponavio       IN NUMBER,
    p_tiponome           IN VARCHAR2,
    p_navio_id_navio     IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new tipo_navio
        INSERT INTO tipo_navio (id_tiponavio, tiponome, navio_id_navio)
        VALUES (p_id_tiponavio, p_tiponome, p_navio_id_navio);
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing tipo_navio
        UPDATE tipo_navio
        SET tiponome = p_tiponome,
            navio_id_navio = p_navio_id_navio
        WHERE id_tiponavio = p_id_tiponavio;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_tiponavio não encontrado');
        END IF;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a tipo_navio
        DELETE FROM tipo_navio
        WHERE id_tiponavio = p_id_tiponavio;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_tiponavio não encontrado');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
    PROCEDURE manage_tipo_operacao (
    p_operation             IN VARCHAR2,
    p_id_tipooperacao      IN NUMBER,
    p_nomeoperacao         IN VARCHAR2,
    p_operacao_lastro_id_operacao IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new tipo_operacao
        INSERT INTO tipo_operacao (id_tipooperacao, nomeoperacao, operacao_lastro_id_operacao)
        VALUES (p_id_tipooperacao, p_nomeoperacao, p_operacao_lastro_id_operacao);
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing tipo_operacao
        UPDATE tipo_operacao
        SET nomeoperacao = p_nomeoperacao,
            operacao_lastro_id_operacao = p_operacao_lastro_id_operacao
        WHERE id_tipooperacao = p_id_tipooperacao;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_tipooperacao não encontrado');
        END IF;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a tipo_operacao
        DELETE FROM tipo_operacao
        WHERE id_tipooperacao = p_id_tipooperacao;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_tipooperacao não encontrado');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
     PROCEDURE manage_historico_localizacao (
    p_operation                     IN VARCHAR2,
    p_id_historico                 IN NUMBER,
    p_historico_timestamp          IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_monitoramento_operacao_id    IN NUMBER,
    p_navio_id                     IN NUMBER,
    p_localizacao_id               IN NUMBER
)
IS
BEGIN
    IF p_operation = 'INSERT' THEN
        -- Insert a new historico_localizacao
        INSERT INTO historico_localizacao (id_historico, historico_timestamp, monitoramento_operacao_id_monitoramento, navio_id_navio, localizacao_id_localizacao)
        VALUES (p_id_historico, p_historico_timestamp, p_monitoramento_operacao_id, p_navio_id, p_localizacao_id);
    ELSIF p_operation = 'UPDATE' THEN
        -- Update an existing historico_localizacao
        UPDATE historico_localizacao
        SET historico_timestamp = p_historico_timestamp,
            monitoramento_operacao_id_monitoramento = p_monitoramento_operacao_id,
            navio_id_navio = p_navio_id,
            localizacao_id_localizacao = p_localizacao_id
        WHERE id_historico = p_id_historico;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Id_historico não encontrado');
        END IF;
    ELSIF p_operation = 'DELETE' THEN
        -- Delete a historico_localizacao
        DELETE FROM historico_localizacao
        WHERE id_historico = p_id_historico;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma linha excluída, id_historico não encontrado');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Operação inválida');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;


END meu_package;
/                                   

EXEC manage_destino('INSERT', 123, 'Porto Marítimo');
EXEC manage_destino('UPDATE', 123, 'Porto Novo');
EXEC manage_destino('DELETE', 123);
EXEC manage_destino('INSERT', 123, 'Porto Marítimo');

EXEC manage_localizacao('INSERT', 123, 45678, 123, 123);
EXEC manage_localizacao('UPDATE', 123, 22278, 123, 123);
EXEC manage_localizacao('DELETE', 123);
EXEC manage_localizacao('INSERT', 123, 45678, 123, 123);

EXEC manage_operacao_lastro('INSERT', 123, 123,TIMESTAMP '2024-06-04 16:22:20.235765 ', 123);
EXEC manage_operacao_lastro('UPDATE', 123, 2223,TIMESTAMP '2024-06-04 16:22:20.235765 ', 123);
EXEC manage_operacao_lastro('DELETE', 123, NULL, NULL, NULL);
EXEC manage_operacao_lastro('INSERT', 123, 123,TIMESTAMP '2024-06-04 16:22:20.235765 ', 123);

EXEC manage_monitoramento_operacao('INSERT', 1, 'Nome Métrica', 100, 123);
EXEC manage_monitoramento_operacao('UPDATE', 1, 'Nome Métrica Atualizada', 200, 123);
EXEC manage_monitoramento_operacao('DELETE', 1, NULL, NULL, NULL);
EXEC manage_monitoramento_operacao('INSERT', 1, 'Nome Métrica', 100, 123);

EXEC manage_navio('INSERT', 133, 'Navio A', 133, 1);
EXEC manage_navio('UPDATE', 133, 'Navio B', 133, 1);
EXEC manage_navio('DELETE', 133, NULL, NULL, NULL);
EXEC manage_navio('INSERT', 133, 'Navio A', 133, 1);

EXEC manage_tipo_navio('INSERT', 1, 'Tipo A', 133);
EXEC manage_tipo_navio('UPDATE', 1, 'Tipo B', 133);
EXEC manage_tipo_navio('DELETE', 1, NULL, NULL);
EXEC manage_tipo_navio('INSERT', 1, 'Tipo A', 133);

EXEC manage_tipo_operacao('INSERT', 1, 'Operação A', 123);
EXEC manage_tipo_operacao('UPDATE', 1, 'Operação B', 123);
EXEC manage_tipo_operacao('DELETE', 1, NULL, NULL);
EXEC manage_tipo_operacao('INSERT', 1, 'Operação A', 123);

EXEC manage_historico_localizacao('INSERT', 1, TIMESTAMP '2024-06-04 16:22:20.235765', 1, 133, 123);
EXEC manage_historico_localizacao('UPDATE', 1, TIMESTAMP '2023-05-04 16:22:20.235765', 1, 133, 123);
EXEC manage_historico_localizacao('DELETE', 1, NULL, NULL, NULL, NULL);
EXEC manage_historico_localizacao('INSERT', 1, TIMESTAMP '2024-06-04 16:22:20.235765', 1, 133, 123);

--------------------------------------
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE relatorio_qtde_operacoes_lastro_por_navio IS
BEGIN
    FOR navio_info IN (
        SELECT n.id_navio, n.nome, COUNT(ol.id_operacao) AS qtde_operacoes
        FROM navio n
        LEFT JOIN operacao_lastro ol ON n.id_navio = ol.localizacao_id_localizacao
        GROUP BY n.id_navio, n.nome
        ORDER BY n.nome
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Navio: ' || navio_info.nome || ', Quantidade de Operações de Lastro: ' || navio_info.qtde_operacoes);
    END LOOP;
END;
/
CREATE OR REPLACE PROCEDURE relatorio_historico_localizacao_por_navio IS
BEGIN
    FOR navio_info IN (
        SELECT n.id_navio, n.nome, COUNT(hl.id_historico) AS qtde_registros
        FROM navio n
        LEFT JOIN historico_localizacao hl ON n.id_navio = hl.navio_id_navio
        GROUP BY n.id_navio, n.nome
        ORDER BY n.nome
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Navio: ' || navio_info.nome || ', Quantidade de Registros de Histórico de Localização: ' || navio_info.qtde_registros);
    END LOOP;
END;
/

BEGIN
    relatorio_qtde_operacoes_lastro_por_navio;
    relatorio_historico_localizacao_por_navio;
END;
/


-----------------------------
CREATE TABLE log_alteracoes (
 id_log NUMBER GENERATED BY DEFAULT AS IDENTITY,
 nome_usuario VARCHAR2(50),
 tabela_afetada VARCHAR2(50),
 data_hora TIMESTAMP,
 dados_antigos CLOB,
 dados_novos CLOB,
 CONSTRAINT pk_log_alteracoes PRIMARY KEY (id_log)
);

CREATE OR REPLACE TRIGGER auditar_alteracoes_destino
AFTER INSERT OR UPDATE OR DELETE ON destino
FOR EACH ROW
DECLARE
    v_nome_usuario VARCHAR2(50);
    v_dados_antigos CLOB;
    v_dados_novos CLOB;
BEGIN
    -- Obter o nome do usuário da sessão atual
    v_nome_usuario := USER;
    
    -- Montar os dados antigos, se houver deleção ou atualização
    IF DELETING OR UPDATING THEN
        v_dados_antigos := 'ID_PORTO: ' || :OLD.id_porto || ', NOME: ' || :OLD.nome;
    END IF;
    
    -- Montar os dados novos, se houver inserção ou atualização
    IF INSERTING OR UPDATING THEN
        v_dados_novos := 'ID_PORTO: ' || :NEW.id_porto || ', NOME: ' || :NEW.nome;
    END IF;
    
    -- Inserir o registro de auditoria na tabela de log, se existir
    BEGIN
        INSERT INTO log_alteracoes (nome_usuario, tabela_afetada, data_hora, dados_antigos, dados_novos)
        VALUES (v_nome_usuario, 'destino', SYSTIMESTAMP, v_dados_antigos, v_dados_novos);
    EXCEPTION
        WHEN OTHERS THEN
            NULL; 
    END;
END;
/


ALTER TRIGGER auditar_alteracoes_destino enable;

INSERT INTO destino (id_porto, nome) VALUES (4, 'Porto A');
INSERT INTO destino (id_porto, nome) VALUES (5, 'Porto B');
COMMIT;

UPDATE destino SET nome = 'Porto C' WHERE id_porto = 4;
COMMIT;

DELETE FROM destino WHERE id_porto = 4;
COMMIT;

------------------------------------------------------------------
CREATE TABLE log_erros (
  id_erro         NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  codigo_erro     VARCHAR2(100),
  mensagem_erro   VARCHAR2(4000),
  data_ocorrencia DATE,
  usuario         VARCHAR2(100)
);

CREATE OR REPLACE PROCEDURE manage_destino (
  p_operation IN VARCHAR2,
  p_id_porto IN NUMBER,
  p_nome VARCHAR2 DEFAULT NULL
)
IS
BEGIN
  IF p_operation = 'INSERT' THEN
    -- Insert a new destino
    INSERT INTO DESTINO (id_porto, nome)
    VALUES (p_id_porto, p_nome);
    COMMIT;
    
  ELSIF p_operation = 'UPDATE' THEN
    -- Update an existing destino
    UPDATE DESTINO
    SET nome = p_nome
    WHERE id_porto = p_id_porto;
    
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-21003, 'Id_porto não encontrado');
    END IF;
    COMMIT;
    
  ELSIF p_operation = 'DELETE' THEN
    -- Delete a destino
    DELETE FROM DESTINO
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
      VALUES (-20001,'Erro ao inserir na tabela destino' ,SYSDATE, USER);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Evita loop de exceções caso a inserção no log falhe
    END;
    
    RAISE;
END;
/

commit;

