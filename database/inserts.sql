USE pops;

INSERT INTO nivel_acesso (nome, descricao) VALUES
('Admin', 'RH e CTO'),
('Squad Lider', 'Scrum Master, P.O e TechLead'),
('Colaborador', 'Funcionários e demais colaboradores');

INSERT INTO departamento (nome) VALUES
('Tecnologia da Informação (TI)'),
('Marketing'),
('Vendas'),
('Recursos Humanos (RH)'),
('Financeiro'),
('Contabilidade'),
('Jurídico'),
('Compras'),
('Administrativo'),
('Atendimento ao cliente/ Suporte'),
('Produtos'),
('Compliance/Governança'),
('Design UX/UI');

INSERT INTO tipo (id_tipo, tipo) VALUES
(1, 'Treinamento Interno'),
(2, 'Certificação Externa');

INSERT INTO area_conhecimento (area) VALUES 
('Desenvolvimento de Software'),
('Segurança da Informação'),
('Gestão de Pessoas'),
('LGPD / Compliance'),
('Finanças / Contabilidade'),
('Liderança'),
('Atendimento ao Cliente'),
('Projetos / Scrum / Agile'),
('Design / UX e UI'),
('Sustentabilidade / ESG'),
('Infraestrutura de TI'),
('Ciência de Dados / Analytics'),
('QA / Testes'),
('Automação de Processos / Arquitetura de Soluções'),
('Compras / Suprimentos'),
('Investimentos'),
('Operações Administrativas / Processos'),
('Comercial / Relacionamentos'),
('Marketing / Brandig'),
('Gestão de Projetos'),
('Saúde / Bem-estar no trabalho');

INSERT INTO categoria (categoria) VALUES 
('Técnica / Operacional'),
('Gestão / Liderança'),
('Cultura e Valores da Empresa'),
('Normativo / Regulatórios');

INSERT INTO modalidade (id_modalidade, modalidade) VALUES 
(1, 'Presencial'),
(2, 'Online ao vivo'),
(3, 'Online gravado / EAD'),
(4, 'Híbrido');

INSERT INTO acao (id_acao, nome, descricao) VALUES 
(1, 'Inserção raw', 'Inserção de dados no bucket'),
(2, 'Inserção trusted', 'Inserção de dados no bucket'),
(3, 'Consulta raw', 'Consultou o bucket'),
(4, 'Consulta trusted', 'Consultou o bucket'),
(5, 'Excluir raw', 'Removeu algo do bucket'),
(6, 'Excluir trusted', 'Removeu algo do bucket'),
(7, 'Alterar raw', 'Realizou alguma alteração dentro do bucket'),
(8, 'Alterar trusted', 'Realizou alguma alteração dentro do bucket'),
(9, 'Notificação', 'Realizou o envio de alguma notificação');
