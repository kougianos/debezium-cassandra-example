## Using Cassandra Debezium connector

```shell 
# Start the topology as defined in https://debezium.io/documentation/reference/stable/tutorial.html
export DEBEZIUM_VERSION=2.1

docker-compose -f docker-compose-cassandra.yaml up --build

# Consume messages from a Debezium topic
winpty docker-compose -f docker-compose-cassandra.yaml exec kafka //kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --from-beginning --property print.key=true --topic test_prefix.testdb.customers

# Modify database
winpty docker-compose -f docker-compose-cassandra.yaml exec cassandra bash -c 'cqlsh --keyspace=testdb'

INSERT INTO customers(id,first_name,last_name,email) VALUES (5,'Roger','Poor','roger@poor.com');
UPDATE customers set first_name = 'Barry' where id = 5;
DELETE FROM customers WHERE id = 5;

# Shut down the cluster
winpty docker-compose -f docker-compose-cassandra.yaml down -v
```