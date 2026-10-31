# Olist Sales Analysis (PostgreSQL + Excel)

Analysis of about 100,000 real e-commerce orders to answer 10 business questions on revenue, product categories, regions, payments, delivery performance and customer retention.

## Data

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle): orders placed between 2016 and 2018 across eight linked tables (customers, orders, order items, payments, reviews, products, sellers, category translations). Raw files are not stored in this repository; check the dataset licence on Kaggle before reuse.

## Tools

PostgreSQL, VS Code (SQLTools), Excel, Git

## Key findings

| # | Question | Answer |
| --- | --- | --- |
| 1 | Delivered orders and total revenue | 96,478 orders, 13,221,498.11 revenue |
| 2 | Orders and revenue per month | Peak in Nov 2017 (7,289 orders); 6,000 to 7,000 a month through 2018 |
| 3 | Top 10 categories by revenue | `health_beauty` first; top 10 make about 62% of revenue |
| 4 | Top states by revenue | SP first (40,501 orders, 5,067,633.16), then RJ and MG |
| 5 | Average order value | 137.04 overall; SP lowest (125.12) |
| 6 | Payment type share | Credit card 78.46% of money, boleto 17.96% |
| 7 | Delivery time and lateness | 12.6 days on average; 8.11% late |
| 8 | Review score and late delivery | 2.57 when late, 4.29 when on time |
| 9 | Repeat customers | 3.00% order more than once |
| 10 | Top 10 sellers | Together 13.27% of revenue |

**Takeaways**

- Revenue is concentrated in a few categories and states (SP has about 42% of orders), but not in a few sellers.
- Late deliveries are associated with review scores 1.7 points lower. Cutting late deliveries is the clearest lever on customer satisfaction.
- Retention is low: 97% of customers ordered only once.

Queries and answers: [`sql/03_questions.sql`](sql/03_questions.sql)

## Method and data quality

- **Revenue** is the sum of item prices for delivered orders, excluding freight. **Average order value** is revenue divided by distinct orders.
- 2016 has almost no orders and delivered orders end in Aug 2018, so trends use Jan 2017 to Aug 2018.
- 8 orders marked delivered have no delivery date and are excluded from delivery and review questions.
- Two categories have no English translation; a `LEFT JOIN` with `COALESCE` keeps their revenue.
- Orders can contain several items, so order counts use `COUNT(DISTINCT order_id)`.

## Limitations

- No cost data, so the analysis covers revenue, not profit.
- Review results show an association, not proof of cause.
- Retention covers about two years and one marketplace.

## Repository structure

```
sql/
  01_create_tables.sql   schema, tables and data load
  02_explore.sql         data quality checks
  03_questions.sql       the 10 business questions
excel/                   charts built on the SQL results (in progress)
data/                    raw CSV files (not in the repo)
```

## How to run

1. Install PostgreSQL and download the dataset into `data/raw/`.
2. Create the database: `psql -U postgres -c "CREATE DATABASE olist_dataset;"`
3. From the repository root: `psql -U postgres -d olist_dataset -f sql/01_create_tables.sql`
4. Run `sql/02_explore.sql` and `sql/03_questions.sql` in any SQL client.