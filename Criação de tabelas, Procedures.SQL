CREATE TABLE historico_localizacao (
    localizacao_id_localizacao                                        NUMBER NOT NULL,
    id_historico                                                      NUMBER NOT NULL,
    historico_timestamp                                               TIMESTAMP WITH LOCAL TIME ZONE, 
    monitoramento_operacao_id_monitoramento                           NUMBER NOT NULL,
    navio_id_navio                                                    NUMBER NOT NULL, 
    monitoramento_operacao_operacao_lastro_id_operacao                NUMBER NOT NULL, 
    monitoramento_operacao_operacao_lastro_localizacao_id_localizacao NUMBER NOT NULL
);

ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_pk PRIMARY KEY ( localizacao_id_localizacao,
                                                          id_historico,
                                                          navio_id_navio );

CREATE TABLE localizacao (
    id_localizacao NUMBER NOT NULL,
    latitude       NUMBER,
    longitude      NUMBER,
    porto          VARCHAR2(30) 
);

ALTER TABLE localizacao ADD CONSTRAINT localizacao_pk PRIMARY KEY ( id_localizacao );

CREATE TABLE monitoramento_operacao (
    navio_id_navio                             NUMBER NOT NULL,
    id_monitoramento                           NUMBER NOT NULL,
    nome_metrica                               VARCHAR2(30),
    valor_metrica                              NUMBER,
    metrica_timestamp                          TIMESTAMP WITH LOCAL TIME ZONE,
    operacao_lastro_id_operacao                NUMBER NOT NULL, 
    operacao_lastro_localizacao_id_localizacao NUMBER NOT NULL
);

ALTER TABLE monitoramento_operacao
    ADD CONSTRAINT monitoramento_operacao_pk PRIMARY KEY ( id_monitoramento,
                                                           operacao_lastro_id_operacao,
                                                           operacao_lastro_localizacao_id_localizacao );

CREATE TABLE navio (
    id_navio          NUMBER NOT NULL,
    nome              VARCHAR2(30),
    tipo_navio        VARCHAR2(30),
    capacidade_lastro NUMBER
);

ALTER TABLE navio ADD CONSTRAINT navio_pk PRIMARY KEY ( id_navio );

CREATE TABLE operacao_lastro (
    navio_id_navio             NUMBER NOT NULL,
    id_operacao                NUMBER NOT NULL,
    tipo_operacao              VARCHAR2(30),
    quantidade_agua            NUMBER,
    operecao_timestamp         TIMESTAMP WITH LOCAL TIME ZONE,
    localizacao_id_localizacao NUMBER NOT NULL
);

ALTER TABLE operacao_lastro ADD CONSTRAINT operacao_lastro_pk PRIMARY KEY ( id_operacao,
                                                                            localizacao_id_localizacao );


ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_localizacao_fk FOREIGN KEY ( localizacao_id_localizacao )
        REFERENCES localizacao ( id_localizacao );


ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_monitoramento_operacao_fk FOREIGN KEY ( monitoramento_operacao_id_monitoramento,
                                                                                 monitoramento_operacao_operacao_lastro_id_operacao,
                                                                                 monitoramento_operacao_operacao_lastro_localizacao_id_localizacao
                                                                                 )
        REFERENCES monitoramento_operacao ( id_monitoramento,
                                            operacao_lastro_id_operacao,
                                            operacao_lastro_localizacao_id_localizacao );

ALTER TABLE historico_localizacao
    ADD CONSTRAINT historico_localizacao_navio_fk FOREIGN KEY ( navio_id_navio )
        REFERENCES navio ( id_navio );


ALTER TABLE monitoramento_operacao
    ADD CONSTRAINT monitoramento_operacao_navio_fk FOREIGN KEY ( navio_id_navio )
        REFERENCES navio ( id_navio );


ALTER TABLE monitoramento_operacao
    ADD CONSTRAINT monitoramento_operacao_operacao_lastro_fk FOREIGN KEY ( operacao_lastro_id_operacao,
                                                                           operacao_lastro_localizacao_id_localizacao )
        REFERENCES operacao_lastro ( id_operacao,
                                     localizacao_id_localizacao );

ALTER TABLE operacao_lastro
    ADD CONSTRAINT operacao_lastro_localizacao_fk FOREIGN KEY ( localizacao_id_localizacao )
        REFERENCES localizacao ( id_localizacao );

ALTER TABLE operacao_lastro
    ADD CONSTRAINT operacao_lastro_navio_fk FOREIGN KEY ( navio_id_navio )
        REFERENCES navio ( id_navio );
        
        
        
CREATE OR REPLACE PROCEDURE GerenciarLocalizacao (
    p_operacao IN VARCHAR2,
    p_id_localizacao IN LOCALIZACAO.id_localizacao%TYPE,
    p_latitude IN LOCALIZACAO.latitude%TYPE DEFAULT NULL,
    p_longitude IN LOCALIZACAO.longitude%TYPE DEFAULT NULL,
    p_porto IN LOCALIZACAO.porto%TYPE DEFAULT NULL
)
IS
BEGIN
    IF p_operacao = 'INSERT' THEN
        IF p_id_localizacao IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'id_localizacao não pode ser nulo.');
        ELSIF p_latitude IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'latitude não pode ser nulo.');
        ELSIF p_longitude IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'longitude não pode ser nulo.');
        ELSIF p_porto IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'porto não pode ser nulo.');
        END IF;

        BEGIN
            INSERT INTO LOCALIZACAO (id_localizacao, latitude, longitude, porto)
            VALUES (p_id_localizacao, p_latitude, p_longitude, p_porto);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20005, 'id_localizacao já existe.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20006, 'Erro ao inserir localização: ' || SQLERRM);
        END;

    ELSIF p_operacao = 'UPDATE' THEN
        IF p_id_localizacao IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'id_localizacao não pode ser nulo.');
        END IF;

        BEGIN
            UPDATE LOCALIZACAO
            SET latitude = NVL(p_latitude, latitude),
                longitude = NVL(p_longitude, longitude),
                porto = NVL(p_porto, porto)
            WHERE id_localizacao = p_id_localizacao;

            IF SQL%NOTFOUND THEN
                RAISE_APPLICATION_ERROR(-20007, 'Localização não encontrada.');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20008, 'Erro ao atualizar localização: ' || SQLERRM);
        END;

    ELSIF p_operacao = 'DELETE' THEN
        IF p_id_localizacao IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'id_localizacao não pode ser nulo.');
        END IF;

        BEGIN
            DELETE FROM LOCALIZACAO
            WHERE id_localizacao = p_id_localizacao;

            IF SQL%NOTFOUND THEN
                RAISE_APPLICATION_ERROR(-20007, 'Localização não encontrada.');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20009, 'Erro ao deletar localização: ' || SQLERRM);
        END;

    ELSE
        RAISE_APPLICATION_ERROR(-20010, 'Operação inválida. Use INSERT, UPDATE ou DELETE.');
    END IF;
END;
/

BEGIN
    GerenciarLocalizacao(
        p_operacao => 'INSERT',
        p_id_localizacao => 1,
        p_latitude => 377749,
        p_longitude => 1224194,
        p_porto => 'San Francisco'
    );
END;
/


BEGIN
    GerenciarLocalizacao(
        p_operacao => 'UPDATE',
        p_id_localizacao => 1,
        p_latitude => 377750,
        p_longitude => 1224195,
        p_porto => 'San Francisco Updated'
    );
END;
/

select * from localizacao;