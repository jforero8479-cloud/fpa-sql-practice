-- ============================================
-- FP&A SQL Queries — Johana Forero
-- Use cases: OpEx tracking, variance analysis
-- ============================================

-- 1. Monthly variance: actual vs budget by cost category
SELECT
    cost_category,
    period_month,
    SUM(actual_amount)              AS actual,
    SUM(budget_amount)              AS budget,
    SUM(actual_amount - budget_amount) AS variance,
    ROUND(SUM(actual_amount - budget_amount) 
          / NULLIF(SUM(budget_amount), 0) * 100, 2) AS variance_pct
FROM expenses
GROUP BY cost_category, period_month
ORDER BY period_month, variance DESC;

-- 2. Top 10 vendors by spend — quarter over quarter
SELECT
    vendor_name,
    fiscal_quarter,
    SUM(amount) AS total_spend
FROM vendor_invoices
GROUP BY vendor_name, fiscal_quarter
ORDER BY fiscal_quarter, total_spend DESC
LIMIT 10;

-- 3. AR aging report — outstanding balances by bucket
SELECT
    client_name,
    SUM(CASE WHEN days_outstanding <= 30  THEN amount ELSE 0 END) AS current_0_30,
    SUM(CASE WHEN days_outstanding <= 60
             AND days_outstanding > 30    THEN amount ELSE 0 END) AS days_31_60,
    SUM(CASE WHEN days_outstanding <= 90
             AND days_outstanding > 60    THEN amount ELSE 0 END) AS days_61_90,
    SUM(CASE WHEN days_outstanding > 90   THEN amount ELSE 0 END) AS over_90,
    SUM(amount)                                                    AS total_outstanding
FROM accounts_receivable
GROUP BY client_name
ORDER BY total_outstanding DESC;

-- 4. Month-end close: accrual validation
SELECT
    department,
    cost_category,
    SUM(accrual_amount) AS total_accruals,
    COUNT(*)            AS accrual_count
FROM accruals
WHERE period = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY department, cost_category
ORDER BY total_accruals DESC;

-- 5. Period-over-period OpEx comparison
SELECT
    cost_category,
    SUM(CASE WHEN period = '2026-03' THEN amount ELSE 0 END) AS mar_2026,
    SUM(CASE WHEN period = '2026-02' THEN amount ELSE 0 END) AS feb_2026,
    SUM(CASE WHEN period = '2026-03' THEN amount ELSE 0 END)
    - SUM(CASE WHEN period = '2026-02' THEN amount ELSE 0 END) AS mom_change
FROM opex_transactions
GROUP BY cost_category
ORDER BY mom_change DESC;
