# sequencer-economics
Simulation modeling to stress test mechanism resilience and identify risk in the below proposed transaction fee mechanism.

# Goal

The purpose of this document is to propose a transaction fee mechanism for the XMTP Ethereum L2 and L3 chains. 

## Motivation

We would like to financially disincentivize spam and protect the network from DOS. Transaction fee mechanisms are the most reliably proven, credibly neutral way to mitigate spam in permissionless networks. A TFM introduces fees. There are two distinct user personas within the network: bulk senders and consumers. Each persona has a different willingness and ability to pay profile. The protocol should capture value from bulk senders, who are willing and able to pay, and distribute this value to consumer users, who are not willing to pay. However, attackers may simulate consumer users. In order for the protocol to sustainably operate, it must have some ability to reduce sybil and convey sender reputation.

## Proposal

Decouple required fees per message from the sequencer’s operational cost per message (i.e., DA and transaction proof settlement). Instead, a user that wishes to send many invite and conversation messages to the network from one XMTP identity (i.e., an outbox) within a short amount of time pays more than a user that sends few messages to the network within a short amount of time. This allows for very low fees for consumer patterns, yet imposes high fees for bulk sender patterns.

The sequencer effectively becomes the primary subsidizer for consumer users in the network. In order to reduce the operational risk taken on by the sequencer, the protocol mints enough XMTP tokens, on average over an acceptable time period, to service the sequencer’s ongoing costs and provide a target profit. By doing this the protocol assumes the operational risk of temporary cash flow mismatches (i.e., insufficient revenue to fund token mints).

The mechanism looks like this:

