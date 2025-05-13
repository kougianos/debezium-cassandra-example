# Cassandra-Debezium POC

## Quickstart
```bash
# Set the Debezium version
export DEBEZIUM_VERSION=2.1

# Start all required containers: Cassandra, Kafka, Zookeeper, Connector
docker-compose -f docker-compose-cassandra.yaml up --build

# Consume messages from the customers topic
winpty docker-compose -f docker-compose-cassandra.yaml exec kafka /kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --from-beginning --property print.key=true --topic test_prefix.testdb.customers

# Connect to Cassandra CQL shell in another terminal
winpty docker-compose -f docker-compose-cassandra.yaml exec cassandra bash -c 'cqlsh --keyspace=testdb'

# Insert a new customer
INSERT INTO customers(id,first_name,last_name,email) VALUES (5,'Roger','Poor','roger@poor.com');

# Watch the kafka event being published in the corresponding topic
```

## References 
- [Cassandra CDC Docs](https://cassandra.apache.org/doc/latest/cassandra/managing/operating/cdc.html)
- [Debezium connector for Cassandra](https://debezium.io/documentation/reference/stable/connectors/cassandra.html)
- [Official debezium examples repository](https://github.com/debezium/debezium-examples/blob/main/tutorial/README.md#using-cassandra)

## Overview and important information

This project demonstrates how to set up and use the Debezium connector for Apache Cassandra to capture and stream data changes (Change Data Capture or CDC) to Apache Kafka. <br>
It was forked from the official debezium-examples repo and stripped down to include only what’s necessary for running a Cassandra CDC PoC using Debezium.

The `config.properties` here includes two critical properties that are missing in the official example, which are essential to trigger near real-time CDC events even for small changes:

```bash
# These 2 properties are important for triggering real time CDC events. If set to false CDC events will be sent in batches only when the max batch size is reached.
commit.log.real.time.processing.enabled=true
commit.log.marked.complete.poll.interval.ms=1000
```

## Components

This project includes the following components:

1. **Apache Cassandra** - NoSQL distributed database with CDC enabled
2. **Apache Kafka** - Distributed event streaming platform
3. **Apache ZooKeeper** - Coordination service for distributed applications
4. **Debezium Cassandra Connector** - The connector that captures changes from Cassandra and sends them to Kafka

## Project Structure

- **docker-compose-cassandra.yaml**: Docker Compose file that sets up the entire infrastructure (Cassandra, Kafka, ZooKeeper)
- **debezium-cassandra-init/**: Directory containing initialization and configuration files
  - **Dockerfile**: Builds a custom Cassandra image with Debezium connector
  - **cassandra.yaml**: Cassandra configuration file
  - **config.properties**: Debezium connector configuration
  - **inventory.cql**: Sample data schema and initial data
  - **log4j.properties**: Logging configuration for the connector
  - **startup-script.sh**: Script that initializes the Cassandra instance and starts the connector
- **Event Examples**: Sample JSON files showing the format of events produced by the connector
  - **insert-event-example.json**: Example of an insert event
  - **update-event-example.json**: Example of an update event
  - **delete-event-example.json**: Example of a delete event

## Database Schema

The sample database (`testdb`) includes the following tables, all with CDC enabled:

1. **products**: Product catalog with fields:
   - id (primary key)
   - name
   - description
   - weight

2. **products_on_hand**: Inventory information with fields:
   - product_id (primary key)
   - quantity

3. **customers**: Customer information with fields:
   - id (primary key)
   - first_name
   - last_name
   - email

## How It Works

1. **Cassandra CDC**: When enabled on a table, Cassandra records all changes to a commit log
2. **Debezium Connector**: Monitors the commit log for changes
3. **Event Transformation**: Changes are transformed into a consistent event format
4. **Kafka Publishing**: Events are published to Kafka topics using the format `<prefix>.<keyspace>.<table>`

## Configuration

Key configuration properties for the Debezium connector include:

- `connector.name`: Name of the connector instance (set to "test_connector")
- `commit.log.relocation.dir`: Directory for processing commit logs
- `cassandra.hosts` and `cassandra.port`: Connection details for Cassandra
- `kafka.producer.bootstrap.servers`: Connection details for Kafka
- `topic.prefix`: Prefix for Kafka topics (set to "test_prefix")
- `snapshot.mode`: Controls how initial snapshots are taken (set to "ALWAYS")
- `commit.log.real.time.processing.enabled`: Enables real-time CDC event triggering

## Running the Project

### Prerequisites

- Docker and Docker Compose installed
- Sufficient system resources to run the containers

### Start the Infrastructure

```bash
# Set the Debezium version
export DEBEZIUM_VERSION=2.1

# Start the containers
docker-compose -f docker-compose-cassandra.yaml up --build
```

### Monitor Change Events

```bash
# Consume messages from the customers topic
winpty docker-compose -f docker-compose-cassandra.yaml exec kafka //kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server kafka:9092 \
  --from-beginning \
  --property print.key=true \
  --topic test_prefix.testdb.customers
```

### Modify Data to Generate Events

```bash
# Connect to Cassandra CQL shell
winpty docker-compose -f docker-compose-cassandra.yaml exec cassandra bash -c 'cqlsh --keyspace=testdb'

# Insert a new customer
INSERT INTO customers(id,first_name,last_name,email) VALUES (5,'Roger','Poor','roger@poor.com');

# Update a customer
UPDATE customers set first_name = 'Barry' where id = 5;

# Delete a customer
DELETE FROM customers WHERE id = 5;
```

### Shut Down

```bash
# Stop and remove containers, networks, and volumes
winpty docker-compose -f docker-compose-cassandra.yaml down -v
```

## Event Structure

The connector generates events in JSON format with a structure that includes:

1. **Key**: Contains the primary key of the modified row
2. **Value**: Contains the details of the change:
   - Metadata about the change (timestamp, operation type)
   - Source information (connector, database, table, etc.)
   - The actual data change (before and after states for updates)

The `op` field in the event indicates the type of operation:
- `c` - Create (INSERT)
- `u` - Update (UPDATE)
- `d` - Delete (DELETE)

## Use Cases

This setup can be used for various purposes:

1. **Real-time Analytics**: Stream changes to analytical systems
2. **Data Integration**: Synchronize Cassandra data with other systems
3. **Audit Trail**: Maintain a complete history of data changes
4. **Caching**: Keep caches up-to-date with the latest data
5. **Microservices**: Enable event-driven communication between services