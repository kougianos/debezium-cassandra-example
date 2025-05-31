#!/bin/bash

# Wait for Cassandra to be fully initialized
echo "Waiting for Cassandra to be ready..."
while ! cqlsh -e "DESCRIBE keyspaces" | grep -q "testdb"; do
  sleep 5
  echo "Still waiting for Cassandra..."
done

echo "Cassandra is ready. Starting auto-insertion of records..."

# Counter for generating unique values
counter=1000

while true; do
  uuid=$(uuidgen)
  operator_id="op1"
  player_id="player1"
  date=$(date +%F) # format: YYYY-MM-DD
  amount=$(shuf -i 1-1000 -n 1)
  bonus_type=$((RANDOM % 5))
  currency="EUR"
  external_id="ext$counter"
  game_session_id="gsess$counter"
  instance_id="inst$counter"
  jackpot_amount=$(shuf -i 0-5000 -n 1)
  jackpot_id="jp$counter"
  jackpot_level=$((RANDOM % 4))
  round=$((RANDOM % 100))
  step=$((RANDOM % 10))
  type=$((RANDOM % 3))
  version_id="v$((RANDOM % 10))"

  cql_command="INSERT INTO testdb.transactions (
    operator_id, player_id, date, id, amount, bonus_type, currency,
    external_id, game_session_id, instance_id, jackpot_amount,
    jackpot_id, jackpot_level, round, step, type, version_id
  ) VALUES (
    '$operator_id', '$player_id', '$date', now(), $amount, $bonus_type, '$currency',
    '$external_id', '$game_session_id', '$instance_id', $jackpot_amount,
    '$jackpot_id', $jackpot_level, $round, $step, $type, '$version_id'
  );"

  echo "Executing: $cql_command"
  cqlsh -e "$cql_command"

  counter=$((counter + 1))
  echo "Waiting 2 seconds before next insertion..."
  sleep 2
done
