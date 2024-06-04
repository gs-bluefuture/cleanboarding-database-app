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

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_localizacao_fk FOREIGN KEY ( localizacao_id_localizacao )
        REFERENCES localizacao ( id_localizacao );

--  ERROR: FK name length exceeds maximum allowed length(30) 
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
    RAISE_APPLICATION_ERROR(-21007, 'Operação inválida');
  END IF;
END;
/                                      

EXEC manage_destino('INSERT', 123, 'Porto Marítimo');
EXEC manage_destino('UPDATE', 123, 'Porto Novo');
EXEC manage_destino('DELETE', 123);

CREATE OR REPLACE PROCEDURE manage_localizacao (
  p_operation IN VARCHAR2,
  p_id_localizacao IN NUMBER,
  p_latitude IN NUMBER DEFAULT NULL,
  p_longitude IN NUMBER DEFAULT NULL,
  p_destino_id_porto IN NUMBER DEFAULT NULL
)
IS
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
END;
/

EXEC manage_localizacao('INSERT', 123, 45678, 123, 123);
EXEC manage_localizacao('UPDATE', 123, 22278, 123, 123);
EXEC manage_localizacao('DELETE', 123);




