-- Habilitar a extensão uuid-ossp (necessária para gerar UUIDs)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de clientes
CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL,
    cpf TEXT UNIQUE NOT NULL,
    renda_mensal DECIMAL(10,2) NOT NULL,
    score_credito INTEGER NOT NULL,
    limite_pre_aprovado DECIMAL(10,2) NOT NULL,
    historico_pagamento TEXT, -- 'bom', 'regular', 'ruim'
    tempo_relacionamento_bancario INTEGER, -- em meses
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de empréstimos
CREATE TABLE emprestimos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID REFERENCES clientes(id),
    valor DECIMAL(10,2) NOT NULL,
    parcelas INTEGER NOT NULL,
    valor_parcela DECIMAL(10,2) NOT NULL,
    taxa_juros DECIMAL(5,2) NOT NULL,
    data_contratacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT NOT NULL, -- 'ativo', 'quitado', 'atrasado'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de solicitações de crédito
CREATE TABLE solicitacoes_credito (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID REFERENCES clientes(id),
    valor_solicitado DECIMAL(10,2) NOT NULL,
    parcelas_solicitadas INTEGER NOT NULL,
    parcelas_recomendadas INTEGER NOT NULL,
    valor_parcela_recomendado DECIMAL(10,2) NOT NULL,
    finalidade TEXT, -- 'pessoal', 'veículo', 'imóvel', 'educação', etc.
    resultado TEXT NOT NULL, -- 'aprovado', 'negado'
    motivo TEXT,
    analise_ia TEXT, -- Armazenar a análise completa da IA
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir clientes de exemplo

INSERT INTO clientes (id, nome, cpf, renda_mensal, score_credito, limite_pre_aprovado, historico_pagamento, tempo_relacionamento_bancario)
VALUES
  ('6858955b-a224-4586-90a6-5b49f257ba1d', 'João Silva', '123.456.789-01', 5000.00, 750, 10000.00, 'bom', 36),
  ('f7f29ac4-e348-4671-9823-c219439aa0f9', 'Maria Souza', '987.654.321-00', 3500.00, 680, 8000.00, 'regular', 24),
  ('041817b7-9eaa-4d37-9f4d-981818cdfc94', 'Carlos Pereira', '456.789.123-00', 7000.00, 820, 15000.00, 'bom', 48),
  ('4782f09d-0703-4b6e-a06d-0dd66cd8cfc8', 'Ana Oliveira', '321.654.987-00', 2500.00, 610, 5000.00, 'ruim', 12);

-- Inserir empréstimos existentes
-- Massa de dados para a tabela emprestimos (cliente_id compatível com clientes cadastrados)

INSERT INTO emprestimos (
    id, cliente_id, valor, parcelas, valor_parcela, taxa_juros, data_contratacao, status, created_at, updated_at
) VALUES
    ('e1d1a1b1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '6858955b-a224-4586-90a6-5b49f257ba1d', 5000.00, 12, 450.00, 2.5, '2024-01-10 10:00:00-03', 'ativo', NOW(), NOW()),
    ('e2d2a2b2-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'f7f29ac4-e348-4671-9823-c219439aa0f9', 8000.00, 24, 400.00, 3.2, '2023-05-15 15:30:00-03', 'quitado', NOW(), NOW()),
    ('e3d3a3b3-cccc-cccc-cccc-cccccccccccc', '041817b7-9eaa-4d37-9f4d-981818cdfc94', 12000.00, 18, 720.00, 4.0, '2022-08-20 09:15:00-03', 'atrasado', NOW(), NOW()),
    ('e4d4a4b4-dddd-dddd-dddd-dddddddddddd', '6858955b-a224-4586-90a6-5b49f257ba1d', 3000.00, 6, 520.00, 2.0, '2024-03-05 14:00:00-03', 'ativo', NOW(), NOW()),
    ('e5d5a5b5-eeee-eeee-eeee-eeeeeeeeeeee', 'f7f29ac4-e348-4671-9823-c219439aa0f9', 15000.00, 36, 480.00, 3.8, '2021-12-25 08:00:00-03', 'quitado', NOW(), NOW()),
    ('e6d6a6b6-ffff-ffff-ffff-ffffffffffff', '4782f09d-0703-4b6e-a06d-0dd66cd8cfc8', 2000.00, 4, 520.00, 1.5, '2024-04-01 11:20:00-03', 'ativo', NOW(), NOW());