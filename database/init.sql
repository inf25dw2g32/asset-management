-- ============================================================
-- SISTEMA DE GESTÃO DE ASSETS - ISO 27001 / Auditorias
-- ============================================================
-- Tabelas: users, categories, assets, inspections
-- Relação 1:N: categories -> assets  |  assets -> inspections
-- ============================================================

CREATE DATABASE IF NOT EXISTS asset_management
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE asset_management;

-- ============================================================
-- TABELA 1: users
-- Utilizadores do sistema (auditores, admins, técnicos)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100)    NOT NULL,
  email       VARCHAR(150)    NOT NULL UNIQUE,
  password    VARCHAR(255)    NOT NULL,          -- bcrypt hash
  role        ENUM('admin','auditor','technician') NOT NULL DEFAULT 'technician',
  active      TINYINT(1)      NOT NULL DEFAULT 1,
  created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- TABELA 2: categories
-- Categorias de assets (ex: Hardware, Software, Rede…)
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
  id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100)    NOT NULL UNIQUE,
  description TEXT,
  created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- TABELA 3: assets
-- Assets de TI/Segurança (relação N:1 com categories)
-- ============================================================
CREATE TABLE IF NOT EXISTS assets (
  id             INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
  category_id    INT UNSIGNED    NOT NULL,
  owner_id       INT UNSIGNED    NOT NULL,          -- utilizador responsável
  name           VARCHAR(150)    NOT NULL,
  serial_number  VARCHAR(100),
  brand          VARCHAR(100),
  model          VARCHAR(100),
  location       VARCHAR(150),
  status         ENUM('active','inactive','maintenance','disposed') NOT NULL DEFAULT 'active',
  purchase_date  DATE,
  criticality    ENUM('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  notes          TEXT,
  created_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_assets_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
  CONSTRAINT fk_assets_owner    FOREIGN KEY (owner_id)    REFERENCES users(id)       ON DELETE RESTRICT
);

-- ============================================================
-- TABELA 4: inspections
-- Inspeções/Auditorias por asset (relação N:1 com assets)
-- ============================================================
CREATE TABLE IF NOT EXISTS inspections (
  id           INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
  asset_id     INT UNSIGNED    NOT NULL,
  inspector_id INT UNSIGNED    NOT NULL,           -- utilizador que fez a inspeção
  type         ENUM('audit','maintenance','security_check','inventory') NOT NULL DEFAULT 'audit',
  result       ENUM('pass','fail','pending','not_applicable') NOT NULL DEFAULT 'pending',
  score        TINYINT UNSIGNED,                   -- 0-100 (conformidade ISO 27001)
  findings     TEXT,
  recommendations TEXT,
  inspected_at TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  next_review  DATE,
  created_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_inspections_asset     FOREIGN KEY (asset_id)     REFERENCES assets(id) ON DELETE CASCADE,
  CONSTRAINT fk_inspections_inspector FOREIGN KEY (inspector_id) REFERENCES users(id)  ON DELETE RESTRICT
);

-- ============================================================
-- ÍNDICES para melhor performance
-- ============================================================
CREATE INDEX idx_assets_category  ON assets(category_id);
CREATE INDEX idx_assets_owner     ON assets(owner_id);
CREATE INDEX idx_assets_status    ON assets(status);
CREATE INDEX idx_inspections_asset     ON inspections(asset_id);
CREATE INDEX idx_inspections_inspector ON inspections(inspector_id);
CREATE INDEX idx_inspections_result    ON inspections(result);


-- ============================================================
-- SEED DATA
-- ============================================================

-- ------------------------------------------------------------
-- USERS (passwords são todos "Password123!" com bcrypt)
-- Hash gerado: $2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq
-- (em prod gerar hashes reais com bcrypt)
-- ------------------------------------------------------------
INSERT INTO users (name, email, password, role) VALUES
('Admin Sistema',        'admin@empresa.pt',       '$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'admin'),
('João Auditor',         'joao.auditor@empresa.pt','$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'auditor'),
('Maria Técnica',        'maria.tecnica@empresa.pt','$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq','technician'),
('Carlos Segurança',     'carlos.seg@empresa.pt',  '$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'auditor'),
('Ana Administradora',   'ana.admin@empresa.pt',   '$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'admin'),
('Rui Técnico',          'rui.tecnico@empresa.pt', '$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'technician'),
('Sofia Auditora',       'sofia.aud@empresa.pt',   '$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'auditor'),
('Pedro Técnico',        'pedro.tec@empresa.pt',   '$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'technician'),
('Inês Segurança',       'ines.seg@empresa.pt',    '$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'auditor'),
('Tiago Admin',          'tiago.admin@empresa.pt', '$2b$10$FEkSBc7t65Rhouc1vlvFuefDbSxr4kI5hU6Vp3UxOM2g/f2Nkg/Iq', 'admin');

-- ------------------------------------------------------------
-- CATEGORIES
-- ------------------------------------------------------------
INSERT INTO categories (name, description) VALUES
('Hardware',         'Equipamentos físicos: computadores, servidores, impressoras'),
('Software',         'Licenças e aplicações instaladas nos sistemas'),
('Rede',             'Equipamentos de rede: switches, routers, firewalls, APs'),
('Storage',          'Dispositivos de armazenamento: NAS, SAN, discos externos'),
('Segurança Física', 'Câmeras, controlo de acessos, alarmes'),
('Cloud',            'Recursos e serviços em nuvem (AWS, Azure, GCP)'),
('Mobile',           'Smartphones e tablets corporativos'),
('Periféricos',      'Monitores, teclados, ratos, headsets');

-- ------------------------------------------------------------
-- ASSETS (30 registos)
-- ------------------------------------------------------------
INSERT INTO assets (category_id, owner_id, name, serial_number, brand, model, location, status, purchase_date, criticality, notes) VALUES
-- Hardware
(1, 1, 'Servidor Principal',        'SRV-001-2021', 'Dell',    'PowerEdge R740',    'Datacenter Rack A1',  'active',      '2021-03-15', 'critical', 'Servidor de produção principal'),
(1, 3, 'Workstation Desenvolvimento','WS-DEV-002',   'HP',      'Z4 G4',             'Sala Desenvolvimento','active',      '2022-01-10', 'high',     'Máquina de desenvolvimento backend'),
(1, 6, 'PC Receção',                'PC-REC-003',   'Lenovo',  'ThinkCentre M720',  'Receção',             'active',      '2020-06-20', 'low',      NULL),
(1, 8, 'Laptop Auditoria',          'LAP-AUD-004',  'Dell',    'Latitude 5420',     'Sala Reuniões',       'active',      '2022-09-01', 'high',     'Portátil dedicado a auditorias externas'),
(1, 3, 'Servidor Backup',           'SRV-BCK-005',  'HP',      'ProLiant DL380',    'Datacenter Rack A2',  'active',      '2021-07-22', 'critical', 'Servidor de backup e recuperação'),
-- Rede
(3, 1, 'Firewall Perimetral',       'FW-PER-001',   'Fortinet','FortiGate 100F',    'Datacenter Rack B1',  'active',      '2022-02-14', 'critical', 'Firewall principal - segmento DMZ'),
(3, 6, 'Switch Core',               'SW-COR-002',   'Cisco',   'Catalyst 9300',     'Datacenter Rack B2',  'active',      '2021-11-30', 'critical', 'Switch de core da rede interna'),
(3, 6, 'Router WAN',                'RT-WAN-003',   'Cisco',   'ISR 4331',          'Datacenter Rack B1',  'active',      '2020-08-05', 'critical', NULL),
(3, 8, 'Access Point - Piso 1',     'AP-P1-004',    'Ubiquiti','UniFi AP AC Pro',   'Piso 1 - Corredor',   'active',      '2021-04-18', 'medium',   NULL),
(3, 8, 'Access Point - Piso 2',     'AP-P2-005',    'Ubiquiti','UniFi AP AC Pro',   'Piso 2 - Corredor',   'active',      '2021-04-18', 'medium',   NULL),
(3, 1, 'IDS/IPS',                   'IDS-001',      'Snort',   'Virtual Appliance', 'Datacenter Virtual',  'active',      '2022-06-01', 'high',     'Sistema de deteção de intrusões'),
-- Storage
(4, 1, 'NAS Principal',             'NAS-001-2020', 'Synology','DS1821+',           'Datacenter Rack C1',  'active',      '2020-12-01', 'critical', 'Armazenamento partilhado produção'),
(4, 3, 'NAS Desenvolvimento',       'NAS-DEV-002',  'QNAP',    'TS-453D',           'Sala Desenvolvimento','active',      '2021-08-14', 'medium',   NULL),
(4, 5, 'Disco Externo Backup',      'HDD-EXT-003',  'Seagate', 'Backup Plus 8TB',   'Cofre Sala Servidores','active',     '2022-03-10', 'high',     'Backup semanal offsite'),
-- Cloud
(6, 1, 'Azure Subscription Prod',   'AZ-SUB-PROD',  'Microsoft','Azure',            'Cloud - West Europe', 'active',      '2021-01-01', 'critical', 'Subscrição Azure produção'),
(6, 2, 'AWS Dev Account',           'AWS-DEV-001',  'Amazon',  'AWS',               'Cloud - EU-West-1',   'active',      '2022-05-15', 'medium',   'Conta AWS para desenvolvimento e testes'),
(6, 5, 'Microsoft 365',             'M365-CORP',    'Microsoft','M365 Business',    'Cloud - Global',      'active',      '2020-09-01', 'high',     'Suite Office + Exchange + Teams'),
-- Mobile
(7, 4, 'Smartphone Diretor',        'MOB-DIR-001',  'Apple',   'iPhone 14 Pro',     'Direção',             'active',      '2023-01-10', 'high',     NULL),
(7, 7, 'Tablet Auditorias',         'TAB-AUD-002',  'Apple',   'iPad Pro 11"',      'Sala Reuniões',       'active',      '2022-11-20', 'medium',   'Usado em auditorias de campo'),
(7, 9, 'Smartphone Técnico',        'MOB-TEC-003',  'Samsung', 'Galaxy S22',        'Suporte Técnico',     'active',      '2022-07-05', 'low',      NULL),
-- Segurança Física
(5, 5, 'Câmera IP Entrada',         'CAM-ENT-001',  'Axis',    'P3245-V',           'Entrada Principal',   'active',      '2021-02-28', 'high',     NULL),
(5, 5, 'Câmera IP Datacenter',      'CAM-DC-002',   'Axis',    'P3245-V',           'Datacenter',          'active',      '2021-02-28', 'critical', 'Monitorização 24/7'),
(5, 5, 'Controlo Acesso Datacenter','ACC-DC-003',   'HID',     'iCLASS SE R40',     'Porta Datacenter',    'active',      '2020-05-10', 'critical', 'Leitor de cartão + PIN'),
(5, 5, 'UPS Datacenter',            'UPS-DC-001',   'APC',     'Smart-UPS 3000VA',  'Datacenter Rack D1',  'active',      '2021-10-15', 'critical', 'Autonomia estimada: 45 min'),
-- Software
(2, 1, 'Antivírus Corporativo',     'SW-AV-001',    'Sophos',  'Intercept X',       'Todos os endpoints',  'active',      '2022-01-01', 'high',     '50 licenças - renovação anual'),
(2, 2, 'SIEM',                      'SW-SIEM-001',  'Splunk',  'Enterprise',        'Servidor Virtual',    'active',      '2021-06-01', 'critical', 'Correlação de eventos de segurança'),
(2, 3, 'IDE Desenvolvimento',       'SW-IDE-001',   'JetBrains','All Products Pack', 'Workstations Dev',   'active',      '2023-01-01', 'low',      '5 licenças ativas'),
-- Periféricos + extras
(8, 3, 'Monitor Duplo Dev',         'MON-DEV-001',  'LG',      '27UK850-W 4K',      'Sala Desenvolvimento','active',      '2022-04-01', 'low',      NULL),
(1, 6, 'Laptop Suporte',            'LAP-SUP-005',  'HP',      'EliteBook 840 G8',  'Suporte Técnico',     'active',      '2022-10-12', 'medium',   NULL),
(3, 1, 'Switch Acesso Piso 1',      'SW-ACC-006',   'Cisco',   'Catalyst 2960-X',   'Piso 1 - Armário TI', 'maintenance', '2019-03-20', 'medium',   'Em manutenção preventiva');

-- ------------------------------------------------------------
-- INSPECTIONS (30 registos)
-- ------------------------------------------------------------
INSERT INTO inspections (asset_id, inspector_id, type, result, score, findings, recommendations, inspected_at, next_review) VALUES
-- Servidor Principal
(1, 2, 'audit',           'pass',   92, 'Patches atualizados. Logs ativos. Backups verificados.',             'Rever política de retenção de logs.',                          '2024-01-15 09:00:00', '2024-07-15'),
(1, 4, 'security_check',  'pass',   88, 'Portas desnecessárias fechadas. TLS 1.3 ativo.',                     'Desativar TLS 1.2 para forçar versão mais recente.',            '2024-03-10 10:30:00', '2024-09-10'),
-- Servidor Backup
(5, 2, 'audit',           'pass',   85, 'Backup diário funcional. Teste de restore realizado com sucesso.',   'Implementar backup offsite automatizado.',                      '2024-02-01 14:00:00', '2024-08-01'),
(5, 4, 'maintenance',     'pass',   NULL,'Substituição de ventoinhas preventiva. Limpeza de pó.',             NULL,                                                            '2024-04-05 08:00:00', '2024-10-05'),
-- Firewall
(6, 2, 'security_check',  'pass',   95, 'Regras de firewall revistas. Sem portas abertas desnecessárias.',    'Ativar geo-blocking para regiões sem tráfego legítimo.',        '2024-01-20 11:00:00', '2024-04-20'),
(6, 7, 'audit',           'pass',   91, 'Logs de tráfego exportados para SIEM. IPS atualizado.',             NULL,                                                            '2024-03-25 09:30:00', '2024-06-25'),
-- Switch Core
(7, 4, 'security_check',  'fail',   55, 'VLANs não segmentadas corretamente. SNMP v1 ainda ativo.',           'Migrar para SNMPv3. Rever segmentação de VLANs urgentemente.',  '2024-02-14 15:00:00', '2024-03-14'),
(7, 2, 'audit',           'pass',   78, 'SNMP v1 desativado após auditoria anterior. VLANs corrigidas.',      'Documentar topologia de rede atualizada.',                      '2024-03-20 10:00:00', '2024-09-20'),
-- NAS Principal
(12, 2, 'audit',          'pass',   87, 'Permissões de acesso corretas. Encriptação ativa.',                  'Ativar autenticação de dois fatores no painel admin.',          '2024-01-10 09:00:00', '2024-07-10'),
(12, 9, 'security_check', 'fail',   62, '2FA não implementado. Versão do DSM desatualizada.',                 'Atualizar DSM para versão 7.2. Ativar 2FA obrigatório.',        '2024-04-01 11:00:00', '2024-05-01'),
-- Azure Production
(15, 2, 'audit',          'pass',   93, 'MFA ativo em todas as contas. Políticas de acesso condicional OK.',  'Rever permissões de service principals trimestralmente.',      '2024-02-20 10:00:00', '2024-08-20'),
(15, 7, 'security_check', 'pass',   90, 'NSGs configurados corretamente. Defender for Cloud a verde.',        NULL,                                                            '2024-04-10 14:00:00', '2024-07-10'),
-- Controlo Acesso Datacenter
(23, 4, 'security_check', 'pass',   97, 'Logs de acesso revistos. Nenhum acesso não autorizado detetado.',   'Rever lista de acessos autorizados semestralmente.',            '2024-01-25 08:30:00', '2024-07-25'),
(23, 9, 'audit',          'pass',   94, 'Política de acesso mínimo implementada. Cartões rekeyed em Jan.',   NULL,                                                            '2024-03-15 09:00:00', '2024-09-15'),
-- UPS
(24, 6, 'maintenance',    'pass',   NULL,'Teste de carga realizado. Autonomia confirmada 47 minutos.',        'Substituir baterias em 2025.',                                  '2024-02-10 07:00:00', '2024-08-10'),
-- Antivírus
(25, 2, 'audit',          'pass',   89, 'Definições atualizadas. 48/50 endpoints com agente ativo.',          'Investigar 2 endpoints sem agente ativo.',                      '2024-03-01 10:00:00', '2024-06-01'),
(25, 4, 'security_check', 'fail',   70, '3 endpoints com definições desatualizadas há +7 dias.',              'Forçar atualização automática e verificar política de grupo.',  '2024-04-15 11:00:00', '2024-05-15'),
-- SIEM
(26, 2, 'audit',          'pass',   96, 'Correlações ativas para MITRE ATT&CK. Alertas testados OK.',        'Expandir cobertura para assets cloud.',                         '2024-01-30 14:00:00', '2024-07-30'),
-- Câmera Datacenter
(22, 5, 'security_check', 'pass',   91, 'Gravação contínua ativa. Retenção de 90 dias confirmada.',          NULL,                                                            '2024-02-25 09:00:00', '2024-08-25'),
-- IDS/IPS
(11, 2, 'audit',          'pass',   88, 'Regras Snort atualizadas. 12 alertas críticos revistos no período.','Integrar alertas com ticketing system.',                        '2024-03-05 10:30:00', '2024-09-05'),
(11, 7, 'security_check', 'pass',   85, 'False positive rate reduzido após tuning de regras.',               NULL,                                                            '2024-04-20 11:00:00', '2024-10-20'),
-- Laptop Auditoria
(4,  9, 'inventory',      'pass',   NULL,'Asset localizado e em bom estado. Etiqueta patrimonial OK.',        NULL,                                                            '2024-01-08 08:00:00', '2025-01-08'),
-- Microsoft 365
(17, 2, 'audit',          'pass',   92, 'DLP policies ativas. eDiscovery configurado. MFA a 100%.',          'Rever conditional access policies para acesso mobile.',         '2024-02-05 10:00:00', '2024-08-05'),
-- Smartphone Diretor
(18, 9, 'security_check', 'pass',   88, 'MDM enrollment OK. Encriptação ativa. iOS atualizado.',             NULL,                                                            '2024-03-18 09:00:00', '2024-09-18'),
-- AWS Dev
(16, 4, 'audit',          'fail',   58, 'Bucket S3 com permissão pública detetado. IAM roles excessivos.',   'Remediar bucket público imediatamente. Rever IAM least privilege.','2024-04-02 14:00:00', '2024-05-02'),
(16, 2, 'security_check', 'pass',   82, 'Bucket público removido. IAM roles revistos e restringidos.',       'Implementar AWS Config rules para prevenir reincidência.',      '2024-04-25 10:00:00', '2024-10-25'),
-- Switch Acesso (em manutenção)
(30, 6, 'maintenance',    'pending',NULL,'Aguarda peça de substituição para porta SFP danificada.',           'Substituir módulo SFP. ETA: 1 semana.',                         '2024-04-18 08:00:00', '2024-05-01'),
-- Câmera Entrada
(21, 5, 'security_check', 'pass',   90, 'Ângulo de visão cobre 100% da entrada. Sem blind spots.',           NULL,                                                            '2024-03-22 09:30:00', '2024-09-22'),
-- NAS Dev
(13, 6, 'inventory',      'pass',   NULL,'Asset inventariado. 2.3TB livres de 8TB.',                         'Planear expansão de capacidade.',                               '2024-01-12 10:00:00', '2025-01-12'),
-- PC Receção
(3,  9, 'audit',          'pass',   75, 'Antivírus ativo. User sem privilégios de admin local.',             'Encriptar disco local com BitLocker.',                          '2024-02-28 11:00:00', '2024-08-28');
