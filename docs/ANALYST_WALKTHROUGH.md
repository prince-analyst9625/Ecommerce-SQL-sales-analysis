# Analyst walkthrough — E-commerce Sales Analysis

Use this as a concise guide for explaining the project to a recruiter or interviewer. **Do not describe the example questions below as verified findings**; run the SQL and examine the output before making factual claims about performance.

## 1. Business problem

An e-commerce operations team needs a reliable picture of sales, customer purchasing patterns, product performance and order/payment outcomes. Transactional data lives in related tables, so reported numbers depend on correct joins, definitions and filters.

## 2. Analytical approach

1. **Understand the schema:** inspect customers, products, orders, order items and payments, including their one-to-many relationships.
2. **Set the reporting rule:** count item sales only for delivered orders; exclude shipping fees from product revenue.
3. **Build descriptive KPIs:** revenue by time, location and product; average order value; category contribution.
4. **Analyze behavior:** identify repeat delivered customers and group customers by illustrative spending thresholds.
5. **Review trends:** compare available monthly revenue rows and calculate a rolling revenue sum with window functions.
6. **Check operations:** inspect cancellation/return rates and orders without a payment record.
7. **Explain limitations:** note synthetic data, missing calendar periods and estimated—not accounting—profit.

## 3. SQL features to demonstrate

| Feature | Where to show it | What it achieves |
| --- | --- | --- |
| Multi-table `JOIN` | Queries 6–9 | Links transactions with product and customer dimensions |
| `GROUP BY` / `HAVING` | Queries 6, 15 | Aggregates performance and filters repeat customers |
| CTE and `CASE` | Queries 16–17 | Builds readable, stepwise metrics and segments |
| `DENSE_RANK()` | Query 18 | Ranks top products within each category |
| `LAG()` / `NULLIF()` | Query 19 | Compares available months safely when denominators are zero |
| `SUM() OVER` | Queries 20–21 | Computes category shares and rolling revenue |
| `LEFT JOIN` / `IS NULL` | Queries 11–12, 25 | Finds missing matches as a data-quality check |

## 4. Business interpretation framework

When the SQL results have been executed and verified, follow this structure:

- **Observation:** What exactly changed, and in which time period or segment?
- **Possible explanation:** Which plausible business drivers could matter?
- **Validation:** What additional data (marketing campaigns, stockouts, traffic, promotions, shipping) would test the explanation?
- **Action:** What small, measurable next step could the team take?
- **Caveat:** What does this dataset *not* tell us?

For example, a category with high revenue is *not automatically* the most profitable; evaluate margin estimates and data assumptions separately.

## 5. Example interview answer

> “I built a MySQL e-commerce analytics project using five related tables and synthetic order data. I wrote 25 SQL queries covering revenue, product performance, customer behavior and operational metrics. I used joins, CTEs and window functions to calculate KPIs such as average order value, category revenue contribution and month-over-month growth. I also checked issues such as missing payment rows and documented why delivered-sales revenue differs from payment totals. The project demonstrates a reproducible analytics workflow, rather than claiming business impact from simulated data.”

## 6. What would make the project stronger?

- Capture verified SQL output with screenshots or a small results table and label it **synthetic sample data**.
- Add an interactive Power BI dashboard using a documented query export.
- Add unit-style SQL assertions for key relationships and metric totals.
- Build a calendar table for complete monthly reporting.
- Include business recommendations only after results are executed and validated.

[← Back to project](../README.md)
