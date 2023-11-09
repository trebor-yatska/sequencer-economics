# outbox base and priority fee functions

# outbox base fees
outboxBaseFeeCurve <- function(tx_count, min_outbox_gasprice, max_outbox_gas_per_epoch, 
                               target_outbox_gas_per_epoch, outbox_gasprice_update_fraction, excess_outbox_gas, 
                               gas_per_tx) {
  
  # gas_cost_total variable for return
  gas_cost_total <- 0
  
  # for each tx_count
  txs_in_epoch <- max_outbox_gas_per_epoch / gas_per_tx
  # print(paste('number of txs that can be executed per epoch', txs_in_epoch))
  epochs_to_complete_campaign <- tx_count / txs_in_epoch
  # print(paste(epochs_to_complete_campaign, 'campaign epochs'))
  
  # set initial gas price
  epoch_outbox_base_gas_price <- min_outbox_gasprice
  for (i in 1:ceiling(epochs_to_complete_campaign)) {
    
    # calculate epoch gas cost depending on number of txs in epoch
    if (i == ceiling(epochs_to_complete_campaign)) {
      last_epoch_tx_count <- txs_in_epoch * (epochs_to_complete_campaign - floor(epochs_to_complete_campaign))
      # print(paste('last epoch tx count', last_epoch_tx_count))
      gas_cost_epoch <- last_epoch_tx_count * gas_per_tx * epoch_outbox_base_gas_price
    } else {
      gas_cost_epoch <- txs_in_epoch * gas_per_tx * epoch_outbox_base_gas_price
    }
    # print(paste('gas cost (gwei) in epoch', i, 'is ', gas_cost_epoch))
    
    # keep track of campaign total gas cost
    gas_cost_total <- gas_cost_total + gas_cost_epoch
    # print(paste('gas cost (gwei) total in epoch', i, 'is ', gas_cost_total))
    
    # set gas price for next epoch using the number of txs
    # assumption: we assume bulk senders use naive strategy. They use up max gas per epoch. -----------------------assumption
    epoch_outbox_base_gas_price <- max(epoch_outbox_base_gas_price*(exp(1)^(excess_outbox_gas / outbox_gasprice_update_fraction)))
    # print(paste('outbox gas fee in epoch', i+1, 'is ', epoch_outbox_base_gas_price))
  }
  
  return(gas_cost_total)
  
}


