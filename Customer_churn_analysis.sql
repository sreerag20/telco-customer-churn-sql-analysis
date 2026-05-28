create database customer_churn;

use customer_churn;

drop table if exists telco;

# 1. Creating table telco

create table telco (
     customer_id varchar(40),
     gender varchar(20),
     senior_citizen int,
     partner varchar(20),
     dependents varchar(20),
     tenure int,
     phone_service varchar(20),
     multiple_lines varchar(30),
     internet_service varchar(30),
     online_security varchar(30),
     online_backup varchar(30),
     device_protection varchar(30), 
     techsupport varchar(30),
     streaming_tv varchar(30),
     streaming_movies varchar(30),
     contract varchar(60),
     paperless_billiing varchar(20),
     payment_method varchar(60),
     monthly_charges float,
     total_charges float,
     churn varchar(20));

# 2. Handling blank total_charges with controlled disabling of SQL safe update mode

set sql_safe_updates = 0;

update telco
set total_charges = null
where total_charges ="";

set sql_safe_updates = 1;

# 3. Data Transformation

create view churn_cleaned as
select
      customer_id,
      gender,
      senior_citizen,
      tenure,
      contract, 
      internet_service,
      techsupport,
      payment_method,
      monthly_charges,
      total_charges,
      churn,
      case
          when tenure < 12 then 'New'
          when tenure < 36 then 'Mid-term'
          else 'Long-term'
	  end as customer_segment,
      case
          when monthly_charges < 40 then 'Low'
          when monthly_charges < 80 then 'Medium'
          else 'High'
	  end as revenue_segment
from telco;

# 4. Exploratory Data Analysis (EDA)
# Churn Rate

select 
      churn, 
      count(*) as customers, 
      round(count(*)*100.0/sum(count(*)) over(), 2) as chrn_rate
from churn_cleaned
group by churn;

# Churn by contract

select
      contract,
      count(*) as total,
      sum(case when churn = 'Yes' then 1 else 0 end) as churned,
      round(sum(case when churn = 'Yes' then 1 else 0 end)* 100.0 / count(*), 2) as churn_rate
from churn_cleaned
group by contract
order by churn_rate desc;

# Churn by internet service

select
      internet_service,
      count(*) as total,
      sum(case when churn = 'Yes' then 1 else 0 end) as churned,
      round(sum(case when churn = 'Yes' then 1 else 0 end)* 100.0 / count(*), 2) as churn_rate
from churn_cleaned
group by internet_service;

# 5. Business insight queries
# High risk customers

select * 
from churn_cleaned
where
     contract = 'Month-to-month'
     and techsupport = 'No'
     and tenure < 12;
     
# Revenue loss due to churn

select
      round(sum(monthly_charges),2) as monthly_revenue_loss
from churn_cleaned 
where churn = 'Yes';
      
# Most valuable retained customer

select * 
from churn_cleaned
where churn = 'No'
order by total_charges desc
limit 10;

# 6. Advanced analytics layer
# Churn risk scoring model

select *,
      case
          when contract = 'Month-to-month' then 2 else 0 end +
	  case 
          when techsupport = 'No' then 2 else 0 end +
	  case 
          when tenure < 12 then 2 else 0 end + 
	  case 
          when internet_service = 'Fiber optic' then 1 else 0 end 
	  as risk_score
from churn_cleaned;

# Categorize risk levels

select *,
	case
		when risk_score >= 5 then 'High Risk'
        when risk_score >= 3 then 'Medium Risk'
        else 'Low Risk'
	end as risk_category
from (
	select *,
		case 
			when contract = 'Month-to-month' then 2 else 0 end +
		case 
			when techsupport = 'No' then 2 else 0 end +
		case
			when tenure < 12 then 2 else 0 end +
		case 
			when internet_service = 'Fiber optic' then 1 else 0 end
		as risk_score
	from churn_cleaned
)t;

# 7. Dashboard-ready queries
# KPI table

select 
	count(*) as total_customers,
    sum(case when churn = 'Yes' then 1 else 0 end) as churned_customers,
    round(sum(case when churn = 'Yes' then 1 else 0 end)*100.0/ count(*), 2) as churn_rate,
    round(sum(monthly_charges), 2) as total_monthly_revenue
from churn_cleaned;

# Segment summary

select
	customer_segment,
    count(*) as customers,
    sum(case when churn = 'Yes' then 1 else 0 end) as churned
from churn_cleaned
group by customer_segment;
      
      
     



