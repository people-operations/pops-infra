CREATE DATABASE IF NOT EXISTS pops DEFAULT CHARACTER SET utf8 ;
USE pops ;

-- -----------------------------------------------------
-- Table pops.nivel_acesso
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.nivel_acesso (
  id_nivel_acesso INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(45) NOT NULL,
  descricao VARCHAR(45) NULL,
  PRIMARY KEY (id_nivel_acesso));

-- -----------------------------------------------------
-- Table pops.colaborador
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.colaborador (
  id_colaborador INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(70) NOT NULL,
  email VARCHAR(100) NOT NULL,
  fk_nivel_acesso INT NOT NULL,
  PRIMARY KEY (id_colaborador),
  INDEX fk_colaborador_nivel_acesso1_idx (fk_nivel_acesso ASC) VISIBLE,
  INDEX idx_colaborador_nivel_acesso (id_colaborador, fk_nivel_acesso),
  CONSTRAINT fk_colaborador_nivel_acesso1
    FOREIGN KEY (fk_nivel_acesso)
    REFERENCES pops.nivel_acesso (id_nivel_acesso)
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table pops.departamento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.departamento (
  id_departamento INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(70) NOT NULL,
  PRIMARY KEY (id_departamento));

-- -----------------------------------------------------
-- Table pops.tipo
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.tipo (
  id_tipo INT NOT NULL,
  tipo VARCHAR(70) NOT NULL,
  PRIMARY KEY (id_tipo));

-- -----------------------------------------------------
-- Table pops.area_conhecimento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.area_conhecimento (
  id_area_conhecimento INT NOT NULL AUTO_INCREMENT,
  area VARCHAR(70) NOT NULL,
  PRIMARY KEY (id_area_conhecimento));

-- -----------------------------------------------------
-- Table pops.modalidade
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.modalidade (
  id_modalidade INT NOT NULL,
  modalidade VARCHAR(70) NOT NULL,
  PRIMARY KEY (id_modalidade));

-- -----------------------------------------------------
-- Table pops.categoria
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.categoria (
  id_categoria INT NOT NULL AUTO_INCREMENT,
  categoria VARCHAR(70) NOT NULL,
  PRIMARY KEY (id_categoria));

-- -----------------------------------------------------
-- Table pops.certificado
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.certificado (
  id_certificado INT NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(70) NOT NULL,
  nome VARCHAR(100) NOT NULL,
  emissor VARCHAR(120) NOT NULL,
  data_conclusao DATE NOT NULL,
  data_validade DATE NULL,
  carga_horaria TIME NULL,
  obrigatorio TINYINT NOT NULL,
  comprovante BLOB NOT NULL,
  comentarios VARCHAR(200) NULL,
  fk_departamento INT NOT NULL,
  fk_tipo INT NOT NULL,
  fk_area_conhecimento INT NOT NULL,
  fk_modalidade INT NOT NULL,
  fk_categoria INT NOT NULL,
  fk_colaborador INT NOT NULL,
  PRIMARY KEY (id_certificado, fk_colaborador),
  INDEX idx_certificado_completo (id_certificado, fk_departamento, fk_tipo, fk_area_conhecimento, fk_modalidade, fk_categoria, fk_colaborador),
  INDEX fk_certificado_departamento_idx (fk_departamento ASC) VISIBLE,
  INDEX fk_certificado_tipo_idx (fk_tipo ASC) VISIBLE,
  INDEX fk_certificado_area_conhecimento_idx (fk_area_conhecimento ASC) VISIBLE,
  INDEX fk_certificado_modalidade_idx (fk_modalidade ASC) VISIBLE,
  INDEX fk_certificado_categoria_idx (fk_categoria ASC) VISIBLE,
  INDEX fk_certificado_colaborador_idx (fk_colaborador ASC) VISIBLE,
  CONSTRAINT fk_certificado_departamento
    FOREIGN KEY (fk_departamento)
    REFERENCES pops.departamento (id_departamento)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT fk_certificado_tipo
    FOREIGN KEY (fk_tipo)
    REFERENCES pops.tipo (id_tipo)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT fk_certificado_area_conhecimento
    FOREIGN KEY (fk_area_conhecimento)
    REFERENCES pops.area_conhecimento (id_area_conhecimento)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT fk_certificado_modalidade
    FOREIGN KEY (fk_modalidade)
    REFERENCES pops.modalidade (id_modalidade)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT fk_certificado_categoria
    FOREIGN KEY (fk_categoria)
    REFERENCES pops.categoria (id_categoria)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT fk_certificado_colaborador
    FOREIGN KEY (fk_colaborador)
    REFERENCES pops.colaborador (id_colaborador)
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table pops.acao
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.acao (
  id_acao INT NOT NULL,
  nome VARCHAR(70) NOT NULL,
  descricao VARCHAR(70) NULL,
  PRIMARY KEY (id_acao));

-- -----------------------------------------------------
-- Table pops.log_certificado
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pops.log_certificado (
  id_log_certificado INT NOT NULL,
  data_hora DATETIME NULL,
  resultado VARCHAR(45) NULL,
  observacao VARCHAR(1000) NULL,
  comentarios VARCHAR(100) NULL,
  fk_acao INT NOT NULL,
  fk_certificado INT NOT NULL,
  fk_departamento INT NOT NULL,
  fk_tipo INT NOT NULL,
  fk_area_conhecimento INT NOT NULL,
  fk_modalidade INT NOT NULL,
  fk_categoria INT NOT NULL,
  fk_colaborador_certificado INT NOT NULL,
  fk_colaborador_rh INT NOT NULL,
  fk_nivel_acesso INT NOT NULL,
  PRIMARY KEY (id_log_certificado, fk_certificado, fk_colaborador_certificado, fk_colaborador_rh),
  INDEX fk_log_certificado_certificado_idx (fk_certificado ASC, fk_departamento ASC, fk_tipo ASC, fk_area_conhecimento ASC, fk_modalidade ASC, fk_categoria ASC, fk_colaborador_certificado ASC) VISIBLE,
  INDEX fk_log_certificado_colaborador_idx (fk_colaborador_rh ASC, fk_nivel_acesso ASC) VISIBLE,
  INDEX fk_log_certificado_acao_idx (fk_acao ASC) VISIBLE,
  CONSTRAINT fk_log_certificado_certificado1
    FOREIGN KEY (fk_certificado , fk_departamento , fk_tipo , fk_area_conhecimento , fk_modalidade , fk_categoria , fk_colaborador_certificado)
    REFERENCES pops.certificado (id_certificado , fk_departamento , fk_tipo , fk_area_conhecimento , fk_modalidade , fk_categoria , fk_colaborador)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT fk_log_certificado_colaborador
    FOREIGN KEY (fk_colaborador_rh , fk_nivel_acesso)
    REFERENCES pops.colaborador (id_colaborador , fk_nivel_acesso)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT fk_log_certificado_acao
    FOREIGN KEY (fk_acao)
    REFERENCES pops.acao (id_acao)
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
