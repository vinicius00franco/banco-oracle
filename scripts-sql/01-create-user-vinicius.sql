-- Script para criar usuário vinicius no Oracle
-- Executado automaticamente na inicialização do container

ALTER SESSION SET CONTAINER = XEPDB1;

-- Criar usuário vinicius
CREATE USER vinicius IDENTIFIED BY ViniciusPassword123
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

-- Conceder privilégios essenciais
GRANT CONNECT, RESOURCE TO vinicius;
GRANT CREATE VIEW TO vinicius;
GRANT CREATE SEQUENCE TO vinicius;
GRANT CREATE SYNONYM TO vinicius;
GRANT CREATE PROCEDURE TO vinicius;
GRANT CREATE TRIGGER TO vinicius;
GRANT CREATE TABLE TO vinicius;
GRANT CREATE INDEX TO vinicius;

-- Privilégios de DBA (para desenvolvimento)
GRANT DBA TO vinicius;

-- Criar usuário de aplicação para o lab de acidentes
CREATE USER lab_acidentes IDENTIFIED BY LabPassword123
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

-- Conceder privilégios ao usuário lab_acidentes
GRANT CONNECT, RESOURCE TO lab_acidentes;
GRANT CREATE VIEW TO lab_acidentes;
GRANT CREATE SEQUENCE TO lab_acidentes;
GRANT CREATE SYNONYM TO lab_acidentes;
GRANT CREATE PROCEDURE TO lab_acidentes;
GRANT CREATE TRIGGER TO lab_acidentes;

-- Mostrar usuários criados
SELECT username, account_status, created FROM dba_users 
WHERE username IN ('VINICIUS', 'LAB_ACIDENTES');

EXIT;
