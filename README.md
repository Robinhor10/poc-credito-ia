# POC de Análise de Crédito com Inteligência Artificial

## O que é esta POC?

Esta Prova de Conceito (POC) demonstra como uma instituição financeira pode automatizar a análise de pedidos de crédito (empréstimos) usando tecnologia moderna e Inteligência Artificial (IA). O objetivo é mostrar como é possível tomar decisões mais rápidas, justas e explicáveis, sem depender apenas de regras fixas ou análise manual.

---

## Por que automatizar a análise de crédito?

Tradicionalmente, bancos e financeiras usam regras rígidas ou análise manual para decidir se um cliente pode ou não receber um empréstimo. Isso pode ser demorado, caro e, às vezes, injusto. Com IA, é possível analisar diversos fatores ao mesmo tempo e tomar decisões mais personalizadas, além de explicar claramente o motivo de cada decisão.

---

## Como funciona este projeto?

### 1. Recebendo o pedido do cliente

- O cliente faz um pedido de crédito (empréstimo), informando:
  - CPF (identificação)
  - Valor desejado do empréstimo
  - Quantidade de parcelas que gostaria de pagar
  - Finalidade do empréstimo (ex: reforma, viagem, etc.)

### 2. Buscando informações no banco de dados

- O sistema consulta um banco de dados para buscar:
  - Dados cadastrais e financeiros do cliente (renda, score de crédito, limite pré-aprovado, etc.)
  - Quais empréstimos o cliente já possui e quanto paga por eles

### 3. Preparando a análise

- O sistema calcula quanto da renda do cliente já está comprometida com outros empréstimos.
- Simula diferentes opções de parcelamento para o novo empréstimo.
- Junta todas essas informações em um texto explicativo (chamado de “prompt”).

### 4. Análise com Inteligência Artificial

- O texto explicativo é enviado para um serviço de IA (OpenAI), que “pensa” como um analista humano.
- A IA avalia se o empréstimo deve ser aprovado ou não, qual o número ideal de parcelas e o valor recomendado para cada parcela.
- A IA também explica o motivo da decisão, de forma clara.

### 5. Registrando e respondendo

- O resultado da análise é salvo no banco de dados para histórico.
- O sistema responde ao cliente, informando:
  - Se o crédito foi aprovado ou negado
  - O motivo da decisão
  - Quantas parcelas são recomendadas e qual o valor ideal de cada parcela

---

## Quais tecnologias são usadas?

- **Supabase**: Um banco de dados online onde ficam armazenadas todas as informações dos clientes e empréstimos.
- **N8N**: Uma ferramenta que conecta diferentes sistemas e automatiza o fluxo de trabalho.
- **OpenAI**: Serviço de Inteligência Artificial que faz a análise do crédito.
- **Docker**: Um programa que facilita instalar e rodar todos esses sistemas juntos, sem complicação.

---

## Passo a passo visual do processo

```mermaid
flowchart TD
    Cliente(Pedido de crédito) --> WebhookN8N(Webhook N8N)
    WebhookN8N --> ConsultaBD(Consulta banco de dados)
    ConsultaBD --> PreparaPrompt(Prepara informações para IA)
    PreparaPrompt --> OpenAI(Análise com Inteligência Artificial)
    OpenAI --> Interpreta(Interpreta resposta da IA)
    Interpreta --> RegistraBD(Registra resultado no banco)
    Interpreta --> RespondeCliente(Envia resposta ao cliente)
```

---

## Exemplos práticos

### Exemplo de pedido de crédito

```json
{
  "cpf": "12345678900",
  "valor": 5000,
  "parcelas": 24,
  "finalidade": "Reforma"
}
```

### Exemplo de resposta ao cliente

```json
{
  "sucesso": true,
  "resultado": "aprovado",
  "motivo": "Cliente com bom histórico e renda suficiente.",
  "parcelas_recomendadas": 24,
  "valor_parcela_recomendado": 220.00,
  "comprometimento_atual": "25%",
  "novo_comprometimento": "35%",
  "analise_completa": "DECISÃO: APROVADO ... (texto completo da IA)"
}
```

---

## Estrutura do banco de dados (resumido)

| Tabela                  | O que armazena?                                                    |
|-------------------------|---------------------------------------------------------------------|
| clientes                | Dados pessoais e financeiros de cada cliente                        |
| emprestimos             | Empréstimos já contratados pelo cliente                            |
| solicitacoes_credito    | Histórico de todos os pedidos de crédito realizados                |
| parametros_credito      | (Opcional) Regras gerais de aprovação, se desejar usar junto com IA |

