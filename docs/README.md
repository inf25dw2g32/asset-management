# Sistema de Gestão de Assets de TI
## Relatório de Desenvolvimento

**Unidade Curricular:** Desenvolvimento Web  
**Ano Letivo:** 2025/2026
**Grupo:** inf25dw2g32  

---

## 1. Introdução

Este trabalho consiste no desenvolvimento de um sistema de gestão de assets de TI, orientado para auditorias de segurança, nomeadamente no contexto da norma ISO 27001. O sistema permite registar, consultar, atualizar e eliminar assets (equipamentos, software, serviços cloud, etc.) e as respetivas inspeções/auditorias.

O sistema foi desenvolvido com uma arquitetura REST, utilizando Node.js com o framework Express para a camada de serviços, MySQL como sistema de gestão de base de dados, e Docker para containerização da aplicação.

---

## 2. Modelo de Dados

O sistema é composto por 4 tabelas:

### 2.1 Diagrama de Entidades

| Tabela | Descrição |
|--------|-----------|
| `users` | Utilizadores do sistema (admins, auditores, técnicos) |
| `categories` | Categorias de assets (Hardware, Software, Rede, etc.) |
| `assets` | Assets de TI registados no sistema |
| `inspections` | Inspeções e auditorias realizadas aos assets |

### 2.2 Relações

- `categories` → `assets`: relação **1:N** (uma categoria tem vários assets)
- `assets` → `inspections`: relação **1:N** (um asset tem várias inspeções)
- `users` → `assets`: relação **1:N** (um utilizador é responsável por vários assets)
- `users` → `inspections`: relação **1:N** (um utilizador realiza várias inspeções)

---

## 3. Arquitetura da API REST

A API foi desenvolvida seguindo os princípios REST, disponibilizando os seguintes recursos:

### 3.1 Recursos Disponíveis

| Recurso | Base URL | Descrição |
|---------|----------|-----------|
| Auth | `/auth` | Autenticação e registo |
| Categories | `/categories` | Gestão de categorias |
| Assets | `/assets` | Gestão de assets |
| Inspections | `/inspections` | Gestão de inspeções |

### 3.2 Verbos HTTP utilizados

| Verbo | Operação | Exemplo |
|-------|----------|---------|
| `GET` | Ler recursos | `GET /assets` |
| `POST` | Criar recursos | `POST /assets` |
| `PUT` | Atualizar recursos | `PUT /assets/1` |
| `DELETE` | Eliminar recursos | `DELETE /assets/1` |

---

## 4. Autenticação e Autorização

### 4.1 Implementação com JWT

A camada de autenticação e autorização foi implementada com **JSON Web Tokens (JWT)**. O fluxo de autenticação funciona da seguinte forma:

1. O utilizador envia as credenciais (email e password) para `POST /auth/login`
2. A API valida as credenciais contra a base de dados
3. Se válidas, a API gera um token JWT assinado com uma chave secreta
4. O token é devolvido ao cliente e deve ser enviado no header `Authorization: Bearer <token>` em todos os pedidos seguintes
5. O middleware de autenticação valida o token em cada pedido protegido
6. Os dados do utilizador autenticado são apresentados na consola a cada pedido

### 4.2 Comparação com OAuth 2.0

O OAuth 2.0 define vários fluxos de autorização (flows). A implementação atual com JWT é equivalente ao **Resource Owner Password Credentials Flow** do OAuth 2.0, onde:

- O utilizador fornece diretamente as credenciais à aplicação
- A aplicação troca as credenciais por um token de acesso
- O token é usado para aceder aos recursos protegidos

Outros flows do OAuth 2.0 incluem:

| Flow | Descrição | Caso de uso |
|------|-----------|-------------|
| **Authorization Code** | Redireciona para servidor de autorização | Aplicações web com backend |
| **Client Credentials** | Autenticação máquina-a-máquina | APIs internas |
| **Implicit** | Token devolvido diretamente | SPAs (deprecated) |
| **Password Credentials** | Credenciais diretas (implementado) | Apps de confiança |

### 4.3 Controlo de Acesso

O sistema implementa controlo de acesso baseado em roles:

| Role | Permissões |
|------|-----------|
| `admin` | Acesso total a todos os recursos |
| `auditor` | Pode criar e gerir inspeções |
| `technician` | Acesso apenas aos seus próprios assets e inspeções |

---

## 5. Containerização com Docker

### 5.1 Estrutura
A aplicação é composta por dois containers definidos no `docker-compose.yml`:

**Container MySQL:**
- Imagem: `mysql:8.0`
- Porta: `3307:3306`
- Volume persistente: `mysql_data`
- Inicialização automática com `init.sql`

**Container API:**
- Imagem: `node:20-alpine`
- Porta: `3000:3000`
- Depende do container MySQL

### 5.2 Imagens no DockerHub

| Imagem | Repositório |
|--------|-------------|
| API Node.js | `inf25dw2g32/api:latest` |
| MySQL | `inf25dw2g32/mysql:latest` |

---

## 6. Documentação da API

A API está documentada com o formato **OpenAPI 3.0** e pode ser consultada em: http://localhost:3000/docs

---

## 7. Como executar o projeto

### Pré-requisitos
- Docker Desktop instalado

### Passos

1. Clonar o repositório:
```bash
git clone https://github.com/inf25dw2g32/asset-management.git
cd asset-management
```

2. Iniciar os containers:
```bash
docker-compose up --build
```

3. A API fica disponível em `http://localhost:3000`
4. A documentação fica disponível em `http://localhost:3000/docs`

### Credenciais de teste

| Email | Password | Role |
|-------|----------|------|
| admin@empresa.pt | Password123! | admin |
| joao.auditor@empresa.pt | Password123! | auditor |
| maria.tecnica@empresa.pt | Password123! | technician |

---

## 8. Estrutura do Projeto

- **database/** — Script SQL de inicialização da base de dados
- **docs/** — Relatório do projeto
- **src/config/** — Configuração da ligação à base de dados
- **src/controllers/** — Lógica de negócio de cada recurso (auth, assets, categories, inspections)
- **src/middleware/** — Middleware de autenticação JWT
- **src/routes/** — Definição das rotas da API
- **.dockerignore** — Ficheiros ignorados pelo Docker
- **.gitignore** — Ficheiros ignorados pelo Git
- **docker-compose.yml** — Configuração dos dois containers
- **Dockerfile** — Configuração da imagem da API
- **index.js** — Ponto de entrada da aplicação
- **package.json** — Dependências do projeto
- **postman_collection.json** — Collection para testes no Postman
- **swagger.yaml** — Documentação OpenAPI 3.0

---

## 9. Tecnologias Utilizadas

| Tecnologia | Versão | Função |
|------------|--------|--------|
| Node.js | 20.x | Servidor aplicacional |
| Express | 4.x | Framework REST |
| MySQL | 8.0 | Base de dados |
| Docker | - | Containerização |
| JWT | - | Autenticação |
| Swagger UI | - | Documentação OpenAPI 3.0 |