# consumer invite assumptions
# consumer users send one invite per n days on avg
avg_consumer_invite_send_time_in_days <- 7
stddev_consumer_invite_send_time_in_days <- 6

#consumer user makeup of active outboxes
active_users_consumer_share <- .9

# chain stats
chain_batch_time_seconds <- 10 * 60 
outbox_epoch_time_seconds <- 5

# bulk sender assumptions
campaign_start_mean_interval_days <- 90
campaign_start_stddev_interval_days <- 60
campaign_invite_msg_count_mean <- 10000
campaign_invite_msg_count_stddev <- 5000
campaign_invite_msg_count_min <- 100

# outbox distribution
initial_active_outboxes <- 430000
bulk_sender_outboxes_initial <- (1-active_users_consumer_share) * initial_active_outboxes
consumer_outboxes_initial <- active_users_consumer_share * initial_active_outboxes

# outbox base fee curve params
min_outbox_gasprice <- 1
max_outbox_gas_per_epoch <- 363520
target_outbox_gas_per_epoch <- 181760
outbox_gasprice_update_fraction <- 3725354
# we can assume excess_outbox_gas is constant, since we make a simplifying assumption that bulk senders want to get their campaign done asap
excess_outbox_gas <- max_outbox_gas_per_epoch - target_outbox_gas_per_epoch

# number of days in simulation
n_days = 30

# bytes and gas per tx
bytes_per_tx <- 142
gas_per_byte <-	16
gas_per_tx <-	bytes_per_tx * gas_per_byte

#ETH values - daily volatility
eth_usd <- 1678
eth_usd_stddev <- 92