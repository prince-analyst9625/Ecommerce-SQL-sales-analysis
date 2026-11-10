# Metric definitions and analysis assumptions

This companion document explains exactly how the queries in [`analysis_queries.sql`](../analysis_queries.sql) calculate business KPIs. The project uses synthetic practice data and **does not report independently verified business outcomes**.

## Reporting scope and grain

- **Data:** 80 customers, 32 products, 420 orders, 923 order lines and 420 payment records in the supplied synthetic seed script.
- **Delivered-order filter:** Most sales/revenue KPIs only count rows whose `orders.order_status = 'Delivered'`.
- **Order lines:** `order_items` can have many rows for one order; count `DISTINCT order_id` when asking how many orders there are after joining order items.
- **Prices:** Use the actual `order_items.unit_price` and `discount_pct` for sales, not the product's current list price.
- **Currencies:** The analysis script uses rupee symbols in the high-value threshold description, but the schema does **not enforce a currency**. Treat numeric outputs as dataset currency units unless currency metadata is added.

## KPI dictionary

| KPI | Definition | Query |
| --- | --- | --- |
| Delivered revenue | `SUM(quantity * unit_price * (1 - discount_pct / 100))` for delivered orders | 4 |
| Monthly delivered revenue | Above formula grouped by `YYYY-MM` of order date | 5 |
| Product/category revenue | Delivered item revenue grouped by product/category | 6–7 |
| Customer lifetime revenue *within dataset* | Delivered item revenue grouped by customer | 9 |
| Average order value | First sum each delivered order's item revenue, then average across those orders | 10 |
| Estimated gross profit | Delivered item revenue minus `SUM(quantity * products.cost_price)` | 13 |
| Repeat delivered customers | Customers with `COUNT(DISTINCT delivered order_id) >= 2` | 15 |
| Spending segments | High: >= 10,000; Mid: >= 4,000; Low: below 4,000 in dataset currency units | 17 |
| Product rank by category | `DENSE_RANK()` on delivered revenue within category | 18 |
| Month-over-month growth | `100 * (revenue - LAG(revenue)) / NULLIF(LAG(revenue), 0)` | 19 |
| Category revenue share | Category revenue / all-category delivered revenue | 20 |
| Rolling revenue | Current row + two previous **available** monthly rows | 21 |
| Cancellation rate | Cancelled orders / all orders × 100 | 22 |
| Return rate | Returned orders / all orders × 100 | 23 |
| Payments by status | Number of payment records and their recorded amount | 24 |
| Orders missing payment record | Orders with no matching `payments` row | 25 |

## Important caveats

1. **Orders vs. payments:** Payment status and amount must be examined separately from order delivery revenue; a row in `payments` does not automatically prove money was settled.
2. **No historical cost ledger:** Estimated gross profit is an analytical approximation, not accounting profit.
3. **Missing calendar months:** `LAG()` and the rolling `ROWS` frame skip absent months because the query operates on present month rows only.
4. **Returns:** Return rate counts orders marked `Returned` out of all orders. It is *not* an item-level refund-value metric.
5. **Customer segments:** Segments are illustrative fixed bands, not optimized or validated business segments.
6. **Data realism:** Synthetic values are useful for skill demonstration, but not suitable for claims about market opportunities or production performance.

## QA checks worth running

- Verify each table's seeded row count with `SELECT COUNT(*)`.
- Check that order revenue aggregation uses sold prices and the line discount.
- Check that a one-to-many join doesn't accidentally multiply order counts.
- Compare total delivered revenue with the sum of delivered revenue across product categories.
- Check missing orders/payments and investigate mismatches between recorded payment values and order totals only after defining settlement rules.

## Suggested next iterations

- Add a date dimension to handle missing months explicitly.
- Report refund amount and margin only when a sound refund/cost model is added.
- Add SQL execution output or a dashboard preview with reproducible query definitions.
- Introduce automated data tests and a small reproducible results table.

[← Back to project](../README.md)
