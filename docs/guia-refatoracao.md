# Refatoração Profunda da POC de Análise de Crédito  
## Um Guia Didático no Estilo Feynman

---

## 1. Introdução: O Problema Inicial

Imagine que você precisa simular uma análise de crédito automatizada, mas quer fugir de regras fixas e usar IA para tomar decisões. O desafio é orquestrar todo o fluxo: desde o recebimento do pedido, passando pela análise, até o registro seguro e confiável no banco de dados.  
No início, a inserção de dados estava suscetível a erros, especialmente por causa de caracteres especiais, formatação inadequada e queries SQL mal construídas. Além disso, era difícil garantir a integridade dos dados entre as tabelas.

---

## 2. Arquitetura Geral

- **Docker Compose**: Orquestra os serviços (Supabase/Postgres + N8N) para garantir ambientes reproduzíveis e isolados.
- **Supabase**: Fornece o banco de dados PostgreSQL, onde ficam as tabelas de clientes, empréstimos, solicitações e parâmetros.
- **N8N**: Automatiza o fluxo, conectando APIs, IA e banco de dados, sem necessidade de código backend tradicional.
- **IA**: Responsável por analisar o perfil do cliente e decidir sobre a aprovação do crédito.

---

## 3. Estrutura do Banco de Dados

### a) Tabela `clientes`

Armazena informações detalhadas dos clientes, incluindo:
- Dados pessoais (nome, CPF)
- Dados financeiros (renda, score, limite pré-aprovado)
- Histórico de pagamento e tempo de relacionamento

### b) Tabela `emprestimos`

Registra empréstimos ativos e históricos, relacionando cada empréstimo a um cliente via `cliente_id`, com detalhes como valor, parcelas, status, taxas e datas.

### c) Tabela `solicitacoes_credito`

Guarda o histórico de todas as solicitações de crédito, permitindo rastreabilidade e análise posterior.

### d) Tabela `parametros_credito`

Armazena regras e parâmetros ajustáveis para a análise de crédito (útil para testes A/B ou ajustes sem código).

---

## 4. Refatoração do Processo de Inserção de Dados

### O Problema:  
Antes, a inserção de dados era feita via queries SQL customizadas, com concatenação de strings. Isso gerava:
- Vulnerabilidade a SQL Injection
- Erros de sintaxe ao lidar com caracteres especiais (apóstrofos, quebras de linha, etc)
- Dificuldade de manutenção e legibilidade

### A Solução:  
**Mudamos para o modo “Insert” do node PostgreSQL do N8N**, que:
- Usa parâmetros, evitando SQL Injection
- Faz o tratamento automático de tipos e caracteres especiais
- Torna o fluxo mais visual e fácil de manter

#### Como foi feito:

1. **Preparação dos Dados**  
   Um node “Code” no N8N é usado para garantir que os dados estejam no formato correto, tratando strings problemáticas (ex: substituindo apóstrofos por dois apóstrofos, removendo quebras de linha, etc).

2. **Configuração do Node PostgreSQL**  
   - Em vez de um SQL customizado, usamos o modo “Insert”, mapeando cada campo da tabela ao respectivo dado.
   - Isso garante que o N8N trata os dados como parâmetros, não como parte da query.

3. **Validação de Integridade**  
   - Garantimos que o campo `cliente_id` sempre corresponda a um cliente existente.
   - IDs são definidos explicitamente para facilitar rastreabilidade e integridade referencial.

---

## 5. Massa de Dados: Garantindo Integridade

Para testes robustos, criamos scripts SQL que:
- Inserem clientes com IDs explícitos
- Inserem empréstimos, sempre referenciando um cliente válido
- Preenchem todos os campos obrigatórios, inclusive datas, taxas e status variados

Exemplo:

```sql
INSERT INTO clientes (id, nome, cpf, renda_mensal, score_credito, limite_pre_aprovado, historico_pagamento, tempo_relacionamento_bancario)
VALUES
  ('6858955b-a224-4586-90a6-5b49f257ba1d', 'João Silva', '12345678901', 5000.00, 750, 10000.00, 'bom', 36),
  ...
;

INSERT INTO emprestimos (
    id, cliente_id, valor, parcelas, valor_parcela, taxa_juros, data_contratacao, status, created_at, updated_at
) VALUES
    ('e1d1a1b1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '6858955b-a224-4586-90a6-5b49f257ba1d', 5000.00, 12, 450.00, 2.5, '2024-01-10 10:00:00-03', 'ativo', NOW(), NOW()),
    ...
;
```

---

## 6. Docker Compose: Orquestração dos Serviços

### O que é o Docker Compose?

O Docker Compose é uma ferramenta que permite definir e gerenciar múltiplos containers Docker como um único serviço. Isso é fundamental para projetos modernos, pois facilita a criação de ambientes isolados, reprodutíveis e portáteis.

### Estrutura do `docker-compose.yml` deste projeto

```yaml
version: '3.8'
services:
  db:
    image: supabase/postgres
    container_name: supabase_db
    restart: always
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_USER: postgres
      POSTGRES_DB: postgres
    volumes:
      - supabase_db_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - app-network

  n8n:
    image: n8nio/n8n
    container_name: n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: db
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: postgres
      DB_POSTGRESDB_USER: postgres
      DB_POSTGRESDB_PASSWORD: postgres
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - app-network
    depends_on:
      - db

volumes:
  supabase_db_data:
  n8n_data:

networks:
  app-network:
```

