# Live streaming Oracle -> PostgreSQL

## Setup
`docker compose up -d`

```
curl -X POST -H "Content-Type: application/json" \
  --data @connectors/oracle-source.json \
  http://localhost:8083/connectors
```
Check with `curl http://localhost:8083/connectors/oracle-source/status | jq`
```
{
  "name": "postgres-sink",
  "connector": {
    "state": "RUNNING",
    "worker_id": "172.18.0.6:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "172.18.0.6:8083"
    }
  ],
  "type": "sink"
}
```

```
curl -X POST -H "Content-Type: application/json" \
  --data @connectors/postgres-sink.json \
  http://localhost:8083/connectors
```
Check with `curl http://localhost:8083/connectors/postgres-sink/status | jq`

```

```

