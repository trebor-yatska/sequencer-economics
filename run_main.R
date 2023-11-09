library(dplyr)
library(ggplot2)
library(plotly)

source(paste0(getwd(),"/config.r"))
source(paste0(getwd(),"/bulk_sender_tx_volumes.r"))
source(paste0(getwd(),"/outbox_fee_curves.r"))
source(paste0(getwd(),"/charts.r"))

# select bulk sender distribution stats for the day
bulk_sender_distribution_df <- activeCampaigns(n_days, campaign_start_mean_interval_days, campaign_start_stddev_interval_days, campaign_invite_msg_count_mean,
                                               campaign_invite_msg_count_stddev, bulk_sender_outboxes_initial)

# apply each day's campaign msg count to outbox base fee curve
# pass campaign msg count as a vector to function - returns a vector of total gas cost per campaign for the specific day
msg_count_vec <- bulk_sender_distribution_df[['campaign_msg_count']]
campaign_total_gas_cost_vec <- sapply(msg_count_vec,outboxBaseFeeCurve,
                        min_outbox_gasprice=min_outbox_gasprice, max_outbox_gas_per_epoch=max_outbox_gas_per_epoch,
                        target_outbox_gas_per_epoch=target_outbox_gas_per_epoch, outbox_gasprice_update_fraction=outbox_gasprice_update_fraction, 
                        excess_outbox_gas=excess_outbox_gas,gas_per_tx=gas_per_tx
                       )

# bind vec to df
bulk_sender_distribution_df['gas_cost_per_campaign'] <- campaign_total_gas_cost_vec

# if active campaigns are zero, then make the whole row zero
bulk_sender_distribution_df[(bulk_sender_distribution_df$active_campaigns_distribution==0)|(bulk_sender_distribution_df$campaign_msg_count==0),c("campaign_msg_count","active_campaigns_today","daily_campaign_total_msg_count","gas_cost_per_campaign")] <- 0

# simulate avg eth/usd for each day, convert gas cost from gwei to usd, and multiply gas cost per campaign by number of campaigns that day
bulk_sender_distribution_df <- bulk_sender_distribution_df %>%
  rowwise() %>%
  mutate(eth_usd_daily_avg = rnorm(1, eth_usd, eth_usd_stddev)) %>%
  ungroup() %>%
  mutate(gas_cost_per_campaign_usd = (gas_cost_per_campaign/(10^9))*eth_usd_daily_avg,
         bulk_sender_invite_gas_fees_per_day_usd = active_campaigns_today * gas_cost_per_campaign_usd)

# calculate consumer invites for the day, and gas paid by consumers
# assumption: we assume consumers pay minimum gas price --------------------------- assumption
bulk_sender_distribution_df <- bulk_sender_distribution_df %>% 
  rowwise() %>% 
  mutate(consumer_invite_send_time_in_days = rnorm(1, avg_consumer_invite_send_time_in_days, stddev_consumer_invite_send_time_in_days)) %>%
  ungroup() %>%
  mutate(consumer_invite_volume_per_day = consumer_outboxes_initial/consumer_invite_send_time_in_days,
         consumer_invite_gas_fees_per_day_usd = ((consumer_invite_volume_per_day * min_outbox_gasprice)/10^9)*eth_usd_daily_avg)

str(bulk_sender_distribution_df)
head(bulk_sender_distribution_df)

# line chart of bulk sender invite campaign msg count and cost per campaign
bulk_sender_invite_outbox_base_fee_chart <- bulkSenderInviteOutboxBaseFee(bulk_sender_distribution_df)
ggplotly(bulk_sender_invite_outbox_base_fee_chart)

# need to come up with a better curve
# document assumptions
