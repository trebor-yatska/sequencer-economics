# bulk sender active campaigns per day
activeCampaigns <- function(n_days, campaign_start_mean_interval_days, campaign_start_stddev_interval_days, campaign_invite_msg_count_mean,
                            campaign_invite_msg_count_stddev, bulk_sender_outboxes_initial) {
  # calculate the number of campaigns kicking off for the day
  active_campaigns_distribution <- rnorm(n_days, campaign_start_mean_interval_days, campaign_start_stddev_interval_days)
  # replace negatives with zeros
  active_campaigns_distribution[active_campaigns_distribution<0] <- 0
  
  # calculate bulk sender campaign volume for today
  # assume that for each day, all senders send same amount of invites in that day ---------------------------------- assumption
  campaign_msg_count <- rnorm(n_days, campaign_invite_msg_count_mean, campaign_invite_msg_count_stddev)
  # replace negatives with minimum campaign msgs
  campaign_msg_count[campaign_msg_count<0] <- campaign_invite_msg_count_min
  
  # create a df from vector
  campaign_df <- data.frame(day = sequence(n_days), active_campaigns_distribution, campaign_msg_count) %>% 
    mutate(active_campaigns_today = bulk_sender_outboxes_initial / active_campaigns_distribution) %>%
    mutate(daily_campaign_total_msg_count = active_campaigns_today * campaign_msg_count)

  # return df
  return(campaign_df)
}

