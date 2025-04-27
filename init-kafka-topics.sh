#!/bin/bash
set -e

KAFKA_BROKER="kafka:9092"
TOPICS=(
  "decisao_aprovada"
  "decisao_negada"
  # Adicione outros tópicos conforme necessário
)
RETENTION_MS=43200000 # 12 horas

# Função para aguardar o Kafka estar disponível
wait_for_kafka() {
  echo "Aguardando o Kafka responder em $KAFKA_BROKER..."
  for i in {1..20}; do
    if kafka-topics --bootstrap-server $KAFKA_BROKER --list > /dev/null 2>&1; then
      echo "Kafka disponível!"
      return 0
    fi
    echo "Kafka ainda não está disponível. Tentando novamente em 3s... ($i/20)"
    sleep 3
  done
  echo "Kafka não respondeu a tempo. Abortando."
  exit 1
}

wait_for_kafka

for topic in "${TOPICS[@]}"; do
  echo "Criando tópico: $topic"
  kafka-topics --create --if-not-exists \
    --topic "$topic" \
    --bootstrap-server $KAFKA_BROKER \
    --partitions 1 \
    --replication-factor 1 \
    --config retention.ms=$RETENTION_MS
  echo "Tópico $topic criado (ou já existia)."
done
