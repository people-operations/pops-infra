-- =====================================================================
-- SCHEMA & DATA · MySQL
-- =====================================================================
DROP DATABASE IF EXISTS company_pops;
CREATE DATABASE IF NOT EXISTS company_pops;
USE company_pops;

-- =========================
-- Tabelas de domínio
-- =========================
CREATE TABLE department (
  id	INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(60) NOT NULL,
  `description`	VARCHAR(100)
);

CREATE TABLE `type` (
  id	INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(60) NOT NULL,
  `description`	VARCHAR(100)
);

CREATE TABLE `status` (
  id 	INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(60) NOT NULL,
  `description`	VARCHAR(100)
);

-- =========================
-- Pessoas e atributos
-- =========================
CREATE TABLE person (
  id	INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(120) NOT NULL,
  email	VARCHAR(100) NOT NULL UNIQUE,
  `password`	VARCHAR(50) NOT NULL,
  cpf	CHAR(11) NOT NULL,
  cnpj CHAR(14),
  linkedin	VARCHAR(100),
  hiring_date	DATE NOT NULL,
  dismissal_date	DATE NOT NULL,
  `active`	BOOLEAN NOT NULL DEFAULT TRUE,
  contract_type	ENUM('CLT','PJ','ESTAGIO') NOT NULL
);

