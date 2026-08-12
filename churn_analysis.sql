-- ============================================================
-- CUSTOMER CHURN INTELLIGENCE — SQL ANALYSIS
-- ============================================================

-- Q1: What is the overall churn rate and revenue at risk?
SELECT
    COUNT(*) AS total_customers,
    SUM(ChurnFlag) AS churned_customers,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END), 2) AS monthly_revenue_lost,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END) * 12, 2) AS annualized_revenue_lost
FROM customers;

-- Q2: Which contract type drives the most churn?
SELECT
    Contract,
    COUNT(*) AS customers,
    SUM(ChurnFlag) AS churned,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- Q3: Does tenure (customer lifecycle stage) predict churn?
SELECT
    TenureBucket,
    COUNT(*) AS customers,
    SUM(ChurnFlag) AS churned,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY TenureBucket
ORDER BY
    CASE TenureBucket
        WHEN '0-1 yr' THEN 1 WHEN '1-2 yr' THEN 2
        WHEN '2-4 yr' THEN 3 ELSE 4 END;

-- Q4: Which internet service type has the highest churn?
SELECT
    InternetService,
    COUNT(*) AS customers,
    SUM(ChurnFlag) AS churned,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge
FROM customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

-- Q5: Does payment method correlate with churn (billing friction)?
SELECT
    PaymentMethod,
    COUNT(*) AS customers,
    SUM(ChurnFlag) AS churned,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- Q6: Does bundling add-on services (stickiness) reduce churn?
SELECT
    NumAddonServices,
    COUNT(*) AS customers,
    SUM(ChurnFlag) AS churned,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY NumAddonServices
ORDER BY NumAddonServices;

-- Q7: High-value customers at risk (top revenue segment with elevated churn)
SELECT
    CASE
        WHEN MonthlyCharges < 35 THEN 'Low ($0-35)'
        WHEN MonthlyCharges < 70 THEN 'Mid ($35-70)'
        ELSE 'High ($70+)'
    END AS charge_tier,
    COUNT(*) AS customers,
    SUM(ChurnFlag) AS churned,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END), 2) AS monthly_revenue_lost
FROM customers
GROUP BY charge_tier
ORDER BY churn_rate_pct DESC;

-- Q8: Senior citizens vs. rest — is churn demographic-linked?
SELECT
    SeniorCitizen,
    Dependents,
    Partner,
    COUNT(*) AS customers,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY SeniorCitizen, Dependents, Partner
ORDER BY churn_rate_pct DESC
LIMIT 10;

-- Q9: Paperless billing + month-to-month + electronic check = the classic high-risk combo?
SELECT
    Contract, PaperlessBilling, PaymentMethod,
    COUNT(*) AS customers,
    ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
WHERE Contract = 'Month-to-month'
GROUP BY Contract, PaperlessBilling, PaymentMethod
ORDER BY churn_rate_pct DESC
LIMIT 10;
