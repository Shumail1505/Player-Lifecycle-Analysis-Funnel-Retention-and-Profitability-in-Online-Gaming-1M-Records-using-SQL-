-- Funnel Counts + conversion %
With registrations as
(Select src_player_id, Signup_Date, acquisition_channel
From Player_Details
Where Internal_Player_YN = 'N'),

deposits as (
Select src_player_id, First_Deposit_Date
From First_Deposit_Data
Where First_Deposit_Date IS NOT NULL),

bets as (
Select src_player_id, System_First_Bet_Datetime
From First_Bet_Data
Where 
System_First_Bet_Slip_Amt IS NOT NULL and
System_First_Bet_Product_Group IS NOT NULL and
System_First_Bet_Product IS NOT NULL and
System_First_Bet_Channel IS NOT NULL and
System_First_Bet_Platform IS NOT NULL),

active30 as
(Select pa.src_player_id
From Player_Activity_Data pa
Join Player_Details pd 
on pa.src_player_id = pd.src_player_id
Where pa.Activity_Month <= DATE_ADD(pd.Signup_Date, INTERVAL 30 DAY)
Group by pa.src_player_id)

Select
Count(Distinct r.src_player_id) as registrations,
Count(Distinct d.src_player_id) as first_deposits,
Count(Distinct b.src_player_id) as first_bets,
Count(Distinct a.src_player_id) as active_30d,
Round(100.0*Count(Distinct d.src_player_id)/NULLIF(Count(Distinct r.src_player_id),0),2) as reg_to_dep_pct,
Round(100.0*Count(Distinct b.src_player_id)/NULLIF(Count(Distinct d.src_player_id),0),2) as dep_to_bet_pct,
Round(100.0*Count(Distinct a.src_player_id)/NULLIF(Count(Distinct b.src_player_id),0),2) as bet_to_active30_pct 
From registrations r
Left Join deposits d on r.src_player_id = d.src_player_id
Left Join bets b on r.src_player_id = b.src_player_id
Left Join active30 a on r.src_player_id = a.src_player_id;


-- Drop-off by acquisition channel
With funnel as (
Select pd.acquisition_channel,
Count(Distinct pd.src_player_id) as registrations,
Count(Distinct fd.src_player_id) as first_deposits,
Count(Distinct fb.src_player_id) as first_bets,
Count(Distinct pa.src_player_id) as active_30d
From Player_Details pd
Left Join First_Deposit_Data fd on pd.src_player_id = fd.src_player_id and fd.First_Deposit_Date IS NOT NULL
Left Join First_Bet_Data fb on pd.src_player_id = fb.src_player_id and fb.System_First_Bet_Datetime IS NOT NULL
Left Join Player_Activity_Data pa 
on pd.src_player_id = pa.src_player_id
and pa.Activity_Month <= DATE_ADD(pd.Signup_Date, INTERVAL 30 DAY)
Where pd.Internal_Player_YN = 'N'
Group by pd.acquisition_channel)

Select *,
Round(100.0*first_deposits/NULLIF(registrations,0),2) as reg_to_dep_pct, 
Round(100.0*first_bets/NULLIF(first_deposits,0),2) as dep_to_bet_pct,
Round(100.0*active_30d/NULLIF(first_bets,0),2) as bet_to_active30_pct
From funnel;

-- Retention & Engagement
With player_days as 
(Select pa.src_player_id,
Sum(pa.Active_Player_Days) as days_active
From Player_Activity_Data pa
Join Player_Details pd on pa.src_player_id = pd.src_player_id
Where pa.Activity_Month <= DATE_ADD(pd.Signup_Date, INTERVAL 30 DAY)
Group by pa.src_player_id),

cohorts as
(Select src_player_id,
Case 
When days_active Between 1 and 2 Then '1–2'
When days_active Between 3 and 5 Then '3–5'
When days_active Between 6 and 10 Then '6–10'
When days_active > 10 Then '10+'
else '0' END as cohort
From player_days),

deposits as 
(Select src_player_id, Sum(First_Deposit_Amount) as total_deposit
From First_Deposit_Data
Where First_Deposit_Date IS NOT NULL
Group by src_player_id)

Select c.cohort,
Count(Distinct c.src_player_id) as players,
Sum(d.total_deposit) as total_deposits,
Round(100.0*Sum(d.total_deposit)/NULLIF((Select Sum(total_deposit) From deposits),0),2) as pct_of_deposits 
From cohorts c
Left Join deposits d on c.src_player_id = d.src_player_id
Group by c.cohort
Order by total_deposits DESC;

-- Gap Between first deposit and first bet
With gaps as 
(Select 
d.src_player_id,
DATEDIFF(b.System_First_Bet_Datetime, d.First_Deposit_Date) as gap_days
From First_Deposit_Data d
Join First_Bet_Data b 
on d.src_player_id = b.src_player_id
Where d.First_Deposit_Date IS NOT NULL
and b.System_First_Bet_Datetime IS NOT NULL),

ranked as 
(Select 
gap_days,
PERCENT_RANK() OVER (Order by gap_days) as pr
From gaps)

Select 
Round(AVG(gap_days),2) as mean_gap,
MAX(Case When pr <= 0.50 Then gap_days END) as median_gap,
MAX(Case When pr <= 0.75 Then gap_days END) as p75_gap,
MAX(gap_days) as max_gap
From ranked;


-- Top 10% by deposits
With deposits as (
Select src_player_id, Sum(First_Deposit_Amount) as total_deposit
From First_Deposit_Data
Where First_Deposit_Date IS NOT NULL
Group by src_player_id),

ranked as 
(Select src_player_id, total_deposit,
NTILE(10) OVER (Order by total_deposit DESC) as decile
From deposits)

Select 
Sum(Case When decile=1 Then total_deposit END) as top10_deposits,
Sum(total_deposit) as total_deposits,
Round(100.0*Sum(Case When decile=1 Then total_deposit END)/NULLIF(Sum(total_deposit),0),2) as top10_share_pct 
From ranked;

-- first deposit amounts by binning them into meaningful buckets.
With deposits as 
(Select 
src_player_id, 
First_Deposit_Amount
From First_Deposit_Data
Where First_Deposit_Date IS NOT NULL)

Select Case 
When First_Deposit_Amount Between 0 and 10 Then '0–10'
When First_Deposit_Amount Between 11 and 50 Then '11–50'
When First_Deposit_Amount Between 51 and 100 Then '51–100'
When First_Deposit_Amount Between 101 and 500 Then '101–500'
Else '500+' end as deposit_bucket,
Count(*) as num_players,
Sum(First_Deposit_Amount) as total_amount,
Round(AVG(First_Deposit_Amount),2) as avg_amount
From deposits
Group by deposit_bucket
Order by MIN(First_Deposit_Amount);