![image](https://github.com/trebor-yatska/sequencer-economics/assets/132451997/c55c27e5-6362-42b2-9876-944ed9e1977e)

The protocol takes on debt by minting XMTP to pay for t1 chain expenses. Fees received in t2 are burned in order to repay the t1 debt. 

Fees are denominated in ETH. All fees are swapped to XMTP and burned. 

The choice to denominate fees in ETH and compensate sequencers in XMTP means the protocol must periodically swap ETH for XMTP, and the sequencer must periodically swap XMTP for ETH. The rationale for this choice is as follows: the UX gains from using ETH as money are greater than the protocol’s cost of trading fees + exchange rate risk. The sequencer’s cost of exchange rate risk + trading fees is less than the sequencer’s operational risk + protocol’s risk of sequencer/user offchain collusion.  

### Permissionless sequencers and token rewards

Although not part of the initial roadmap, the chain can provide stronger censorship resistance and availability guarantees by rotating a set of staked, permissionless sequencers.

Decentralized sequencer operators will require techniques to mitigate operational risk. Some techniques, such as hedging and securing favorable operating loan terms can be achieved independent of the protocol. The protocol can offer operational risk mitigation through XMTP token batch rewards. 

Token rewards as the primary revenue source is also effective in mitigating offchain collusion between chain users and the decentralized sequencer operators. 

XMTP tokens rewards per batch are determined by targeting a return on investment for a protocol targeted stake amount. The targeted stake amount will depend on the level of chain economic security required. 

******************************************Scaling batch rewards******************************************

Scaling token rewards by the number of transactions in each batch is reasonable as the sequencer should be compensated according to the amount of work performed and transaction count determines the sequencer’s cost for executing the batch. However, there are two considerations for scaling batch rewards by batch transaction count: (1) the cost to execute, validate, and settle a transaction should be consistently low (<$0.01), especially considering message transaction size is constant; and, (2) scaling rewards up and down may incentivize sequencers to favor high transaction count batches over low; at the same time, holding reward rate constant would incentivize sequencers to favor low transaction batches over high. 

The first consideration above means costs should be manageable, even as transactions scale up. This provides some flexibility to choose a constant token reward rate for the protocol, as the ROI outcome over a sufficiently large period of batches should reach equilibrium. A sequencer’s profit should be constant so long as batches are evenly split between low and high transaction counts. 

The sequencer strategies alluded to in the second consideration above point to the need for a robust accountability mechanism that properly disincentivizes censoring. 

The decentralized sequencer model requires more analysis before roadmap inclusion. During the network bootstrap phase, XMTP Labs will run a centralized trusted sequencer. XMTP Labs will assume sequencer operational risk without requiring XMTP token batch rewards to offset risk.  

## Outbox base fees
![image](https://github.com/trebor-yatska/sequencer-economics/assets/132451997/8063a98f-0a7a-4009-87a9-3f4d07a4bf10)

The model requires a mechanism that would allow the protocol to track sender outbox state over time. The solution must maintain privacy.

A protocol base fee per outbox fluctuates depending on the demand from the outbox. Fees rise quickly as the outbox demands more network bandwidth within a short amount of time. As demand from the outbox subsides, fees fall quickly and are lower bounded by MIN_OUTBOX_GASPRICE. 

The mechanism is similar to the [EIP 4844 version](https://eips.ethereum.org/EIPS/eip-4844#blob-gasprice-update-rule) of the [EIP 1559 base fee](https://eips.ethereum.org/EIPS/eip-1559) calculation. 

**Example EIP 4844 mechanism applied to sender outboxes**

> The outbox base gas price update rule is intended to approximate the formula outbox_gasprice = MIN_OUTBOX_GASPRICE * e**(excess_outbox_gas / OUTBOX_GASPRICE_UPDATE_FRACTION), where excess_outbox_gas is the total “extra” amount of outbox gas that the outbox has consumed relative to the “targeted” number (TARGET_OUTBOX_GAS_PER_EPOCH per L2 epoch). Like EIP-1559, it’s a self-correcting formula: as the excess goes higher, the outbox_gasprice increases exponentially, reducing usage and eventually forcing the excess back down. The parameter OUTBOX_GASPRICE_UPDATE_FRACTION controls the maximum rate of change of the outboxes gas price. It is chosen to target a maximum change rate of e(TARGET_OUTBOX_GAS_PER_BLOCK / OUTBOX_GASPRICE_UPDATE_FRACTION) ≈ 1.125 per L2 epoch.
> 

Similar to EIP 1559, outboxes are throttled by a max gas used amount per epoch. This prevents outboxes from flooding the network with batched transactions in one epoch.

A separate message count would be maintained for both invite and conversation messages. 

Outbox state is maintained by the sequencer. The sequencer calculates required fees according to its local state. Any final solution must preserve sender anonymity.

The protocol relies on the sequencer to preload and maintain a “gas tank” for paying data availability and settlement costs for each message that gets executed. The sequencer is incentivized to take on this risk through XMTP token rewards for each confirmed batch. 

**************************Priority fees**************************

Sender-specified priority fee per message acts as a reputation signal for post delivery inbox app filtering algorithms. 

********************Inbox fees********************

A separate fee component fluctuates depending on demand for specific invite inboxes. Fees rise quickly as demand for the inbox increases within a short amount of time, converging towards a vertical asymptote (i.e., an exponential curve). This fee is calculated in the inbox smart contract.

******************************User experience******************************

Users can pay their own fees or have their fees subsidized by gateway providers. Users that wish to maintain full permissionless access to the system will pay their own fees. Gateways that wish to offer a subsidized free tier can implement a means of verification for Sybil resistance (own an ENS/xmtp.id, submit to proof-of-personhood verification, stake/register credit card).

### Pros

- Fee curves are designed to result in very low consumer messaging fees, and higher fees for bulk senders.
- The sequencer is incentivized by XMTP token batch rewards
- XMTP token compensation reduces the sequencer’s operational risk
- Burning fees instead of passing them to the sequencer ensures actors are protocol aligned (offchain collusion not a likely strategy)

### Cons

- System equilibrium is dependent on demand from bulk senders and the cost of DA and settlement. These two components fluctuate independently.
- System equilibrium also depends on currency exchange rates between XMTP, DA token, and ETH (i.e., exchange rate risk)
- The sequencer is exposed to XMTP, DA token, and ETH exchange rate risk

### Questions

- Should outbox fees adjust in response to global demand for settlement and DA?
    - When global demand for settlement and/or DA chain exceeds supply, a bottleneck will form on the L2 chain. The two ways to clear out the backlog is to outbid others for settlement and DA resources, or wait until demand subsides. There are UX implications for handling resource bottlenecks.
- Would we want any other smart contracts on the L2 chain besides the contact and inbox contracts?
- If we do want the L2 chain to be a general purpose smart contract chain, will the TFM proposed for the sequencer above work? How would the mechanism change the way existing dApps work? For instance, if the XMTP/ETH pool resides on the L2 chain, how would the fee mechanism change aspects of the DEX?
- Does the specified TFM provide DOS protection against intentional or unintentional infinite loops and transactions that demand heavy computation?
- If we accept ETH as the payment token, would we create a price ceiling for $XMTP? If XMTP is burned at a faster pace than it is minted, the price of XMTP/ETH will rise. Thus, we will be able to buy less XMTP with ETH denominated chain revenue. This reduces the burn rate, and causes XMTP supply to increase, which puts downward pressure on XMTP/ETH price.
    - One solution is to denominate chain fees in $XMTP.
- Can we get the full benefits of outbox base fees if gateways obfuscate the outbox? Would this result in the gateway being subjected to bulk sender pricing? Can [offchain account state](https://0xpolygonmiden.github.io/miden-base/architecture/state.html) and [transaction execution](https://0xpolygonmiden.github.io/miden-base/architecture/execution.html) help here?

## XMTP ID fees and sender reputation

Bulk senders benefit by building the reputation of their known addresses. For instance, by building the reputation of a 0x address or an ENS name, bulk senders can reliably avoid inbox app filtering algorithms, reach more of their audience, and enjoy more effective campaigns. 

However, mechanisms that require fees for bulk messaging patterns, while offering subsidies for consumer messaging patterns create a strong incentive for bulk senders to simulate consumer patterns. This incentive is most apparent for bulk senders not necessarily concerned with reputation (i.e., low reputation spammers).

A low reputation spammer can subsidize their campaign and significantly boost ROIs by simulating consumer patterns (i.e., create enough XMTP IDs to remain within the consumer fee structure). The protocol and users pay the price of this attack, through lost protocol revenue and increased spam. 

### Introducing cost to sybil attack

There are currently no registration fees in XMTP. Thus, the cost to spam the network from multiple unique IDs is essentially zero. 

The attack can be mitigated by moving contact bundle creation onchain, thus introducing a mandatory “registration fee”. 

A registration fee eliminates the linear cost savings available to sybil attackers in the above proposed economic model. However, registration is a one time event, and attackers would do well by reusing IDs. There may be ways to limit sybil address useful life, such as tracking them in extra-protocol lists maintained by inbox app providers.
