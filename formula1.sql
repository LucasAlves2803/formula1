CREATE TABLE pais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE equipes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    pais_id INT REFERENCES pais(id) NOT NULL
);

CREATE TABLE piloto (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    pais_id INT REFERENCES pais(id) NOT NULL,
    equipe_id INT REFERENCES equipes(id)
);

CREATE TABLE pistas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    pais_id INT REFERENCES pais(id) NOT NULL
);

CREATE TABLE grande_premio (
    id SERIAL PRIMARY KEY,
    pista_id INT REFERENCES pistas(id) NOT NULL,
    ano INT NOT NULL,
    campeao INT REFERENCES piloto(id) NOT NULL,
    vice INT REFERENCES piloto(id) NOT NULL,
    terceiro INT REFERENCES piloto(id) NOT NULL
);


INSERT INTO pais (nome) VALUES
('Germany'),
('Austria'),
('Italy'),
('United Kingdom'),
('France'),
('Netherlands'),
('Mexico'),
('Monaco'),
('Spain'),
('Australia');    

INSERT INTO equipes (nome, pais_id) VALUES
('Mercedes', 1),
('Red Bull Racing', 2),
('Ferrari', 3),
('McLaren', 4),
('Alpine', 5);

INSERT INTO piloto (nome, pais_id, equipe_id) VALUES
('Lewis Hamilton', 4, 1),
('George Russell', 4, 1),
('Max Verstappen', 6, 2),
('Sergio Pérez', 7, 2),
('Charles Leclerc', 8, 3),
('Carlos Sainz', 9, 3),
('Lando Norris', 4, 4),
('Daniel Ricciardo', 10, 4),
('Fernando Alonso', 9, 5),
('Esteban Ocon', 5, 5);


INSERT INTO pistas (nome, pais_id) VALUES
('Silverstone Circuit', 4),                  
('Circuit Zandvoort', 6),                    
('Autódromo Hermanos Rodríguez', 7),         
('Circuit de Monaco', 8),                    
('Circuit de Barcelona-Catalunya', 9);       

INSERT INTO grande_premio (pista_id, ano, campeao, vice, terceiro) VALUES
(1, 2022, 1, 2, 3),
(2, 2022, 3, 4, 5),
(3, 2022, 3, 1, 6),
(4, 2022, 5, 6, 7),
(5, 2022, 6, 5, 9);

INSERT INTO grande_premio (pista_id, ano, campeao, vice, terceiro) VALUES
(1, 2021, 5, 9, 4),
(2, 2021, 3, 1, 5),
(3, 2021, 4, 6, 2),
(4, 2021, 6, 5, 7),
(5, 2021, 7, 9, 8);

INSERT INTO grande_premio (pista_id, ano, campeao, vice, terceiro) VALUES
(1, 2023, 3, 1, 6),
(2, 2023, 4, 1, 2),
(3, 2023, 1, 5, 7),
(4, 2023, 1, 4, 7),
(5, 2023, 1, 6, 8);

CREATE TABLE pontos_por_corrida (
    id SERIAL PRIMARY KEY,
    grande_premio_id INT REFERENCES grande_premio(id),
    piloto_id INT REFERENCES piloto(id),
    pontos INT NOT NULL
);

SELECT * FROM pontos_por_corrida;

INSERT INTO pontos_por_corrida (grande_premio_id, piloto_id, pontos)
SELECT id, campeao, 3 FROM grande_premio
UNION ALL
SELECT id, vice, 2 FROM grande_premio
UNION ALL
SELECT id, terceiro, 1 FROM grande_premio;

CREATE INDEX ON pontos_por_corrida USING HASH (piloto_id);

\d+ pontos_por_corrida;

SELECT ppc.piloto_id, gp.ano, p.nome, SUM(ppc.pontos) AS total_pontos
FROM pontos_por_corrida ppc
JOIN grande_premio gp ON ppc.grande_premio_id = gp.id
JOIN piloto p on p.id = ppc.piloto_id
WHERE p.nome = 'Fernando Alonso' AND gp.ano = 2022
GROUP BY ppc.piloto_id, gp.ano, p.nome;

SELECT
    ppc.piloto_id,
    p.nome AS piloto_nome,
    gp.ano,
    SUM(ppc.pontos) AS total_pontos
FROM
    pontos_por_corrida ppc
JOIN
    grande_premio gp ON ppc.grande_premio_id = gp.id
JOIN
    piloto p ON ppc.piloto_id = p.id
WHERE
    gp.ano = 2022
GROUP BY
    ppc.piloto_id, gp.ano, p.nome
ORDER BY
    total_pontos DESC;

SELECT
    ano,
    piloto_id,
    piloto_nome,
    total_pontos
