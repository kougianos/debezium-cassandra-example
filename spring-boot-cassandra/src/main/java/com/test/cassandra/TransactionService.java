package com.test.cassandra;

import com.datastax.oss.driver.api.core.uuid.Uuids;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Random;

@Slf4j
@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final Random random = new Random();

    @Scheduled(fixedRate = 2000)
    public void insertRandomTransaction() {
        try {
            Transaction tx = new Transaction();
            tx.setOperatorId("op1");
            tx.setPlayerId("player" + random.nextInt(5));
            tx.setDate(LocalDate.now());
            tx.setId(Uuids.timeBased());
            tx.setAmount(BigDecimal.valueOf(random.nextInt(1000)));
            tx.setBonusType((short) random.nextInt(5));
            tx.setCurrency("EUR");
            tx.setExternalId("ext" + random.nextInt(10000));
            tx.setGameSessionId("gsess" + random.nextInt(10000));
            tx.setInstanceId("inst" + random.nextInt(10000));
            tx.setJackpotAmount(BigDecimal.valueOf(random.nextInt(5000)));
            tx.setJackpotId("jp" + random.nextInt(10));
            tx.setJackpotLevel((short) random.nextInt(4));
            tx.setRound(random.nextInt(100));
            tx.setStep(random.nextInt(10));
            tx.setType((short) random.nextInt(3));
            tx.setVersionId("v" + random.nextInt(5));

            transactionRepository.save(tx);
            log.info("Inserted: {}", tx);
        } catch (Exception e) {
            log.error("Error inserting transaction", e);
        }
    }

    @Scheduled(fixedRate = 4000)
    public void fetchAllTransactions() {
        try {
            log.info("Fetching all transactions...");
            long count = transactionRepository.findAll().spliterator().getExactSizeIfKnown();
            if (count == -1) {
                count = transactionRepository.findAll().size();
            }
            log.info("Total transactions found: {}", count);
        } catch (Exception e) {
            log.error("Error fetching transactions", e);
        }
    }

}
