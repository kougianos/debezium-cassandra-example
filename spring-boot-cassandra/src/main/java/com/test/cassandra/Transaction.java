package com.test.cassandra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.cassandra.core.cql.PrimaryKeyType;
import org.springframework.data.cassandra.core.mapping.CassandraType;
import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.PrimaryKeyColumn;
import org.springframework.data.cassandra.core.mapping.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

import static org.springframework.data.cassandra.core.mapping.CassandraType.Name;

@Table("transactions")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Transaction {

    @PrimaryKeyColumn(name = "operator_id", type = PrimaryKeyType.PARTITIONED)
    private String operatorId;

    @PrimaryKeyColumn(name = "player_id", type = PrimaryKeyType.PARTITIONED)
    private String playerId;

    @PrimaryKeyColumn(name = "date", type = PrimaryKeyType.PARTITIONED)
    private LocalDate date;

    @PrimaryKeyColumn(name = "id", type = PrimaryKeyType.CLUSTERED)
    @CassandraType(type = Name.TIMEUUID)
    private UUID id;

    @Column("amount")
    private BigDecimal amount;

    @Column("bonus_type")
    private short bonusType;

    @Column("currency")
    private String currency;

    @Column("external_id")
    private String externalId;

    @Column("game_session_id")
    private String gameSessionId;

    @Column("instance_id")
    private String instanceId;

    @Column("jackpot_amount")
    private BigDecimal jackpotAmount;

    @Column("jackpot_id")
    private String jackpotId;

    @Column("jackpot_level")
    private short jackpotLevel;

    @Column("round")
    private long round;

    @Column("step")
    private long step;

    @Column("type")
    private short type;

    @Column("version_id")
    private String versionId;
}
