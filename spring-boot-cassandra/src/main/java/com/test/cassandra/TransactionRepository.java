package com.test.cassandra;

import org.springframework.data.cassandra.repository.CassandraRepository;

import java.util.UUID;

public interface TransactionRepository extends CassandraRepository<Transaction, UUID> {
}