# 🛒 E-commerce Sales Analysis | SQL Portfolio Project

**Business-focused sales, customer and operational analytics using MySQL 8.0+.**

[![SQL](https://img.shields.io/badge/SQL-MySQL%208.0%2B-4479A1?logo=mysql&logoColor=white)](https://dev.mysql.com/doc/)
![Analysis queries](https://img.shields.io/badge/Analysis-25%20SQL%20queries-2563EB)
![Data](https://img.shields.io/badge/Dataset-Synthetic%20practice%20data-64748B)
![Focus](https://img.shields.io/badge/Focus-Business%20KPIs-16A34A)

> **Portfolio case study:** How can an e-commerce team use order, product, customer and payment data to understand revenue, purchasing patterns and operational performance?

**Explore:** [Business questions](#-business-objectives) · [Data model](#-data-model) · [Metrics](#-key-performance-indicators) · [SQL analysis](analysis_queries.sql) · [How to run](#-reproduce-the-analysis) · [Limitations](#-interpretation--limitations)

## 🔎 Project overview

This project models a small e-commerce business with five linked tables and answers **25 analytical questions**, from descriptive reporting to SQL window functions. The objective is to demonstrate a transparent, reproducible workflow for defining KPIs and exploring business performance.

| At a glance | Details |
| --- | --- |
| **Technology** | MySQL 8.0+ |
| **Dataset** | Synthetic practice data (not real customers or production transactions) |
| **Database** | `ecommerce_analytics` |
| **Data model** | Five related tables: customers, products, orders, order_items, payments |
| **Seed script** | 80 customers, 32 products, 420 orders, 923 order items and 420 payments |
| **Analysis** | 25 SQL queries |
| **SQL techniques** | Joins, CASE, HAVING, subqueries, CTEs, DENSE_RANK, LAG, rolling SUM |
| **Business focus** | Revenue, product mix, customers, growth, order outcomes, payments |

## 🎯 Business objectives

| Business question | What the SQL explores |
| --- | --- |
| **How are sales performing?** | Delivered revenue, monthly trend, order value |
| **What sells best?** | Product and category revenue, category contribution, category-level rankings |
| **Who buys repeatedly?** | Highest-value customers, repeat orders, spending segments |
| **How is performance changing?** | Month-over-month growth and rolling three-month revenue |
| **Where are operational issues?** | Cancellation rate, return rate, payment statuses and missing payment records |

## 🗃️ Data model

```text
customers (1) ───────< orders (1) ───────< order_items >─────── (1) products
                         │
                         └────────── (0..1) payments
```

| Table | Grain | Main fields |
| --- | --- | --- |
| `customers` | Customer | Customer ID, city, state, signup date |
| `products` | Product | Product ID, category, listed price, cost estimate |
| `orders` | Order | Order ID, customer ID, date, status |
| `order_items` | Line item | Order ID, product ID, quantity, sold price, discount |
| `payments` | Payment record | Order ID, method, status, amount |

Primary keys, foreign keys and CHECK constraints are defined in [`schema.sql`](schema.sql). The seed contains one payment record per order; the schema allows an order to have at most one payment record.

## 📊 Key performance indicators

| KPI | Definition / business rule |
| --- | --- |
| **Delivered revenue** | Sum of delivered line-item `quantity * unit_price * (1 - discount_pct / 100)` |
| **Average order value (AOV)** | Average **delivered order total**, computed at order grain |
| **Estimated gross profit** | Delivered item revenue minus quantity × *current listed* product cost |
| **Category revenue share** | Category delivered revenue / all delivered revenue |
| **Month-over-month growth** | (Current month revenue - previous available month revenue) / previous available month revenue |
| **Cancellation rate** | Cancelled orders / all orders |
| **Return rate** | Returned orders / all orders |

**Important:** Product revenue excludes shipping fees; payment amounts are distinct from delivered item revenue. The formulas, edge cases and caveats are explained in [`docs/METRICS_AND_ASSUMPTIONS.md`](docs/METRICS_AND_ASSUMPTIONS.md).

## 🧠 SQL techniques demonstrated

- **Joins and aggregations:** delivered revenue by category, city, customer and product.
- **CTEs and conditional logic:** high-value orders and customer segments.
- **Window functions:** `DENSE_RANK()` for product rankings, `LAG()` for revenue comparisons, `SUM() OVER` for rolling trends.
- **Data-quality questions:** missing payment records, customers without orders and unsold products.

**[📄 Read all 25 SQL queries →](analysis_queries.sql)**

## ▶️ Reproduce the analysis

**Prerequisites:** MySQL 8.0+ and a compatible SQL client (e.g. MySQL Workbench).

1. Clone or download this repository.
2. Execute [`schema.sql`](schema.sql) to create the database and five tables.
3. Execute [`seed_data.sql`](seed_data.sql) **once** to load the synthetic records.
4. Execute [`analysis_queries.sql`](analysis_queries.sql) to inspect the metrics and breakdowns.

In a MySQL client started from the project directory:

```sql
SOURCE schema.sql;
SOURCE seed_data.sql;
SOURCE analysis_queries.sql;
```

⚠️ The seed file uses explicit IDs and is **not designed to be rerun on an already-populated database**. Inspect scripts before executing them.

## 📁 Repository structure

```text
Ecommerce-SQL-sales-analysis/
├── README.md                         # Project introduction and navigation
├── schema.sql                        # Database tables, keys and constraints
├── seed_data.sql                     # Synthetic practice data
├── analysis_queries.sql              # 25 analytical queries
└── docs/
    ├── METRICS_AND_ASSUMPTIONS.md    # Definitions, scope and interpretation
    ├── ANALYST_WALKTHROUGH.md        # Interview-ready business case narrative
    └── GITHUB_PROFILE_README.md      # Reusable personal profile README template
```

## 💡 How to discuss the analysis

This repository demonstrates **how to calculate business metrics**, not a verified set of production findings. After running the queries, compare category sales, customer behavior and monthly revenue, then discuss plausible business hypotheses and what further data would be needed to test them.

For an interview-style explanation of the problem, approach, and possible next steps, see [`docs/ANALYST_WALKTHROUGH.md`](docs/ANALYST_WALKTHROUGH.md).

## ⚠️ Interpretation & limitations

- The dataset is **synthetic**; conclusions should not be presented as real-world company performance.
- Revenue is for **delivered** orders only. Shipping is excluded.
- Estimated profit uses the product's **current** listed cost rather than historical cost.
- Month-over-month changes compare **consecutive available months**; a calendar table would be needed to report missing months explicitly.
- The rolling three-month window counts three available month rows, which may not represent three consecutive calendar months.
- Customer segment cutoffs are project-defined examples, **not validated segmentation thresholds**.
- A missing payment record check does **not** establish settlement, reconciliation or fraud.

## 👤 About the analyst

**Prince Dubey** — aspiring Data Analyst based in Gurugram, India, with hands-on SQL, Power BI, Excel and Python training.

[GitHub profile](https://github.com/prince-analyst9625) · [LinkedIn](https://www.linkedin.com/in/prince-dubey-7b5248299/) · [Email](mailto:prince962536@gmail.com)

---

*Made for learning, reproducibility and discussion of practical SQL analytics.*