---

## Como rodar o projeto (passo a passo simples)

1. **Instale o Docker** (não precisa instalar cada sistema separadamente).
2. **Baixe os arquivos do projeto**.
3. **Configure as senhas e chaves** (instruções no README).
4. **Execute o comando para subir os containers:**
   ```sh
   docker-compose up -d
   ```
5. **Acesse o painel do N8N** pelo navegador para acompanhar o fluxo.
6. **Faça um teste**: envie um pedido de crédito e veja a resposta automática!

---

## Comandos úteis do Docker

- **Subir os containers do projeto:**
  ```sh
  docker-compose up -d
  ```

- **Parar todos os containers do projeto:**
  ```sh
  docker-compose down
  ```

- **Parar e remover containers, redes e volumes (apaga os dados do banco!):**
  ```sh
  docker-compose down -v
  ```

- **Verificar containers ativos:**
  ```sh
  docker ps -a
  ```

- **Remover um container específico:**
  ```sh
  docker rm nome_do_container
  ```

> **Atenção:** O comando `docker-compose down -v` apaga todos os dados persistidos do banco de dados. Use com cuidado se quiser manter o histórico!

---

## Por que este projeto é inovador?

- **Decisão rápida e personalizada**: a IA analisa cada caso individualmente.
- **Transparência**: o cliente sempre sabe o motivo da decisão.
- **Facilidade de uso**: todo o processo é automatizado, sem necessidade de conhecimento técnico.
- **Flexibilidade**: pode ser adaptado para qualquer instituição financeira.

---

## Glossário

- **POC**: Prova de Conceito, um experimento para testar uma ideia.
- **IA**: Inteligência Artificial, tecnologia que simula o raciocínio humano.
- **Webhook**: Um ponto de entrada para receber informações de outros sistemas automaticamente.
- **Docker**: Ferramenta para rodar vários sistemas juntos, sem conflito.
- **N8N**: Plataforma para automatizar tarefas e conectar diferentes sistemas.

---

## Configuração do arquivo `.env`

> **Importante:**
> Ao clonar este repositório, você deve criar um arquivo chamado `.env` na raiz do projeto para que o ambiente funcione corretamente. Este arquivo **NÃO** é versionado por questões de segurança.

### Exemplo de configuração do arquivo `.env`

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
POSTGRES_HOST=db
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin@example.com
N8N_BASIC_AUTH_PASSWORD=n8n
```

- Altere os valores conforme necessário para seu ambiente.
- Estes valores são usados automaticamente pelo Docker Compose e pelos serviços do projeto.

Se tiver dúvidas sobre a configuração, consulte a documentação ou o arquivo `docker-compose.yml` para ver como as variáveis são utilizadas.

---

## Estrutura dos Arquivos do Projeto

Abaixo está uma explicação dos principais arquivos e diretórios deste projeto e seus respectivos objetivos:

| Arquivo/Diretório                | Objetivo                                                                 |
|----------------------------------|--------------------------------------------------------------------------|
| `README.md`                      | Documentação principal do projeto, instruções de uso e informações gerais|
| `.gitignore`                     | Lista de arquivos e pastas ignorados pelo Git (ex: `.env`, dados locais) |
| `.env`                           | Variáveis de ambiente sensíveis (NÃO versionado, exemplo no README)      |
| `docker-compose.yml`             | Orquestração dos containers Docker (banco, N8N, etc)                     |
| `init-db.sql`                    | Script SQL para criar e popular o banco de dados com massa de teste      |
| `docs/estrutura-db.md`           | Documentação detalhada do modelo de dados e exemplos de inserts          |
| `docs/guia-refatoracao.md`       | Guia técnico e didático sobre toda a refatoração e decisões do projeto   |
| `n8n_data/`                      | Volume Docker para persistir dados e workflows do N8N                    |
| `supabase_db_data/`              | Volume Docker para persistir dados do banco Postgres/Supabase            |
| `docs/`                          | Pasta para documentação adicional, guias e apresentações                 |

- Outros arquivos e diretórios podem ser adicionados conforme o projeto evolui.
- Sempre consulte esta seção ou o próprio arquivo para entender o propósito de cada item.

---

Se precisar de ilustrações, exemplos adicionais ou quiser adaptar o texto para slides, só avisar!