FROM (
    SELECT
        gp.ano,
        ppc.piloto_id,
        p.nome AS piloto_nome,
        SUM(ppc.pontos) AS total_pontos,
        RANK() OVER (PARTITION BY gp.ano ORDER BY SUM(ppc.pontos) DESC) AS posicao
    FROM pontos_por_corrida ppc
    JOIN grande_premio gp ON ppc.grande_premio_id = gp.id
    JOIN piloto p ON ppc.piloto_id = p.id
    GROUP BY gp.ano, ppc.piloto_id, p.nome
) AS ranking
WHERE posicao = 1
ORDER BY ano DESC;

CREATE VIEW campeao_temporada AS
SELECT ano, piloto_id, nome, total_pontos FROM (
    SELECT
        gp.ano,
        p.id AS piloto_id,
        p.nome,
        SUM(ppc.pontos) AS total_pontos,
        RANK() OVER (PARTITION BY gp.ano ORDER BY SUM(ppc.pontos) DESC) AS posicao
    FROM grande_premio gp
    JOIN pontos_por_corrida ppc ON gp.id = ppc.grande_premio_id
    JOIN piloto p ON ppc.piloto_id = p.id
    GROUP BY gp.ano, p.id, p.nome
) sub
WHERE posicao = 1 and ano = 2022;

SELECT * FROM campeao_temporada;

