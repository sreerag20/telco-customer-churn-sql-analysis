# 📊 Telco Customer Churn Analysis — SQL

> End-to-end SQL-based analysis of telecom customer churn behaviour, including data cleaning, exploratory analysis, churn risk scoring, and dashboard-ready KPI queries.

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/Language-SQL-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Dataset](https://img.shields.io/badge/Dataset-Kaggle-20beff?logo=kaggle)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Folder Structure](#folder-structure)
- [Data Sources](#data-sources)
- [How to Run / Reproduce](#how-to-run--reproduce)
- [Key Findings](#key-findings)
- [Future Improvements](#future-improvements)
- [License](#license)

---

## Project Overview

This project performs a structured analysis of IBM's Telco Customer Churn dataset using pure SQL (MySQL). The goal is to identify drivers of customer attrition, quantify revenue impact, and surface high-risk segments — insights that can directly inform retention strategy.

The analysis is structured across six layers:

1. **Database & table setup** — schema definition for 7,043 customer records across 21 attributes
2. **Data cleaning** — handling blank `total_charges` with controlled safe-update toggling
3. **Data transformation** — a reusable `churn_cleaned` view with customer segmentation (New / Mid-term / Long-term) and revenue tiers (Low / Medium / High)
4. **Exploratory Data Analysis (EDA)** — overall churn rate, churn by contract type, churn by internet service
5. **Business insight queries** — high-risk customer identification, monthly revenue loss from churn, and most valuable retained customers
6. **Advanced analytics** — a churn risk scoring model that assigns weighted penalty scores across four dimensions (contract type, tech support, tenure, internet service), then categorises each customer as Low / Medium / High Risk

Dashboard-ready KPI and segment summary queries are included at the end, making the output directly usable in BI tools such as Tableau, Power BI, or Looker.

---

## Tech Stack

| Layer          | Tool / Technology                                                                   |
|----------------|-------------------------------------------------------------------------------------|
| Database       | MySQL 8.0+                                                                          |
| Query Language | SQL (DDL + DML + Window Functions)                                                  |
| Data Format    | CSV (7,043 rows × 21 columns)                                                       |
| Source Dataset | [Kaggle — Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) |
| Version Control| Git / GitHub                                                                        |

---

## Folder Structure

```
telco-customer-churn-sql-analysis/
├── data/
│   ├── raw/
│   │   └── telco_customer_churn_raw.csv       # Original Kaggle dataset (unmodified)
│   └── processed/
│       └── telco_customer_churn_cleaned.csv   # Cleaned export (optional, for BI tools)
├── sql/
│   └── telco_churn_analysis.sql               # Full analysis script (DDL + EDA + scoring)
├── docs/
│   └── data_dictionary.md                     # Column definitions and value descriptions
├── exports/
│   └── (optional query result screenshots or CSV exports)
├── .gitignore
├── LICENSE
└── README.md
```

---

## Data Sources

**File:** `telco_customer_churn_raw.csv`  
**Source:** [IBM Sample Data — Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)  
**Rows:** 7,043 &nbsp;|&nbsp; **Columns:** 21

| Column | Type | Description |
|---|---|---|
| `customer_id` | VARCHAR | Unique customer identifier |
| `gender` | VARCHAR | Male / Female |
| `senior_citizen` | INT | 1 if senior citizen, else 0 |
| `partner` | VARCHAR | Whether the customer has a partner (Yes/No) |
| `dependents` | VARCHAR | Whether the customer has dependents (Yes/No) |
| `tenure` | INT | Months the customer has been with the company |
| `phone_service` | VARCHAR | Phone service subscription (Yes/No) |
| `multiple_lines` | VARCHAR | Multiple phone lines (Yes/No/No phone service) |
| `internet_service` | VARCHAR | DSL / Fiber optic / No |
| `online_security` | VARCHAR | Online security add-on (Yes/No/No internet) |
| `online_backup` | VARCHAR | Online backup add-on (Yes/No/No internet) |
| `device_protection` | VARCHAR | Device protection add-on (Yes/No/No internet) |
| `techsupport` | VARCHAR | Tech support add-on (Yes/No/No internet) |
| `streaming_tv` | VARCHAR | Streaming TV subscription (Yes/No/No internet) |
| `streaming_movies` | VARCHAR | Streaming movies subscription (Yes/No/No internet) |
| `contract` | VARCHAR | Month-to-month / One year / Two year |
| `paperless_billing` | VARCHAR | Paperless billing enrolled (Yes/No) |
| `payment_method` | VARCHAR | Electronic check / Mailed check / Bank transfer / Credit card |
| `monthly_charges` | FLOAT | Current monthly charge (USD) |
| `total_charges` | FLOAT | Total amount charged to date (USD); blanks converted to NULL |
| `churn` | VARCHAR | Whether the customer left (Yes/No) — **target variable** |

> **Note:** 11 records contain blank `total_charges` values (customers with zero tenure). These are set to `NULL` during the cleaning step.

---

## How to Run / Reproduce

### Prerequisites

- MySQL 8.0+ installed locally, or access to a MySQL-compatible cloud DB (e.g., AWS RDS, PlanetScale)
- A MySQL client: [MySQL Workbench](https://dev.mysql.com/downloads/workbench/), DBeaver, or the `mysql` CLI

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/your-username/telco-customer-churn-sql-analysis.git
cd telco-customer-churn-sql-analysis
```

**2. Import the raw dataset into MySQL**

Using MySQL Workbench:
- Open **Server → Data Import**
- Choose "Import from Self-Contained File" and select `data/raw/telco_customer_churn_raw.csv`
- Target schema: `customer_churn` (created automatically in step 3)

Using the CLI (after creating the DB):
```sql
LOAD DATA INFILE '/absolute/path/to/telco_customer_churn_raw.csv'
INTO TABLE telco
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

**3. Run the analysis script**
```bash
mysql -u your_username -p < sql/telco_churn_analysis.sql
```
Or open `sql/telco_churn_analysis.sql` in MySQL Workbench and execute it section by section.

**4. Explore the results**

Run any query block from the script individually in your MySQL client to inspect results. The script is fully annotated with numbered section headers for easy navigation.

---

## Key Findings

- **High overall churn rate:** Approximately **26.5%** of customers churned, representing a significant monthly revenue drain from the active customer base.
- **Month-to-month contracts are the strongest churn predictor:** Customers on flexible contracts churn at a drastically higher rate than one- or two-year subscribers, making contract type the most actionable retention lever.
- **Fiber optic users churn more than DSL users:** Despite being a premium tier, fiber optic subscribers show elevated churn — indicating possible dissatisfaction with price-to-value or service reliability.
- **New customers without tech support are the highest-risk cohort:** The risk scoring model (max score 7) flags customers with month-to-month contracts, no tech support, and tenure under 12 months as "High Risk" — the most cost-effective target for proactive retention outreach.

---

## Future Improvements

1. **Python + pandas integration** — Reproduce the cleaning and EDA layer in a Jupyter notebook for visual exploration (histograms, correlation heatmaps, churn distribution charts) alongside the SQL script.
2. **Predictive modelling** — Train a logistic regression or random forest classifier on the engineered features (risk score, customer segment, revenue segment) to output per-customer churn probabilities.
3. **BI dashboard** — Connect the MySQL database directly to Tableau or Power BI and build an interactive churn monitoring dashboard using the dashboard-ready queries already included in the script.

---

## License

This project is licensed under the [MIT License](LICENSE).  
Dataset sourced from [Kaggle — Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) (IBM Sample Data, public use).
