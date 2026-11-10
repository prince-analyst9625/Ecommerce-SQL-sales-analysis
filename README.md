# E-commerce Sales Analysis
### SQL portfolio project · MySQL 8.0+

A business-focused SQL project exploring sales performance, customer purchasing behavior, product performance, and payment records. The analysis contains **25 queries** that progress from aggregates and joins to CTEs and window functions.

[Explore the analysis](analysis_queries.sql) · [View the schema](schema.sql) · [View the seed data](seed_data.sql)

## Business questions

| Area | Questions explored | SQL techniques |
| --- | --- | --- |
| Sales performance | What is delivered revenue? How does it change by month? | Aggregation, date functions, joins |
| Products and categories | Which products lead sales? How much does each category contribute? | Multi-table joins, DENSE_RANK, window aggregates |
| Customer behavior | Who are the highest-spending customers? Who has repeat delivered orders? | HAVING, CASE, CTEs, LEFT JOIN |
| Growth and trends | What is month-over-month revenue growth? What is the rolling revenue total? | LAG, window frames, NULLIF |
| Operations and payments | What are the cancellation and return rates? Are payments missing? | Conditional aggregation, referential checks |

## Data model

The schema includes five related tables:

| Table | Grain | Purpose |
| --- | --- | --- |
| customers | One row per customer | Customer attributes and geography |
| products | One row per product | Categories, listed prices, and cost estimates |
| orders | One row per order | Customer, date, status, and shipping fee |
| order_items | One row per order item | Product quantities, sale prices, and discounts |
| payments | At most one row per order | Payment method, status, and amount |

Orders link to customers; order items link to orders and products; payments link to orders. Primary keys, foreign keys, uniqueness rules, and CHECK constraints define the model.

## Run the project

**Requirements:** MySQL 8.0+ and a SQL client such as MySQL Workbench or the MySQL command-line client. Use a local practice database and an account permitted to create it.

1. Run [schema.sql](schema.sql) to create the `ecommerce_analytics` database and tables.
2. Run [seed_data.sql](seed_data.sql) to load the supplied records.
3. Run [analysis_queries.sql](analysis_queries.sql), ideally one query at a time, to inspect the results.

From the MySQL client, started in the repository directory:

```sql
SOURCE schema.sql;
SOURCE seed_data.sql;
SOURCE analysis_queries.sql;
```

The seed script should be inspected before rerunning it in a database that already contains data.

## Metric definitions

- **Delivered revenue:** sum of `quantity × unit_price × (1 − discount_pct / 100)` for delivered orders.
- **Average order value:** average of delivered order totals, calculated at order level.
- **Estimated gross profit:** delivered item revenue minus quantity multiplied by the product's listed cost.
- **Cancellation / return rate:** cancelled / returned orders as a percentage of all orders.
- **Revenue share:** a category's delivered revenue divided by total delivered revenue.

Shipping fees are excluded from product revenue. Payment totals are separate measures and should not be treated as interchangeable with delivered item revenue.

## Analysis guide

| Queries | Focus |
| --- | --- |
| 1–7 | Table preview, status counts, customer geography, revenue, and product performance |
| 8–14 | City and customer revenue, AOV, customers without orders, unsold products, estimated profit, and payments |
| 15–17 | Repeat customers, high-value orders, and spending segments |
| 18–21 | Product ranking, month-over-month growth, category share, and rolling revenue |
| 22–25 | Cancellation, returns, payment statuses, and orders missing a payment record |

## Interpretation and limitations

This repository demonstrates SQL analysis using the supplied seed data. The queries describe analytical questions; this README does not claim numerical findings or business impact without executed results.

- Gross profit uses the current listed product cost, rather than historical accounting costs.
- The rolling window uses the current and previous two **available monthly rows**. Missing calendar months are not filled.
- Month-over-month growth compares consecutive available monthly rows; use a calendar table if missing months need explicit handling.
- Customer spending segments use fixed project thresholds, rather than a validated business segmentation model.
- The missing-payment query checks for absent records; it does not establish payment settlement or reconciliation.

## Skills demonstrated

**SQL · MySQL · Relational modeling · Joins · Aggregation · Subqueries · CTEs · Window functions · KPI definitions · Data validation**

---

Created as part of [Prince's data analytics portfolio](https://github.com/prince-analyst9625).
