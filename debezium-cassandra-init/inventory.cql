CREATE KEYSPACE testdb
WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 3}
AND durable_writes = true;

USE testdb;

CREATE TABLE transactions (
  operator_id ASCII,
  player_id ASCII,
  date DATE,
  id TIMEUUID,
  amount DECIMAL,
  bonus_type SMALLINT,
  currency ASCII,
  external_id ASCII,
  game_session_id ASCII,
  instance_id ASCII,
  jackpot_amount DECIMAL,
  jackpot_id ASCII,
  jackpot_level SMALLINT,
  round BIGINT,
  step BIGINT,
  type SMALLINT,
  version_id ASCII,
  PRIMARY KEY ((operator_id, player_id, date), id)
) WITH cdc = true;

INSERT INTO transactions (
  operator_id, player_id, date, id, amount, bonus_type, currency,
  external_id, game_session_id, instance_id, jackpot_amount,
  jackpot_id, jackpot_level, round, step, type, version_id
) VALUES (
  'op1', 'player1', toDate(now()), now(), 100.00, 1, 'EUR',
  'ext123', 'gsess1', 'inst1', 500.00, 'jp1', 2, 10, 1, 1, 'v1'
);

INSERT INTO transactions (
  operator_id, player_id, date, id, amount, bonus_type, currency,
  external_id, game_session_id, instance_id, jackpot_amount,
  jackpot_id, jackpot_level, round, step, type, version_id
) VALUES (
  'op1', 'player1', toDate(now()), now(), 200.00, 0, 'USD',
  'ext456', 'gsess2', 'inst2', 1000.00, 'jp2', 3, 11, 2, 2, 'v2'
);