### Explicação das escolhas técnicas

#### 1. **Separação de Serviços**

- **db (Supabase/Postgres)**:  
  Escolhemos o container oficial do Supabase/Postgres para garantir compatibilidade com recursos modernos do Postgres, além de facilitar futuras integrações com o ecossistema Supabase.
- **n8n**:  
  Usamos a imagem oficial do N8N, que já vem pronta para ser conectada a diversos bancos e APIs.

#### 2. **Volumes**

- **supabase_db_data**:  
  Garante que os dados do banco persistam mesmo se o container for destruído. Isso é vital para não perder dados de clientes, empréstimos, etc.
- **n8n_data**:  
  Persiste as configurações e workflows criados no N8N, permitindo upgrades e restauração fácil.

#### 3. **Mount de Arquivo de Inicialização**

- O arquivo `init-db.sql` é montado em `/docker-entrypoint-initdb.d/` para inicializar o banco com a estrutura de tabelas e massa de dados assim que o container sobe.  
  Isso automatiza o setup e garante que todos tenham o mesmo ponto de partida.

#### 4. **Redes**

- **app-network**:  
  Todos os containers compartilham a mesma rede Docker interna, permitindo comunicação segura e isolada dos serviços do host e de outros containers externos.

#### 5. **Ports**

- **5432:5432** (db):  
  Expõe o banco de dados Postgres na porta padrão, facilitando o acesso para debugging e integração com ferramentas externas.
- **5678:5678** (n8n):  
  Expõe o painel web do N8N, permitindo orquestrar e monitorar os workflows via navegador.

#### 6. **Variáveis de Ambiente**

- Definimos explicitamente usuário, senha e nome do banco para garantir previsibilidade e facilitar troubleshooting.
- No N8N, as variáveis de ambiente apontam para o serviço `db`, usando nomes de host internos do Docker Compose, o que elimina a necessidade de IPs fixos.

#### 7. **depends_on**

- Garante que o serviço do banco de dados esteja disponível antes de iniciar o N8N, evitando falhas de conexão na inicialização.

#### 8. **restart: always**

- Mantém os serviços sempre ativos, reiniciando automaticamente em caso de falhas, o que é essencial para ambientes de produção ou testes robustos.

### Por que tudo isso importa?

- **Reprodutibilidade**: Qualquer pessoa pode clonar o projeto e subir o ambiente idêntico ao seu, sem surpresas.
- **Isolamento**: Mudanças em um serviço não afetam outros projetos ou o sistema operacional do host.
- **Automação**: O banco já nasce pronto, com tabelas e dados de teste, acelerando o desenvolvimento e testes.
- **Escalabilidade**: Fácil adicionar novos serviços (ex: frontend, workers) no futuro, apenas editando o `docker-compose.yml`.
- **Segurança**: O uso de redes e variáveis de ambiente evita exposição desnecessária de dados sensíveis.

---

## 7. Fluxo Funcional na Prática

1. **Recebimento do Pedido**  
   O N8N recebe dados da solicitação (por API, formulário, etc).

2. **Análise via IA**  
   Um node executa a análise de crédito utilizando IA, retornando decisão e justificativa.

3. **Preparação dos Dados**  
   O node “Code” trata e formata os dados para inserção.

4. **Registro no Banco**  
   O node PostgreSQL insere os dados na tabela correta, garantindo integridade e segurança.

5. **Resposta ao Solicitante**  
   O workflow retorna a decisão, justificativa e registra tudo para auditoria.

---

## 8. Segurança e Boas Práticas

- **Escapando Strings**: Sempre trate campos de texto para evitar problemas de sintaxe e segurança.
- **Parâmetros em SQL**: Nunca monte queries concatenando strings diretamente.
- **Relacionamentos**: Sempre garanta que IDs referenciados existam (integridade referencial).
- **Testes com Massa Realista**: Use dados variados para simular cenários reais e garantir robustez.

---

## 9. Conclusão: O Que Você Aprendeu

- Como estruturar um banco de dados relacional para análise de crédito
- Como usar Docker Compose para orquestrar múltiplos serviços
- Como criar workflows robustos no N8N, integrando IA e banco de dados
- Como garantir integridade e segurança na manipulação de dados
- Como preparar massa de dados realista para testes
- A importância de documentar e entender profundamente cada etapa do processo

---

## 10. Referências e Próximos Passos

- [Documentação do N8N](https://docs.n8n.io/)
- [Documentação do Supabase](https://supabase.com/docs)
- [PostgreSQL Best Practices](https://www.postgresql.org/docs/)
- [Técnica de Ensino de Feynman](https://pt.wikipedia.org/wiki/T%C3%A9cnica_de_Feynman)

---

Se quiser aprofundar ainda mais algum ponto, adicionar diagramas ou exemplos de código, é só pedir!  
Esse material está pronto para ser compartilhado, estudado e servir de base para evolução do seu projeto e aprendizado.
