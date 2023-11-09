# charts

bulkSenderInviteOutboxBaseFee <- function(bulk_sender_distribution_df) {
  
  # get columns for chart
  bulk_sender_distribution_df <- bulk_sender_distribution_df %>%
    select(campaign_msg_count, gas_cost_per_campaign_usd) %>%
    arrange(campaign_msg_count)
  
  # build the chart object
  chart_object <- ggplot(bulk_sender_distribution_df, aes(x=campaign_msg_count, y=gas_cost_per_campaign_usd)) +
    geom_line()
  
  # return the chart object
  return(chart_object)
}