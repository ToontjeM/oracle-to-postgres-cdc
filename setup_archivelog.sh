#!/bin/bash

echo "Waiting for Oracle to be ready..."
# Loop until the specific success message appears in the logs
until docker logs oracle 2>&1 | grep -q "DATABASE IS READY TO USE"; do
    echo "Oracle is starting... (checking again in 5s)"
    sleep 5
done

echo "Oracle is UP. Enabling Archivelog Mode..."

# Run the SQL commands safely
docker exec -i oracle sqlplus sys/password as sysdba <<EOF
   SHUTDOWN IMMEDIATE;
   STARTUP MOUNT;
   ALTER DATABASE ARCHIVELOG;
   ALTER DATABASE OPEN;
   ALTER PLUGGABLE DATABASE ALL OPEN;
   EXIT;
EOF

echo "Restarting Debezium Connector to pick up the change..."
docker restart debezium

echo "Done! Archivelog is enabled and Debezium has been restarted."
