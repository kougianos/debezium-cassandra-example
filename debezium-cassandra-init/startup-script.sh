#!/bin/sh

# Replace placeholders in cassandra.yaml using env vars
sed -i "s/__NODE_NAME__/${NODE_NAME}/g" /opt/cassandra/conf/cassandra.yaml
sed -i "s/__CASSANDRA_SEEDS__/${CASSANDRA_SEEDS}/g" /opt/cassandra/conf/cassandra.yaml

# Start Cassandra in background
sh /opt/cassandra/bin/cassandra -f &

# Wait for Cassandra to be ready (max 60 seconds)
timeout=60
elapsed=0
until cqlsh -e "SELECT cluster_name FROM system.local;" >/dev/null 2>&1; do
  sleep 2
  elapsed=$((elapsed + 2))
  if [ "$elapsed" -ge "$timeout" ]; then
    echo "Cassandra did not become ready in time; proceeding anyway"
    break
  fi
done

# Initialize schema only from one node
if [ "$NODE_NAME" = "cassandra-1" ]; then
  echo "Initializing schema from $NODE_NAME"
  cqlsh -f $DEBEZIUM_HOME/inventory.cql
fi

# Optional auto-insert
# $DEBEZIUM_HOME/auto-insert.sh > /tmp/auto-insert.log 2>&1 &

# Start Debezium connector
java -Dlog4j.info -Dlog4j.configuration=file:$DEBEZIUM_HOME/log4j.properties --add-exports java.base/jdk.internal.misc=ALL-UNNAMED --add-exports java.base/jdk.internal.ref=ALL-UNNAMED --add-exports java.base/sun.nio.ch=ALL-UNNAMED --add-exports java.management.rmi/com.sun.jmx.remote.internal.rmi=ALL-UNNAMED --add-exports java.rmi/sun.rmi.registry=ALL-UNNAMED --add-exports java.rmi/sun.rmi.server=ALL-UNNAMED --add-exports java.sql/java.sql=ALL-UNNAMED --add-opens java.base/java.lang.module=ALL-UNNAMED --add-opens java.base/jdk.internal.loader=ALL-UNNAMED --add-opens java.base/jdk.internal.ref=ALL-UNNAMED --add-opens java.base/jdk.internal.reflect=ALL-UNNAMED --add-opens java.base/jdk.internal.math=ALL-UNNAMED --add-opens java.base/jdk.internal.module=ALL-UNNAMED --add-opens java.base/jdk.internal.util.jar=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens jdk.management/com.sun.management.internal=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED -jar $DEBEZIUM_HOME/debezium-connector-cassandra.jar $DEBEZIUM_HOME/config.properties