CREATE TABLE adress (
  id	INT PRIMARY KEY AUTO_INCREMENT,
  person_id	INT NOT NULL,
  zip_code	CHAR(8),
  neighborhood	VARCHAR(120),
  street	VARCHAR(160),
  street_number	INT(6),
  CONSTRAINT fk_address_person
    FOREIGN KEY (person_id) REFERENCES person(id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- =========================
-- Habilidades
-- =========================
CREATE TABLE skills (
  id	INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(60) NOT NULL,
  `description`	VARCHAR(100)
);

CREATE TABLE skills_association (
  id	INT PRIMARY KEY AUTO_INCREMENT,
  person_id	INT NOT NULL,
  skills_id	INT NOT NULL,
  UNIQUE KEY uq_person_skill (person_id, skills_id),
  CONSTRAINT fk_ps_person  FOREIGN KEY (person_id) REFERENCES person(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ps_skill   FOREIGN KEY (skills_id) REFERENCES skills(id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- =========================
-- Carreira
-- =========================
CREATE TABLE career_level (
  id	INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(60) NOT NULL,
  `description`	VARCHAR(100),
  `active`	BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE job_position (
  id	INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(60) NOT NULL,
  `description`	VARCHAR(100),
  `active`	BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE position_history (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  person_id     INT NOT NULL,
  level_id      INT NOT NULL,
  position_id   INT NOT NULL,
  started_at    DATE NOT NULL,
  ended_at      DATE,
  salary        DECIMAL(12,2),
  CONSTRAINT fk_ph_person   FOREIGN KEY (person_id)  REFERENCES person(id),
  CONSTRAINT fk_ph_level    FOREIGN KEY (level_id)   REFERENCES career_level(id),
  CONSTRAINT fk_ph_position FOREIGN KEY (position_id) REFERENCES job_position(id)
);

-- =========================
-- Projetos / Times
-- =========================
CREATE TABLE project (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(60) NOT NULL,
  `description`	VARCHAR(100),
  budget        DOUBLE,
  start_date    DATE,
  end_date      DATE,
  fk_type       INT NOT NULL,
  fk_status     INT NOT NULL,
  fk_area       INT NOT NULL,
  CONSTRAINT fk_proj_type   FOREIGN KEY (fk_type)   REFERENCES type(id),
  CONSTRAINT fk_proj_status FOREIGN KEY (fk_status) REFERENCES status(id),
  CONSTRAINT fk_proj_area   FOREIGN KEY (fk_area)   REFERENCES department(id)
) ENGINE=InnoDB;

CREATE TABLE team (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  `name`	VARCHAR(60) NOT NULL,
  `description`	VARCHAR(100),
  sprint_duration INT NOT NULL,
  fk_approver   INT,
  fk_project    INT NOT NULL,
  CONSTRAINT fk_team_project  FOREIGN KEY (fk_project) REFERENCES project(id),
  CONSTRAINT fk_team_approver FOREIGN KEY (fk_approver) REFERENCES person(id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- Formação define “vagas”/papéis por time e nível
CREATE TABLE formation (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  started_at    DATE,
  ended_at      DATE,
  allocated_hours DECIMAL(6,2),
  team_id       INT NOT NULL,
  position_id   INT NOT NULL,
  level_id      INT NOT NULL,
  CONSTRAINT fk_form_team     FOREIGN KEY (team_id)     REFERENCES team(id),
  CONSTRAINT fk_form_position FOREIGN KEY (position_id) REFERENCES job_position(id),
  CONSTRAINT fk_form_level    FOREIGN KEY (level_id)    REFERENCES career_level(id)
);

-- Alocação de pessoas nas formações
CREATE TABLE allocation_history (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  started_at    DATE NOT NULL,
  ended_at      DATE,
  person_id     INT NOT NULL,
  formation_id  INT NOT NULL,
  CONSTRAINT fk_alloc_person    FOREIGN KEY (person_id)    REFERENCES person(id),
  CONSTRAINT fk_alloc_formation FOREIGN KEY (formation_id) REFERENCES formation(id)
);

-- ============================================================
-- CARGA DE DADOS
-- ============================================================ 

-- Domínios
INSERT INTO department (`name`,`description`) VALUES
('Produtos da Financeira','Soluções de software para área financeira'),
('Marketing','Alcance de novos clientes'),
('RH','Recrutamento e Seleção de Pessoas');

INSERT INTO `type` (`name`,`description`) VALUES
('Benfeitoria','Benfeitoria ao negócio e ao cliente'),
('Operacional','Ajuste de pontos técnicos para melhora da performance'),
('Compliance','Regra governamental');

INSERT INTO `status` (`name`,`description`) VALUES
('Em Planejamento','Escopo sendo montado'),
('Em progresso','Executando o que foi planejado'),
('Completo', null),
('Em espera', null);

-- Pessoas
INSERT INTO person
(`name`, email, `password`, cpf, cnpj, linkedin, hiring_date, dismissal_date, `active`, contract_type)
VALUES
('Ana Silva','ana@peopleops.com','hash','13145248367',NULL,'/in/anasilva','2023-03-01','9999-12-31',TRUE,'CLT'),
('Bruno Souza','bruno@peopleops.com','hash','24376868604',NULL,'/in/brunosouza','2022-10-10','9999-12-31',TRUE,'CLT'),
('Carla Mendes','carla@peopleops.com','hash','44988286827','26857572000185','/in/carlam','2021-05-05','9999-12-31',TRUE,'PJ'),
('Diego Lima','diego@peopleops.com','hash','49466325221',NULL,'/in/diegolima','2020-01-15','2024-06-30',FALSE,'CLT');

-- Endereços
INSERT INTO adress (person_id, zip_code, neighborhood, street, street_number) VALUES
(1,'01310100','Bela Vista','Avenida Paulista',1000),
(2,'01504000','Paraíso','Rua Vergueiro',1000),
(3,'05013001','Perdizes','Rua Cardoso de Almeida',1000),
(4,'05426200','Pinheiros','Avenida Brigadeiro Faria Lima',400);

-- Skills
INSERT INTO skills (`name`,`description`) VALUES
('Java','Programação backend'),
('SQL','Modelagem e análise de dados'),
('React','Programação web frontend'),
('QA','Teste de qualidade'),
('Trabalho em Equipe', null);

INSERT INTO skills_association (person_id, skills_id) VALUES
(1,1),(1,2),
(2,2),(2,3),
(3,4),
(4,5);

-- Carreira
INSERT INTO career_level (`name`,`description`,`active`) VALUES
('Junior','Baixa experiência',TRUE),
('Pleno','Média experiência',TRUE),
('Sênior','Grande experiência',TRUE);

INSERT INTO job_position (`name`,`description`,`active`) VALUES
('Desenvolvedor Backend','APIs/Services',TRUE),
('Desenvolvedor Frontend','Web',TRUE),
('Product Owner','Product management',TRUE),
('Engenheiro de QA','Garantia de qualidade',TRUE);

INSERT INTO position_history (person_id, level_id, position_id, started_at, ended_at, salary) VALUES
(1,3,1,'2023-03-01',NULL,14000.00),
(2,2,2,'2022-10-10',NULL,11000.00),
(3,3,3,'2021-05-05',NULL,20000.00),
(4,1,4,'2020-01-15','2024-06-30',3000.00);

-- Projetos
INSERT INTO project
(`name`,`description`, budget, start_date, end_date, fk_type, fk_status, fk_area)
VALUES
('Plataforma de Investimentos X','Nova plataforma de investimentos',500000,'2024-01-15',NULL, 1,2,1),
('Website MKT','Redesign do site de Marketing', 80000,'2024-07-01',NULL,  1,1,2);

-- Times
INSERT INTO team
(`name`,`description`, sprint_duration, fk_approver, fk_project)
VALUES
('Squad Alpha','Time da Plataforma de Investimentos X',14,3,1),
('Web Team','Time do Redesign do site de Marketing',14,2,2);

-- Formaçōes (vagas por time/nível)
INSERT INTO formation (started_at, ended_at, allocated_hours, team_id, position_id, level_id) VALUES
('2024-01-15',NULL,160, 1, 1, 3), 
('2024-01-15',NULL,160, 1, 2, 2),
('2024-01-15',NULL, 80, 1, 3, 3),
('2024-03-01','2024-06-30',160, 1, 4, 1),
('2024-07-01',NULL,160, 2, 2, 2);

-- Alocações
INSERT INTO allocation_history (started_at, ended_at, person_id, formation_id) VALUES
('2024-01-15',NULL, 1, 1),                
('2024-01-15','2024-06-30', 2, 2),
('2024-07-01',NULL, 2, 5),
('2024-01-15',NULL, 3, 3),
('2024-03-01','2024-06-30', 4, 4);

-- ============================================================
-- SELECTS - VALIDAÇÃO DE RELACIONAMENTO
-- ============================================================ 

-- Pessoas + Endereço
SELECT p.id, p.`name` AS person_name, p.email, p.active,
       a.zip_code, a.neighborhood, a.street, a.street_number
FROM person p
LEFT JOIN adress a ON a.person_id = p.id
ORDER BY p.id;

-- Skills por pessoa
SELECT p.`name` AS person_name, s.`name` AS skill_name
FROM skills_association sa
JOIN person p ON p.id = sa.person_id
JOIN skills s ON s.id = sa.skills_id
ORDER BY p.id, s.`name`;

-- Posição/cargo atual por pessoa (ended_at IS NULL)
SELECT p.`name` AS person_name,
       jp.`name` AS job_role,
       cl.`name` AS career_level,
       ph.salary, ph.started_at
FROM position_history ph
JOIN person p   ON p.id = ph.person_id
JOIN job_position jp ON jp.id = ph.position_id
JOIN career_level cl ON cl.id = ph.level_id
WHERE ph.ended_at IS NULL
ORDER BY p.id;

-- Projetos com departamento, tipo e status
SELECT pr.id, pr.`name` AS project_name, pr.start_date, pr.end_date, pr.budget,
       d.`name` AS department,
       t.`name` AS project_type,
       st.`name` AS project_status
FROM project pr
JOIN department d ON d.id = pr.fk_area
JOIN `type` t     ON t.id = pr.fk_type
JOIN `status` st  ON st.id = pr.fk_status
ORDER BY pr.id;

-- Times com projeto e aprovador
SELECT tm.id, tm.`name` AS team_name, tm.sprint_duration,
       pr.`name` AS project_name,
       p.`name`  AS approver_name
FROM team tm
JOIN project pr ON pr.id = tm.fk_project
LEFT JOIN person p ON p.id = tm.fk_approver
ORDER BY tm.id;

-- Formaçōes (vaga por time) com papel e nível
SELECT f.id, tm.`name` AS team_name,
       jp.`name` AS job_role, cl.`name` AS career_level,
       f.started_at, f.ended_at, f.allocated_hours
FROM formation f
JOIN team tm        ON tm.id = f.team_id
JOIN job_position jp ON jp.id = f.position_id
JOIN career_level cl ON cl.id = f.level_id
ORDER BY f.team_id, f.id;

-- Alocações atuais (quem está alocado agora)
SELECT ah.id, p.`name` AS person_name,
       tm.`name` AS team_name, pr.`name` AS project_name,
       jp.`name` AS job_role, cl.`name` AS career_level,
       ah.started_at, ah.ended_at
FROM allocation_history ah
JOIN formation f   ON f.id = ah.formation_id
JOIN team tm       ON tm.id = f.team_id
JOIN project pr    ON pr.id = tm.fk_project
JOIN person p      ON p.id = ah.person_id
JOIN job_position jp ON jp.id = f.position_id
JOIN career_level cl ON cl.id = f.level_id
WHERE ah.ended_at IS NULL
ORDER BY tm.id, p.id;

-- Quadro do projeto (quem está em cada projeto, histórico)
SELECT pr.`name` AS project_name, tm.`name` AS team_name,
       p.`name`  AS person_name, jp.`name` AS job_role, cl.`name` AS level,
       ah.started_at, ah.ended_at
FROM project pr
JOIN team tm       ON tm.fk_project = pr.id
JOIN formation f   ON f.team_id = tm.id
JOIN allocation_history ah ON ah.formation_id = f.id
JOIN person p      ON p.id = ah.person_id
JOIN job_position jp ON jp.id = f.position_id
JOIN career_level cl ON cl.id = f.level_id
ORDER BY pr.id, tm.id, p.id, ah.started_at;

-- Capacidade atual por time (headcount ativo)
SELECT tm.`name` AS team_name, COUNT(*) AS active_allocations
FROM allocation_history ah
JOIN formation f ON f.id = ah.formation_id
JOIN team tm     ON tm.id = f.team_id
WHERE ah.ended_at IS NULL
GROUP BY tm.`name`
ORDER BY tm.`name`;

-- Pessoas ativas x status de emprego
SELECT p.id, p.`name`, p.active, p.hiring_date, p.dismissal_date
FROM person p
ORDER BY p.id;

-- ============================================================
-- PADRONIZAÇÃO DE DADOS
-- ============================================================ 
/* ============================================================
   FUNÇÃO: MAIÚSCULO + REMOVER ACENTOS
   ============================================================ */
DROP FUNCTION IF EXISTS fn_unaccent_upper;
DELIMITER $$
CREATE FUNCTION fn_unaccent_upper(s VARCHAR(1000))
RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
  IF s IS NULL THEN RETURN NULL; END IF;
  SET s = UPPER(s);
  -- A
  SET s = REPLACE(s,'Á','A'); SET s = REPLACE(s,'À','A'); SET s = REPLACE(s,'Â','A'); SET s = REPLACE(s,'Ã','A'); SET s = REPLACE(s,'Ä','A');
  -- E
  SET s = REPLACE(s,'É','E'); SET s = REPLACE(s,'È','E'); SET s = REPLACE(s,'Ê','E'); SET s = REPLACE(s,'Ë','E');
  -- I
  SET s = REPLACE(s,'Í','I'); SET s = REPLACE(s,'Ì','I'); SET s = REPLACE(s,'Î','I'); SET s = REPLACE(s,'Ï','I');
  -- O
  SET s = REPLACE(s,'Ó','O'); SET s = REPLACE(s,'Ò','O'); SET s = REPLACE(s,'Ô','O'); SET s = REPLACE(s,'Õ','O'); SET s = REPLACE(s,'Ö','O');
  -- U
  SET s = REPLACE(s,'Ú','U'); SET s = REPLACE(s,'Ù','U'); SET s = REPLACE(s,'Û','U'); SET s = REPLACE(s,'Ü','U');
  -- Outros
  SET s = REPLACE(s,'Ç','C'); SET s = REPLACE(s,'Ñ','N'); SET s = REPLACE(s,'Ý','Y');
  RETURN s;
END$$
DELIMITER ;

/* ============================================================
   TRIGGERS: PADRONIZAÇÃO POR TABELA
   (BI = BEFORE INSERT, BU = BEFORE UPDATE)
   ============================================================ */

-- department
DROP TRIGGER IF EXISTS trg_department_bi;
DROP TRIGGER IF EXISTS trg_department_bu;
DELIMITER $$
CREATE TRIGGER trg_department_bi BEFORE INSERT ON department
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
CREATE TRIGGER trg_department_bu BEFORE UPDATE ON department
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
DELIMITER ;

-- type
DROP TRIGGER IF EXISTS trg_type_bi;
DROP TRIGGER IF EXISTS trg_type_bu;
DELIMITER $$
CREATE TRIGGER trg_type_bi BEFORE INSERT ON `type`
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
CREATE TRIGGER trg_type_bu BEFORE UPDATE ON `type`
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
DELIMITER ;

-- status
DROP TRIGGER IF EXISTS trg_status_bi;
DROP TRIGGER IF EXISTS trg_status_bu;
DELIMITER $$
CREATE TRIGGER trg_status_bi BEFORE INSERT ON `status`
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
CREATE TRIGGER trg_status_bu BEFORE UPDATE ON `status`
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
DELIMITER ;

-- person
DROP TRIGGER IF EXISTS trg_person_bi;
DROP TRIGGER IF EXISTS trg_person_bu;
DELIMITER $$
CREATE TRIGGER trg_person_bi BEFORE INSERT ON person
FOR EACH ROW
BEGIN
  SET NEW.`name`   = fn_unaccent_upper(NEW.`name`);
  SET NEW.email    = UPPER(NEW.email); -- remova se não quiser e-mail em maiúsculo
  -- normalizar documentos (somente dígitos)
  SET NEW.cpf      = REGEXP_REPLACE(NEW.cpf,  '[^0-9]', '');
  SET NEW.cnpj     = REGEXP_REPLACE(NEW.cnpj, '[^0-9]', '');
  -- datas já são DATE; mantemos padrão ISO
END$$
CREATE TRIGGER trg_person_bu BEFORE UPDATE ON person
FOR EACH ROW
BEGIN
  SET NEW.`name`   = fn_unaccent_upper(NEW.`name`);
  SET NEW.email    = UPPER(NEW.email);
  SET NEW.cpf      = REGEXP_REPLACE(NEW.cpf,  '[^0-9]', '');
  SET NEW.cnpj     = REGEXP_REPLACE(NEW.cnpj, '[^0-9]', '');
END$$
DELIMITER ;

-- adress (endereço)
DROP TRIGGER IF EXISTS trg_adress_bi;
DROP TRIGGER IF EXISTS trg_adress_bu;
DELIMITER $$
CREATE TRIGGER trg_adress_bi BEFORE INSERT ON adress
FOR EACH ROW
BEGIN
  SET NEW.neighborhood = fn_unaccent_upper(NEW.neighborhood);
  SET NEW.street       = fn_unaccent_upper(NEW.street);
  SET NEW.zip_code     = REGEXP_REPLACE(NEW.zip_code, '[^0-9]', '');
END$$
CREATE TRIGGER trg_adress_bu BEFORE UPDATE ON adress
FOR EACH ROW
BEGIN
  SET NEW.neighborhood = fn_unaccent_upper(NEW.neighborhood);
  SET NEW.street       = fn_unaccent_upper(NEW.street);
  SET NEW.zip_code     = REGEXP_REPLACE(NEW.zip_code, '[^0-9]', '');
END$$
DELIMITER ;

-- skills
DROP TRIGGER IF EXISTS trg_skills_bi;
DROP TRIGGER IF EXISTS trg_skills_bu;
DELIMITER $$
CREATE TRIGGER trg_skills_bi BEFORE INSERT ON skills
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
CREATE TRIGGER trg_skills_bu BEFORE UPDATE ON skills
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
DELIMITER ;

-- career_level
DROP TRIGGER IF EXISTS trg_career_level_bi;
DROP TRIGGER IF EXISTS trg_career_level_bu;
DELIMITER $$
CREATE TRIGGER trg_career_level_bi BEFORE INSERT ON career_level
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
CREATE TRIGGER trg_career_level_bu BEFORE UPDATE ON career_level
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
DELIMITER ;

-- job_position
DROP TRIGGER IF EXISTS trg_job_position_bi;
DROP TRIGGER IF EXISTS trg_job_position_bu;
DELIMITER $$
CREATE TRIGGER trg_job_position_bi BEFORE INSERT ON job_position
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
CREATE TRIGGER trg_job_position_bu BEFORE UPDATE ON job_position
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
DELIMITER ;

-- project
DROP TRIGGER IF EXISTS trg_project_bi;
DROP TRIGGER IF EXISTS trg_project_bu;
DELIMITER $$
CREATE TRIGGER trg_project_bi BEFORE INSERT ON project
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
CREATE TRIGGER trg_project_bu BEFORE UPDATE ON project
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
DELIMITER ;

-- team
DROP TRIGGER IF EXISTS trg_team_bi;
DROP TRIGGER IF EXISTS trg_team_bu;
DELIMITER $$
CREATE TRIGGER trg_team_bi BEFORE INSERT ON team
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
CREATE TRIGGER trg_team_bu BEFORE UPDATE ON team
FOR EACH ROW
BEGIN
  SET NEW.`name` = fn_unaccent_upper(NEW.`name`);
  SET NEW.`description` = fn_unaccent_upper(NEW.`description`);
END$$
DELIMITER ;

/* ============================================================
   BACKFILL: NORMALIZAR O QUE JÁ ESTÁ CADASTRADO
   ============================================================ */
-- department / type / status
UPDATE department   SET `name`=fn_unaccent_upper(`name`), `description`=fn_unaccent_upper(`description`) WHERE id >= 1;
UPDATE `type`       SET `name`=fn_unaccent_upper(`name`), `description`=fn_unaccent_upper(`description`) WHERE id >= 1;
UPDATE `status`     SET `name`=fn_unaccent_upper(`name`), `description`=fn_unaccent_upper(`description`) WHERE id >= 1;

UPDATE person
SET `name`=fn_unaccent_upper(`name`),
    email=UPPER(email),
    cpf=REGEXP_REPLACE(cpf,'[^0-9]',''),
    cnpj=REGEXP_REPLACE(cnpj,'[^0-9]','')
WHERE id >= 1;

UPDATE adress
SET neighborhood=fn_unaccent_upper(neighborhood),
    street=fn_unaccent_upper(street),
    zip_code=REGEXP_REPLACE(zip_code,'[^0-9]','')
WHERE id >= 1;

UPDATE skills       SET `name`=fn_unaccent_upper(`name`), `description`=fn_unaccent_upper(`description`) WHERE id >= 1;
UPDATE career_level SET `name`=fn_unaccent_upper(`name`), `description`=fn_unaccent_upper(`description`) WHERE id >= 1;
UPDATE job_position SET `name`=fn_unaccent_upper(`name`), `description`=fn_unaccent_upper(`description`) WHERE id >= 1;
UPDATE project      SET `name`=fn_unaccent_upper(`name`), `description`=fn_unaccent_upper(`description`) WHERE id >= 1;
UPDATE team         SET `name`=fn_unaccent_upper(`name`), `description`=fn_unaccent_upper(`description`) WHERE id >= 1;

/* ============================================================
   VIEWS PARA SELECTS FORMATADOS
   - Datas em 'YYYY-MM-DD'
   - CEP/CPF/CNPJ mascarados
   ============================================================ */

-- Pessoas (com máscaras e datas ISO)
DROP VIEW IF EXISTS vw_person_formatted;
CREATE VIEW vw_person_formatted AS
SELECT
  p.id,
  p.`name`                                 AS person_name,
  UPPER(p.email)                           AS email,
  -- máscaras
  CASE WHEN CHAR_LENGTH(p.cpf)=11
       THEN CONCAT(SUBSTRING(p.cpf,1,3),'.',SUBSTRING(p.cpf,4,3),'.',SUBSTRING(p.cpf,7,3),'-',SUBSTRING(p.cpf,10,2))
       ELSE p.cpf END                      AS cpf_mask,
  CASE WHEN p.cnpj IS NULL OR CHAR_LENGTH(p.cnpj)<>14 THEN NULL
       ELSE CONCAT(SUBSTRING(p.cnpj,1,2),'.',SUBSTRING(p.cnpj,3,3),'.',SUBSTRING(p.cnpj,6,3),'/',SUBSTRING(p.cnpj,9,4),'-',SUBSTRING(p.cnpj,13,2))
  END                                      AS cnpj_mask,
  DATE_FORMAT(p.hiring_date,    '%Y-%m-%d') AS hiring_date,
  DATE_FORMAT(p.dismissal_date, '%Y-%m-%d') AS dismissal_date,
  p.`active`,
  p.contract_type
FROM person p;

-- Endereço (com CEP formatado)
DROP VIEW IF EXISTS vw_address_formatted;
CREATE VIEW vw_address_formatted AS
SELECT
  a.id,
  a.person_id,
  CONCAT(a.street, ', ', a.street_number, ' - ', a.neighborhood) AS full_address,
  CASE WHEN CHAR_LENGTH(a.zip_code)=8
       THEN CONCAT(SUBSTRING(a.zip_code,1,5), '-', SUBSTRING(a.zip_code,6,3))
       ELSE a.zip_code END AS zip_code,
  a.street, a.street_number, a.neighborhood
FROM adress a;

-- Projetos (datas ISO) + domínios
DROP VIEW IF EXISTS vw_project_formatted;
CREATE VIEW vw_project_formatted AS
SELECT
  pr.id,
  pr.`name` AS project_name,
  pr.`description`,
  pr.budget,
  DATE_FORMAT(pr.start_date,'%Y-%m-%d') AS start_date,
  DATE_FORMAT(pr.end_date,  '%Y-%m-%d') AS end_date,
  d.`name`  AS department,
  t.`name`  AS project_type,
  st.`name` AS project_status
FROM project pr
JOIN department d ON d.id = pr.fk_area
JOIN `type` t     ON t.id = pr.fk_type
JOIN `status` st  ON st.id = pr.fk_status;



/* ============================================================
   EXEMPLOS DE SELECTS USANDO AS VIEWS
   ============================================================ */

-- Pessoas + endereço (já normalizado, com máscaras)
SELECT p.id, p.person_name, p.email, p.cpf_mask, p.cnpj_mask,
       a.zip_code AS cep, a.full_address
FROM vw_person_formatted p
LEFT JOIN vw_address_formatted a ON a.person_id = p.id
ORDER BY p.id;

-- Projetos
SELECT * FROM vw_project_formatted ORDER BY id;

-- Quadro atual dos projetos (datas em ISO; nomes já padronizados)
SELECT
  pr.project_name, tm.`name` AS team_name, p.person_name,
  jp.`name` AS job_role, cl.`name` AS career_level,
  DATE_FORMAT(ah.started_at, '%Y-%m-%d') AS started_at,
  DATE_FORMAT(ah.ended_at,   '%Y-%m-%d') AS ended_at
FROM allocation_history ah
JOIN formation f    ON f.id  = ah.formation_id
JOIN team tm        ON tm.id = f.team_id
JOIN project pr0    ON pr0.id = tm.fk_project
JOIN vw_project_formatted pr ON pr.id = pr0.id
JOIN vw_person_formatted  p  ON p.id  = ah.person_id
JOIN job_position jp  ON jp.id = f.position_id
JOIN career_level cl  ON cl.id = f.level_id
WHERE ah.ended_at IS NULL
ORDER BY pr.id, tm.id, p.id;