CREATE OR REPLACE FUNCTION pontos_piloto_ano(piloto_nome VARCHAR, ano_temporada INT)
RETURNS TABLE (
    piloto_id INT,
    nome VARCHAR,
    ano INT,
    total_pontos INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ppc.piloto_id,
        p.nome,
        gp.ano,
        SUM(ppc.pontos)::INT AS total_pontos
    FROM pontos_por_corrida ppc
    JOIN grande_premio gp ON ppc.grande_premio_id = gp.id
    JOIN piloto p ON p.id = ppc.piloto_id
    WHERE p.nome = piloto_nome AND gp.ano = ano_temporada
    GROUP BY ppc.piloto_id, gp.ano, p.nome;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM pontos_piloto_ano('Fernando Alonso', 2022);

CREATE OR REPLACE FUNCTION podium_ano(ano_temporada INT)
RETURNS TABLE (
    posicao INT,
    piloto_nome VARCHAR,
    total_pontos INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        RANK() OVER (ORDER BY SUM(ppc.pontos) DESC)::INT AS posicao,
        p.nome,
        SUM(ppc.pontos)::INT AS total_pontos
    FROM pontos_por_corrida ppc
    JOIN grande_premio gp ON ppc.grande_premio_id = gp.id
    JOIN piloto p ON ppc.piloto_id = p.id
    WHERE gp.ano = ano_temporada
    GROUP BY p.nome
    ORDER BY total_pontos DESC
  	limit 3;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM podium_ano(2022);

CREATE OR REPLACE FUNCTION classificacao_geral_ano(ano_corrida INT)
RETURNS TABLE (
    piloto_id INT,
    nome VARCHAR,
    ano INT,
    total_pontos INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ppc.piloto_id,
        p.nome AS piloto_nome,
        gp.ano,
        SUM(ppc.pontos)::INT AS total_pontos
    FROM pontos_por_corrida ppc
    JOIN grande_premio gp ON ppc.grande_premio_id = gp.id
    JOIN piloto p ON ppc.piloto_id = p.id
    WHERE gp.ano = ano_corrida
    GROUP BY ppc.piloto_id, gp.ano, p.nome
    ORDER BY total_pontos DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM classificacao_geral_ano(2022);

CREATE OR REPLACE FUNCTION top3_gp_ppc_trigger()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO pontos_por_corrida(grande_premio_id, piloto_id, pontos) values (NEW.id, NEW.campeao, 3);
	INSERT INTO pontos_por_corrida(grande_premio_id, piloto_id, pontos) values (NEW.id, NEW.vice, 2);
	INSERT INTO pontos_por_corrida(grande_premio_id, piloto_id, pontos) values (NEW.id, NEW.terceiro, 1);
    RETURN NULL; -- Retorno NULL para triggers AFTER
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER top3_gp_ppc
AFTER INSERT
ON grande_premio
FOR EACH ROW
EXECUTE FUNCTION top3_gp_ppc_trigger();

INSERT INTO grande_premio(pista_id,ano,campeao,vice,terceiro) values (1,2024,6,2,8);

ALTER TABLE equipes
ADD COLUMN pilotos_ativos INT DEFAULT 0;

UPDATE equipes e
SET pilotos_ativos = (
    SELECT COUNT(*)
    FROM piloto p
    WHERE p.equipe_id = e.id); -- Relaciona os pilotos à equipe

CREATE OR REPLACE FUNCTION pilotos_ativos_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        -- Reduzir a quantidade de pilotos ativos
        UPDATE equipes
        SET pilotos_ativos = pilotos_ativos - 1
        WHERE id = OLD.equipe_id;

    ELSIF TG_OP = 'INSERT' THEN
        -- Incrementar a quantidade de pilotos ativos
        UPDATE equipes
        SET pilotos_ativos = pilotos_ativos + 1
        WHERE id = NEW.equipe_id;
    END IF;

    RETURN NULL; -- Retorno NULL para triggers AFTER
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER pilotos_ativos
AFTER INSERT OR DELETE
ON piloto
FOR EACH ROW
EXECUTE FUNCTION pilotos_ativos_trigger();

CREATE OR REPLACE FUNCTION limitar_tamanho_equipe_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se a equipe já tem 2 pilotos
    IF (SELECT pilotos_ativos FROM equipes WHERE id = NEW.equipe_id) >= 2 THEN
        -- Definir equipe_id como NULL
        NEW.equipe_id = NULL;
    END IF;

    RETURN NEW; -- Retornar a nova linha modificada
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER limitar_tamanho_equipe
BEFORE INSERT
ON piloto
FOR EACH ROW
EXECUTE FUNCTION limitar_tamanho_equipe_trigger();

CREATE OR REPLACE VIEW equipes_temporada_atual
 AS
 SELECT 
    e.id AS equipe_id,
    e.nome AS equipe_nome,
    p1.nome AS piloto1_nome,
    p2.nome AS piloto2_nome
FROM 
    equipes e
LEFT JOIN LATERAL (
    SELECT nome 
    FROM piloto p 
    WHERE p.equipe_id = e.id
    ORDER BY p.id
    LIMIT 1
) p1 ON TRUE
LEFT JOIN LATERAL (
    SELECT nome 
    FROM piloto p 
    WHERE p.equipe_id = e.id
    ORDER BY p.id
    OFFSET 1
    LIMIT 1
) p2 ON TRUE;

CREATE OR REPLACE VIEW podio_todas_corridas
 AS
	SELECT
	    gp.id AS grande_premio_id,
	    pistas.nome,
	    p.nome AS piloto_nome,
	    CASE 
	        WHEN ppc.pontos = 3 THEN '1º lugar'
	        WHEN ppc.pontos = 2 THEN '2º lugar'
	        WHEN ppc.pontos = 1 THEN '3º lugar'
	    END AS posicao
	FROM grande_premio gp
	JOIN pontos_por_corrida ppc ON gp.id = ppc.grande_premio_id
	JOIN piloto p ON ppc.piloto_id = p.id
	JOIN pistas ON pistas.id = gp.pista_id
	WHERE ppc.pontos IN (1, 2, 3)
	order by grande_premio_id, posicao;

ALTER TABLE grande_premio 
	add column pole_position integer references piloto(id);

INSERT INTO public.grande_premio (pista_id, ano, campeao, vice, terceiro, pole_position)
VALUES
(1, 2021, 1, 2, 3, 4),
(2, 2021, 4, 5, 6, 5),
(3, 2021, 2, 8, 9, 9),
(4, 2021, 3, 6, 7, 8),
(5, 2021, 5, 1, 2, 5),
(1, 2022, 3, 6, 7, 7),
(2, 2022, 1, 9, 10, 1),
(3, 2022, 4, 6, 3, 6),
(4, 2022, 5, 7, 8, 9),
(5, 2022, 10, 3, 1, 1),
(1, 2023, 7, 2, 5, 5),
(2, 2023, 8, 9, 10, 1),
(3, 2023, 1, 6, 4, 6),
(4, 2023, 7, 10, 2, 7),
(5, 2023, 6, 8, 7, 8),
(1, 2024, 4, 7, 9, 10),
(2, 2024, 2, 3, 5, 3),
(3, 2024, 8, 3, 6, 4),
(4, 2024, 9, 10, 7, 7),
(5, 2024, 9, 5, 2, 9);

create or replace view top_pole_position
	as
	WITH pole_positions_ranking AS (
	    SELECT 
	        piloto.nome AS piloto_nome,
	        COUNT(gp.pole_position) AS pole_positions,
	        pistas.nome AS pista_nome,
	        RANK() OVER (PARTITION BY pistas.id ORDER BY COUNT(gp.pole_position) DESC) AS ranking
	    FROM grande_premio gp 
	    JOIN piloto ON piloto.id = gp.pole_position
	    JOIN pistas ON pistas.id = gp.pista_id
	    GROUP BY pistas.id, pistas.nome, piloto.nome
	)
	SELECT piloto_nome, pole_positions, pista_nome
	FROM pole_positions_ranking
	WHERE ranking = 1
	ORDER BY pole_positions desc;


