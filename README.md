# Olist Sales Analysis (PostgreSQL + Excel)

Answering 10 business questions on about 100,000 real e-commerce orders: which product categories and states earn the most, how revenue changes by month, how late deliveries affect customer reviews, and how many customers come back.

## The problem

An online marketplace connects small sellers with customers across Brazil. The business wants to know:

- Where does the revenue come from, and how is it changing over time?
- Are customers receiving their orders on time, and does it affect how they rate the service?
- Do customers come back after their first order?

This project answers those questions with SQL (PostgreSQL) for the analysis, and Excel for pivot tables, charts and a cross-check of the numbers.

## The data

**Brazilian E-Commerce Public Dataset by Olist** (Kaggle): real orders placed between 2016 and 2018, split across several linked tables.

| Table | What it holds | Rows loaded |
| --- | --- | --- |
| `customers` | One row per customer ID, with city and state | 99,441 |
| `orders` | Order status and the purchase, delivery and estimated delivery dates | 99,441 |
| `order_items` | The products in each order, with price and freight | 112,650 |
| `payments` | How each order was paid | 103,886 |
| `reviews` | Review score and comment for each order | 99,224 |
| `products` | Product category and size | 32,951 |
| `sellers` | Seller city and state | 3,095 |
| `product_category_translation` | Portuguese to English category names | 71 |

The geolocation file (about a million rows) is not used, because none of the questions need it.

**Data source and licence:** the raw files are not stored in this repository. Download them from the dataset page on Kaggle, check its licence there, and credit Olist if you reuse the data.

## Tools

- **PostgreSQL**: loading, cleaning, joins, aggregations and window functions
- **Excel**: pivot tables, charts, and reconciliation with the SQL results
- **VS Code + SQLTools** for writing and running queries
- **Git and GitHub** for version control

## Business questions

| # | Question | SQL | Excel |
| --- | --- | --- | --- |
| 1 | How many delivered orders are there, and what is the total revenue? | [ ] | [ ] check |
| 2 | What are orders and revenue per month? | [ ] | [ ] chart |
| 3 | Which 10 product categories earn the most? | [ ] | [ ] chart |
| 4 | Which states earn the most, and how many orders does each have? | [ ] | [ ] pivot |
| 5 | What is the average order value, overall and by state? | [ ] | [ ] check |
| 6 | What share of payments is credit card, boleto, voucher and debit? | [ ] | |
| 7 | What is the average delivery time, and what percentage of orders arrive late? | [ ] | |
| 8 | How does the review score change when a delivery is late? | [ ] | |
| 9 | What share of customers order more than once? | [ ] | |
| 10 | Who are the top 10 sellers by revenue? | [ ] | |

Tick each box when the query is written, checked and committed.

## Repository structure

```
olist-sales-analysis-sql-excel/
  README.md
  .gitignore
  sql/
    01_create_tables.sql     create the olist schema, tables, and load the CSVs
    02_explore.sql           data quality checks
    03_questions.sql         the 10 business questions
  excel/
    olist-analysis.xlsx      pivots and charts built on the SQL results
  data/                      raw CSV files (not in the repo, see below)
```

## How to run it

1. Install PostgreSQL and make sure `psql` works from your terminal.
2. Download the dataset from Kaggle and put the CSV files in `data/raw/`.
3. Create a database:
   ```bash
   psql -U postgres -c "CREATE DATABASE olist_dataset;"
   ```
4. From the repository root, create the tables and load the data:
   ```bash
   psql -U postgres -d olist_dataset -f sql/01_create_tables.sql
   ```
   The script ends with a row count for every table. They should match the table above.
5. Run `sql/02_explore.sql` and `sql/03_questions.sql` in any SQL client.

## Data quality notes

Checks run before the analysis (to be completed as I go):

- Order statuses and what counts as a sale (delivered orders only for revenue)
- Orders with no delivery date
- Product categories with no English translation
- Text encoding of review comments (UTF-8)

## Key findings

> To be filled in after the analysis. Put three or four findings here, each with a real number and a recommended action. For example: "Orders delivered late scored X on average, against Y for on-time orders."

## Trade-offs and next steps

> To be filled in. Ideas to cover: what I assumed (for example, revenue = item price excluding freight), what the data cannot tell me, and what I would do with more time (a dashboard, a star schema, an automated pipeline).

## What I learned

> To be filled in.
