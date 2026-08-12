# Customer Churn Intelligence: End-to-End Business Analytics Solution for Customer Retention

## 1. Dataset

**Source:** IBM Telco Customer Churn (public sample dataset, originally published on Kaggle by IBM)
- Kaggle listing: https://www.kaggle.com/datasets/blastchar/telco-customer-churn
- File used here: `telco_churn_raw.csv` (7,043 customers, 21 columns)

This is a real telecom subscriber dataset covering demographics, account details (contract, tenure, billing), subscribed services, and a `Churn` flag — matching the "7,000+ customer records" scope on your resume.

## 2. Tools & Tech Stack

| Layer | Tool | What it did |
|---|---|---|
| Data cleaning & feature engineering | **Python** (pandas, numpy) | Fixed types, handled nulls, engineered features |
| Business-question analysis | **SQL** (SQLite) | 9 analyst queries answering specific business questions |
| KPI visuals | **Python** (matplotlib) | Static chart exports |
| Executive dashboard | **HTML/Chart.js** (Power BI–equivalent interactive dashboard) | Interactive KPI dashboard — same design logic you'd build in Power BI: KPI cards, bar/line visuals, cross-cutting insight callouts |

> Note on Power BI: I can't natively produce a `.pbix` file in this environment, so I built the equivalent interactive dashboard in HTML/Chart.js using the *same* KPIs, aggregations, and visual grammar (KPI cards, bar charts, drill dimensions) you'd build in Power BI. If you have Power BI Desktop, `telco_churn_clean.csv` drops straight into it — I've noted the exact visuals to recreate in Section 5.

## 3. Methodology (step by step)

1. **Ingest** — loaded raw CSV (7,043 rows × 21 cols).
2. **Clean** —
   - `TotalCharges` was stored as text with 11 blank values (all customers with `tenure = 0`, i.e., brand-new sign-ups not yet billed) → coerced to numeric, filled with 0 rather than dropped, since dropping would bias the "new customer" segment out of the analysis.
   - `SeniorCitizen` recoded from 0/1 to No/Yes for consistency with other flags.
3. **Feature engineering** —
   - `TenureBucket`: 0–1yr / 1–2yr / 2–4yr / 4+yr (lifecycle stage)
   - `NumAddonServices`: count of add-ons subscribed (Online Security, Backup, Device Protection, Tech Support, Streaming TV/Movies) — a proxy for product stickiness
   - `CLV_Proxy`: MonthlyCharges × tenure (rough lifetime value)
4. **SQL analysis** — loaded cleaned data into SQLite (`churn.db`) and ran 9 business-question queries (full file: `churn_analysis.sql`).
5. **KPI dashboard** — aggregated results into an interactive executive dashboard.
6. **Recommendations** — translated findings into retention actions (below).

## 4. Business Questions Answered

1. **What's the overall churn rate and revenue impact?** → 26.5% churn (1,869 of 7,043 customers), $139K/month lost, ~**$1.67M annualized**.
2. **Which contract type drives the most churn?** → Month-to-month: **42.7%** churn vs. 11.3% (1-year) and 2.8% (2-year).
3. **Does tenure predict churn?** → Yes, sharply: **47.4%** churn in year 1, dropping to 9.5% after 4+ years. Churn risk is front-loaded.
4. **Which internet service type churns most?** → Fiber optic customers churn at **41.9%** vs. 19.0% (DSL) and 7.4% (no internet) — despite fiber being the premium, highest-revenue product.
5. **Does payment method matter?** → Electronic check payers churn at **45.3%**, roughly 3x automatic payment methods (~15–17%). This signals friction/low commitment, not just a billing preference.
6. **Does service bundling reduce churn?** → Yes — churn drops from 45.8% (1 add-on) to **5.3%** (all 6 add-ons). Customers with zero add-ons are lower risk than those with just one, suggesting the "single add-on" group may be trial/low-commitment users.
7. **Which value tier has the most revenue at risk?** → High-spend customers ($70+/mo) are both the biggest segment (3,591 customers) and the highest-churn segment (35.5%), accounting for **81% of all lost monthly revenue** ($113K of $139K).
8. **Is churn demographic-linked?** → Senior citizens without partners/dependents churn highest (49.2%); customers with both a partner and dependents churn lowest (13.8%) — household stability correlates with retention.
9. **What's the highest-risk customer profile?** → Month-to-month + paperless billing + electronic check = **57.7% churn** — the single riskiest combination in the dataset, vs. 2.8% for the safest (two-year contract) segment.

## 5. Dashboard (delivered)

`churn_dashboard.html` — open directly in a browser. Contains:
- 5 KPI cards (churn rate, revenue lost monthly/annually, tenure comparison, highest-risk segment)
- Churn by Contract Type, Tenure Stage, Internet Service, Payment Method, Add-on count
- Revenue-at-risk by customer value tier
- An auto-generated insight callout

**To rebuild this in Power BI Desktop:** import `telco_churn_clean.csv` → create the same 6 visuals as bar/line charts sliced by `Contract`, `TenureBucket`, `InternetService`, `PaymentMethod`, `NumAddonServices` against a measure `Churn Rate = DIVIDE(SUM(ChurnFlag), COUNTROWS(customers))`.

## 6. Recommendations (what you'd say in an interview about this project)

1. **Target month-to-month + electronic check customers first** — this segment alone drives the majority of churn dollars. A targeted contract-upgrade incentive (discount for switching to annual) could meaningfully cut churn.
2. **Fix the first-year onboarding experience** — nearly half of year-1 customers churn. A structured 90-day onboarding/check-in program would address the biggest single risk window.
3. **Investigate fiber optic service quality** — premium customers churning at the highest rate is a red flag on product/service quality, not price sensitivity.
4. **Push service bundling proactively** — each additional add-on service correlates with materially lower churn; bundling isn't just upsell revenue, it's a retention lever.
5. **Prioritize retention spend on high-value tier** — since 81% of revenue at risk sits in the $70+/mo segment, retention offers should be value-weighted, not applied uniformly.

## Files delivered
- `telco_churn_raw.csv` — original dataset
- `telco_churn_clean.csv` — cleaned + feature-engineered dataset
- `01_clean_data.py` — Python cleaning/feature engineering script
- `churn_analysis.sql` — 9 SQL business-question queries
- `churn_dashboard.html` — interactive executive dashboard
