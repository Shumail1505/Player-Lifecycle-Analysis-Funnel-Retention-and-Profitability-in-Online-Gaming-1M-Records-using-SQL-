This Project analyzes player behavior across the lifecycle — from registration to deposit, first bet, and early activity. The aim is to identify funnel drop-offs, retention patterns, engagement gaps, and deposit concentration to inform customer acquisition, engagement, and retention strategies. 

Datasets Used: 
• Player_Details → registration info & acquisition channel
• First_Deposit_Data → first deposit date, method, and amount   
• First_Bet_Data → timestamp and details of first bet 
• Player_Activity_Data → player betting activity (days active, amounts, wins/losses)  
• BonusCost_Data → bonus incentives provided to players 

Approach: 
• Funnel analysis → Registrations → First Deposit → First Bet → Active 30 Days 
• Retention & Engagement → Active days cohorting, deposit contribution 
• Engagement Lag → Gap between first deposit and first bet 
• Segmentation → Top 10% depositors and deposit bucket distributions

Conclusion: 
Key Takeaways 
1. Funnel Conversion 
o Out of 290,715 registered players, only 43.7% converted to depositors. 
o The largest drop-off occurs between registration and deposit, especially in 
Affiliate and Social channels. 
o Interestingly, the number of bettors exceeds depositors (>100% conversion), 
suggesting that some players are betting without deposits, likely due to bonus 
bets or missing deposit records. 
o Retention after the first bet is very strong (≈94%), showing that once players 
engage, they tend to stay active. 
2. Retention & Engagement 
o Cohort analysis shows that lightly active players (1–5 days) contribute the largest 
share of deposits (~52%), while 10+ day players contribute less (~19%). 
o This indicates the presence of “high-value sprinters” who deposit heavily in the 
short term before churning, versus steady recreational players who engage 
longer with smaller deposits. 
o Gap analysis reveals that most players place their first bet immediately (median 
and 75th percentile = 0 days). Negative mean values suggest betting before 
deposits, again pointing to bonuses or data issues. 
3. Player Segmentation 
o The top 10% of players contribute 48.6% of deposits, highlighting a whale
driven economy with high concentration of value. 
o First deposit amounts cluster around 11–50 (influenced by preset payment 
options and bonuses). 
o High-value buckets (101–500, 500+) represent fewer players but contribute 
disproportionately to total deposits.
