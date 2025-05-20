#!/bin/bash

# Wait for Cassandra to be fully initialized
echo "Waiting for Cassandra to be ready..."
while ! cqlsh -e "DESCRIBE keyspaces" | grep -q "testdb"; do
  sleep 5
  echo "Still waiting for Cassandra..."
done

echo "Cassandra is ready. Starting auto-insertion of records..."

# Counter for generating unique IDs
counter=1000

# Infinite loop to insert records every 2 seconds
while true; do
  # Generate a unique customer record
  id=$counter
  first_name="AutoUser$counter"
  last_name="Generated"
  email="auto$counter@example.com"
  
  # Insert the record into Cassandra
  cql_command="INSERT INTO testdb.customers(id,first_name,last_name,email) VALUES ($id,'$first_name','$last_name','$email');"
  echo "Executing: $cql_command"
  cqlsh -e "$cql_command"
  
  # Increment counter for next record
  counter=$((counter + 1))
  
  # Wait for 2 seconds before next insertion
  echo "Waiting 2 seconds before next insertion..."
  sleep 2
done
