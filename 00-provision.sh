#!/bin/bash

docker compose up -d

sleep 5

sh ./setup_archivelog.sh

sleep 5

curl -X POST -H "Content-Type: application/json" \
  --data @connectors/oracle-source.json \
  http://localhost:8083/connectors

curl -X POST -H "Content-Type: application/json" \
  --data @connectors/postgres-sink.json \
  http://localhost:8083/connectors

sleep 5

echo ""
curl -s http://localhost:8083/connectors/oracle-source/status | jq
echo ""
curl -s http://localhost:8083/connectors/postgres-sink/status | jq
