-- =========================================================
-- Script completo para criação do banco e autenticação MySQL
-- Projeto: PeopleOps Project Manager API
-- =========================================================
DROP DATABASE IF EXISTS popsdb;

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS popsdb
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Usar o banco de dados
USE popsdb;

-- =========================================================
-- Tabelas de domínio e referência
-- =========================================================

CREATE TABLE IF NOT EXISTS skill_type (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS project_type (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS project_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- Entidades principais
-- =========================================================

CREATE TABLE IF NOT EXISTS skill (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    skill_type_id BIGINT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (skill_type_id) REFERENCES skill_type(id)
);

CREATE TABLE IF NOT EXISTS project (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    project_type_id BIGINT,
    description VARCHAR(1000),
    project_status_id BIGINT NOT NULL,
    budget DECIMAL(15,2),
    start_date DATE,
    end_date DATE,
    area VARCHAR(100),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_type_id) REFERENCES project_type(id),
    FOREIGN KEY (project_status_id) REFERENCES project_status(id)
);

CREATE TABLE IF NOT EXISTS project_skills (
    project_id BIGINT NOT NULL,
    skill_id BIGINT NOT NULL,
    PRIMARY KEY (project_id, skill_id),
    FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skill(id) ON DELETE CASCADE
);

-- =========================================================
-- Tabelas relacionadas à gestão de equipes
-- =========================================================

CREATE TABLE IF NOT EXISTS team (
    id BIGINT NOT NULL AUTO_INCREMENT,
    fk_approver BIGINT NULL DEFAULT NULL,
    description VARCHAR(100) NULL DEFAULT NULL,
    name VARCHAR(60) NOT NULL,
    fk_project BIGINT NOT NULL,
    sprint_duration INT NOT NULL,
    status TINYINT(1) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (fk_project) REFERENCES project(id)
);

CREATE TABLE IF NOT EXISTS allocation (
    id BIGINT NOT NULL AUTO_INCREMENT,
    allocated_hours INT NOT NULL,
    fk_person BIGINT NOT NULL,
    position VARCHAR(255) NOT NULL,
    started_at DATE NOT NULL,
    fk_team BIGINT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_allocation_team FOREIGN KEY (fk_team) REFERENCES team (id)
);

CREATE TABLE IF NOT EXISTS allocation_history (
    id BIGINT NOT NULL AUTO_INCREMENT,
    allocated_hours INT NOT NULL,
    ended_at DATE NOT NULL,
    person_id BIGINT NOT NULL,
    position VARCHAR(255) NOT NULL,
    started_at DATE NOT NULL,
    fk_person BIGINT NOT NULL,
    fk_team BIGINT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_allocation_history_team FOREIGN KEY (fk_team) REFERENCES team (id)
);

-- =========================================================
-- Dados iniciais
-- =========================================================

INSERT INTO skill_type (name, description) VALUES
    ('HARD', 'Habilidades técnicas e conhecimentos específicos'),
    ('SOFT', 'Habilidades comportamentais e interpessoais'),
    ('MANAGEMENT', 'Habilidades de gestão e liderança'),
    ('ANALYTICS', 'Habilidades de análise de dados e métricas');

INSERT INTO project_type (name, description) VALUES
    ('DESENVOLVIMENTO', 'Projetos de desenvolvimento de software'),
    ('WEB', 'Projetos de desenvolvimento web'),
    ('MOBILE', 'Projetos de desenvolvimento mobile'),
    ('INFRAESTRUTURA', 'Projetos de infraestrutura e DevOps'),
    ('BI', 'Projetos de Business Intelligence e Analytics'),
    ('CONSULTORIA', 'Projetos de consultoria e análise');

INSERT INTO project_status (name, description) VALUES
    ('EM PLANEJAMENTO', 'Projeto em fase de planejamento'),
    ('EM PROGRESSO', 'Projeto em andamento'),
    ('EM ESPERA', 'Projeto pausado temporariamente'),
    ('CONCLUÍDO', 'Projeto concluído com sucesso'),
    ('CANCELADO', 'Projeto cancelado');

INSERT INTO skill (name, description, skill_type_id) VALUES
    ('Java', 'Linguagem de programação Java', 1),
    ('Kotlin', 'Linguagem de programação Kotlin', 1),
    ('Spring Boot', 'Framework Spring Boot para desenvolvimento de APIs', 1),
    ('MySQL', 'Sistema de gerenciamento de banco de dados MySQL', 1),
    ('Docker', 'Plataforma de containerização', 1),
    ('Git', 'Sistema de controle de versão', 1),
    ('React', 'Biblioteca JavaScript para interfaces de usuário', 1),
    ('Node.js', 'Runtime JavaScript para desenvolvimento backend', 1),
    ('Comunicação', 'Habilidade de comunicação interpessoal', 2),
    ('Liderança', 'Capacidade de liderar equipes', 2),
    ('Trabalho em Equipe', 'Habilidade de trabalhar colaborativamente', 2),
    ('Resolução de Problemas', 'Capacidade de analisar e resolver problemas', 2),
    ('Gestão de Tempo', 'Habilidade de gerenciar tempo e prioridades', 2),
    ('Adaptabilidade', 'Capacidade de se adaptar a mudanças', 2),
    ('Gestão de Projetos', 'Habilidade em gerenciar projetos', 3),
    ('Gestão de Equipes', 'Habilidade em gerenciar equipes', 3),
    ('Scrum', 'Metodologia ágil Scrum', 3),
    ('Power BI', 'Ferramenta de Business Intelligence', 4),
    ('Python', 'Linguagem de programação para análise de dados', 4),
    ('SQL Avançado', 'Consultas SQL complexas e otimização', 4);

-- ====== APENAS 5 PROJETOS ======
INSERT INTO project (name, project_type_id, description, project_status_id, budget, start_date, end_date, area) VALUES
    ( 'Sistema de Gestão de Projetos', 1,
      'Sistema completo para gerenciar projetos, equipes e recursos',
      2, 50000.00, '2024-09-01', '2024-12-31', 'Tecnologia' ),
    ( 'Portal do Cliente', 2,
      'Portal web responsivo para clientes acessarem serviços e informações',
      1, 75000.00, '2024-10-15', '2025-02-15', 'Tecnologia' ),
    ( 'App Mobile de Vendas', 3,
      'Aplicativo mobile para equipe de vendas externas',
      1, 120000.00, '2024-11-01', '2025-05-01', 'Tecnologia' ),
    ( 'Migração de Dados', 4,
      'Migração de dados legados para nova arquitetura',
      3, 30000.00, '2024-08-01', '2024-10-31', 'Infraestrutura' ),
    ( 'Dashboard Analytics', 5,
      'Dashboard para análise de métricas e KPIs',
      4, 25000.00, '2024-06-01', '2024-08-31', 'Analytics' );

-- =========================================================
-- TEAMS (alguns projetos com múltiplas squads)
-- =========================================================
INSERT INTO team (fk_approver, description, name, fk_project, sprint_duration, status)
VALUES
    (510,  'Squad A do Projeto 1', 'Team 1A', 1, 10, 1),
    (1362, 'Squad B do Projeto 1', 'Team 1B', 1, 10, 1),

    (2334, 'Squad única do Projeto 2', 'Team 2', 2, 10, 1),

    (510,  'Squad A do Projeto 3', 'Team 3A', 3, 10, 1),
    (2334, 'Squad B do Projeto 3', 'Team 3B', 3, 10, 1),

    (510,  'Squad única do Projeto 4', 'Team 4', 4, 10, 1),
    (1362, 'Squad única do Projeto 5', 'Team 5', 5, 10, 1);

-- =========================================================
-- ALLOCATIONS (5 pessoas por squad, times 1..5)
-- IDs de time e projeto ficam consistentes (1..5)
-- =========================================================
-- =========================================================
-- ALLOCATIONS — poucas pessoas em múltiplas squads
-- =========================================================
INSERT INTO allocation (allocated_hours, fk_person, position, started_at, fk_team)
VALUES
    -- Team 1A (Project 1)
    (37, 2475, 'Desenvolvedor Backend',  '2024-09-08', 1),
    (45, 2505, 'Desenvolvedor Frontend', '2024-09-07', 1),
    (31, 2517, 'Dev Mobile',             '2024-09-05', 1),

    -- Team 1B (Project 1)
    (40, 2475, 'Desenvolvedor Backend',  '2024-09-15', 2), -- mesma pessoa, squad diferente
    (39, 2466, 'QA Analyst',             '2024-09-11', 2),
    (37, 2512, 'Scrum Master',           '2024-09-09', 2),

    -- Team 2 (Project 2)
    (37, 1115, 'Desenvolvedor Backend',  '2024-10-18', 3),
    (40, 2483, 'Desenvolvedor Frontend', '2024-10-25', 3),
    (36, 1385, 'Dev Mobile',             '2024-10-20', 3),
    (36, 2448, 'QA Analyst',             '2024-10-15', 3),
    (20, 2475, 'Desenvolvedor Backend',  '2024-10-01', 3), -- 3ª squad da pessoa 2475

    -- Team 3A (Project 3)
    (42, 2504, 'Desenvolvedor Backend',  '2024-11-01', 4),
    (39, 2462, 'Desenvolvedor Frontend', '2024-11-06', 4),
    (38, 2483, 'Dev Mobile',             '2024-11-07', 4), -- 2ª squad da pessoa 2483
    (40, 2450, 'Scrum Master',           '2024-11-02', 4),

    -- Team 3B (Project 3)
    (38, 2432, 'QA Analyst',             '2024-11-05', 5),
    (25, 2450, 'Scrum Master',           '2024-11-10', 5), -- 2ª squad da pessoa 2450

    -- Team 4 (Project 4)
    (36, 2497, 'Desenvolvedor Backend',  '2024-08-04', 6),
    (38, 2495, 'Desenvolvedor Frontend', '2024-08-10', 6),
    (38, 2485, 'Dev Mobile',             '2024-08-06', 6),
    (40, 2481, 'QA Analyst',             '2024-08-04', 6),
    (37, 2480, 'Scrum Master',           '2024-08-11', 6),

    -- Team 5 (Project 5)
    (45, 2442, 'Desenvolvedor Backend',  '2024-06-08', 7),
    (37, 2456, 'Desenvolvedor Frontend', '2024-06-07', 7),
    (40, 2476, 'Dev Mobile',             '2024-06-11', 7),
    (18, 2472, 'QA Analyst',             '2024-06-08', 7),
    (21, 1145, 'Scrum Master',           '2024-06-03', 7);

-- =========================================================
-- NOVOS PROJETOS (IDs esperados: 6..16)
-- =========================================================
INSERT INTO project (name, project_type_id, description, project_status_id, budget, start_date, end_date, area) VALUES
    ( 'Monitoramento de Infraestrutura Cloud', 4,
      'Plataforma de monitoramento e alertas para infraestrutura em nuvem',
      1, 90000.00, '2025-01-10', '2025-04-30', 'Infraestrutura' ),
    ( 'Portal de Autoatendimento do Colaborador', 2,
      'Portal web para solicitações de RH, TI e facilities',
      1, 65000.00, '2025-02-01', '2025-06-15', 'RH Digital' ),
    ( 'Engine de Recomendação de Treinamentos', 5,
      'Mecanismo de recomendação de treinamentos baseado em skills e gaps',
      2, 70000.00, '2025-03-05', '2025-09-30', 'Analytics' ),
    ( 'Sistema de Gestão de Incidentes e Mudanças', 1,
      'Sistema integrado para registro, acompanhamento e mudança de incidentes',
      1, 110000.00, '2025-04-01', '2025-08-31', 'Tecnologia' ),
    ( 'Plataforma de Feedback Contínuo', 3,
      'Plataforma para feedback recorrente entre gestores e colaboradores',
      1, 55000.00, '2025-05-10', '2025-10-31', 'RH Digital' ),
    ( 'Integração ERP–PeopleOps', 4,
      'Integrações entre o ERP financeiro e a plataforma PeopleOps',
      1, 80000.00, '2025-06-01', '2025-11-30', 'Integração' ),
    ( 'Portal de Indicadores de People Analytics', 5,
      'Portal consolidado de indicadores de pessoas e squads',
      2, 60000.00, '2025-07-01', '2025-11-30', 'Analytics' ),
    ( 'App Mobile do Colaborador', 3,
      'Aplicativo mobile para autoatendimento e comunicação com o colaborador',
      1, 95000.00, '2025-08-01', '2025-12-15', 'Tecnologia' ),
    ( 'Automação de Onboarding e Offboarding', 2,
      'Automação de fluxos de entrada e saída de colaboradores',
      1, 50000.00, '2025-09-01', '2026-01-31', 'RH Digital' ),
    ( 'Gestão de Capacity e Alocação de Times', 1,
      'Ferramenta para planejamento de capacidade e alocação de squads',
      1, 120000.00, '2025-10-01', '2026-03-31', 'Tecnologia' ),
    ( 'Central de Conhecimento e Documentação Técnica', 2,
      'Central unificada de documentação, FAQs e tutoriais internos',
      1, 45000.00, '2025-11-01', '2026-02-28', 'Documentação' );

-- =========================================================
-- NOVOS TEAMS (IDs esperados: 8..18)
-- =========================================================
INSERT INTO team (fk_approver, description, name, fk_project, sprint_duration, status)
VALUES
    (2497, 'Squad única do Projeto 8', 'Team 8', 8, 10, 1),
    (2442, 'Squad única do Projeto 9', 'Team 9', 9, 10, 1),
    (2510, 'Squad única do Projeto 10', 'Team 10', 10, 10, 1),
    (2456, 'Squad única do Projeto 11', 'Team 11', 11, 10, 1),
    (2432, 'Squad única do Projeto 12', 'Team 12', 12, 10, 1),
    (2495, 'Squad única do Projeto 13', 'Team 13', 13, 10, 1),
    (2481, 'Squad única do Projeto 14', 'Team 14', 14, 10, 1),
    (2450, 'Squad única do Projeto 15', 'Team 15', 15, 10, 1),
    (2515, 'Squad única do Projeto 16', 'Team 16', 16, 10, 1);

select * from team;

-- =========================================================
-- NOVAS ALLOCATIONS PARA OS NOVOS TEAMS (5 pessoas por squad)
-- =========================================================
INSERT INTO allocation (allocated_hours, fk_person, position, started_at, fk_team)
VALUES
    (30, 2475, 'Desenvolvedor Backend', '2025-01-10', 8),
    (33, 2505, 'Desenvolvedor Frontend', '2025-01-12', 8),
    (36, 2517, 'Dev Mobile', '2025-01-14', 8),
    (39, 2466, 'QA Analyst', '2025-01-16', 8),
    (42, 2512, 'Scrum Master', '2025-01-18', 8),
    (30, 1115, 'Desenvolvedor Backend', '2025-02-10', 9),
    (33, 2483, 'Desenvolvedor Frontend', '2025-02-12', 9),
    (36, 1385, 'Dev Mobile', '2025-02-14', 9),
    (39, 2448, 'QA Analyst', '2025-02-16', 9),
    (42, 2510, 'Scrum Master', '2025-02-18', 9),
    (30, 2504, 'Desenvolvedor Backend', '2025-03-10', 10),
    (33, 2462, 'Desenvolvedor Frontend', '2025-03-12', 10),
    (36, 2484, 'Dev Mobile', '2025-03-14', 10),
    (39, 2432, 'QA Analyst', '2025-03-16', 10),
    (42, 2450, 'Scrum Master', '2025-03-18', 10),
    (30, 2497, 'Desenvolvedor Backend', '2025-04-10', 11),
    (33, 2495, 'Desenvolvedor Frontend', '2025-04-12', 11),
    (36, 2485, 'Dev Mobile', '2025-04-14', 11),
    (39, 2481, 'QA Analyst', '2025-04-16', 11),
    (42, 2480, 'Scrum Master', '2025-04-18', 11),
    (30, 2442, 'Desenvolvedor Backend', '2025-05-10', 12),
    (33, 2456, 'Desenvolvedor Frontend', '2025-05-12', 12),
    (36, 2476, 'Dev Mobile', '2025-05-14', 12),
    (39, 2472, 'QA Analyst', '2025-05-16', 12),
    (42, 1145, 'Scrum Master', '2025-05-18', 12),
    (30, 2436, 'Desenvolvedor Backend', '2025-06-10', 13),
    (33, 1305, 'Desenvolvedor Frontend', '2025-06-12', 13),
    (36, 2477, 'Dev Mobile', '2025-06-14', 13),
    (39, 2508, 'QA Analyst', '2025-06-16', 13),
    (42, 2454, 'Scrum Master', '2025-06-18', 13),
    (30, 2470, 'Desenvolvedor Backend', '2025-07-10', 14),
    (33, 2474, 'Desenvolvedor Frontend', '2025-07-12', 14),
    (36, 2429, 'Dev Mobile', '2025-07-14', 14),
    (39, 2464, 'QA Analyst', '2025-07-16', 14),
    (42, 2428, 'Scrum Master', '2025-07-18', 14),
    (30, 1264, 'Desenvolvedor Backend', '2025-08-10', 15),
    (33, 2467, 'Desenvolvedor Frontend', '2025-08-12', 15),
    (36, 1219, 'Dev Mobile', '2025-08-14', 15),
    (39, 2502, 'QA Analyst', '2025-08-16', 15),
    (42, 2452, 'Scrum Master', '2025-08-18', 15),
    (30, 1268, 'Desenvolvedor Backend', '2025-09-10', 16),
    (33, 2434, 'Desenvolvedor Frontend', '2025-09-12', 16),
    (36, 2499, 'Dev Mobile', '2025-09-14', 16),
    (39, 2455, 'QA Analyst', '2025-09-16', 16),
    (42, 2461, 'Scrum Master', '2025-09-18', 16);


CREATE OR REPLACE VIEW vw_company_allocated_hours AS
SELECT
    a.started_at AS allocation_date,
    SUM(a.allocated_hours) AS total_allocated_hours
FROM allocation a
GROUP BY
    a.started_at;

-- View para visualizar alocação completa, utilizado na ETL da dash
CREATE OR REPLACE VIEW vw_squad_allocations AS
SELECT
    a.fk_person AS person_id,
    a.allocated_hours,
    a.position,
    t.id AS team_id,
    t.name AS team_name,
    p.id AS project_id,
    p.name AS project_name,
    p.area AS project_area,
    p.project_status_id,
    a.started_at
FROM allocation a
         INNER JOIN team t ON a.fk_team = t.id
         INNER JOIN project p ON t.fk_project = p.id;

-- View para KPI de total de projetos ativos
CREATE OR REPLACE VIEW vw_total_active_projects AS
SELECT
    COUNT(*) AS total_active_projects
FROM project
WHERE active = TRUE;

-- View para KPI de total de squad ativos
CREATE OR REPLACE VIEW vw_total_active_squads AS
SELECT
    COUNT(*) AS total_active_squads
FROM team
WHERE status = 1;