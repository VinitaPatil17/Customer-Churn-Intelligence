import pandas as pd
import numpy as np

df = pd.read_csv('/home/claude/churn_project/data/telco_churn.csv')

print("=== RAW SHAPE ===", df.shape)
print("\n=== DTYPES ===")
print(df.dtypes)

# TotalCharges is loaded as object -> has blank strings for new customers (tenure=0)
df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')
print("\n=== NULLS AFTER COERCE ===")
print(df.isnull().sum()[df.isnull().sum() > 0])
print("\nRows with null TotalCharges (tenure check):")
print(df[df['TotalCharges'].isnull()][['customerID','tenure','MonthlyCharges','TotalCharges']])

# These are brand-new customers (tenure=0) who haven't been billed yet -> fill with 0, not drop
df['TotalCharges'] = df['TotalCharges'].fillna(0)

# Standardize SeniorCitizen to Yes/No for consistency with other flags
df['SeniorCitizen'] = df['SeniorCitizen'].map({1: 'Yes', 0: 'No'})

# Feature engineering
df['ChurnFlag'] = df['Churn'].map({'Yes': 1, 'No': 0})

def tenure_bucket(t):
    if t <= 12: return '0-1 yr'
    elif t <= 24: return '1-2 yr'
    elif t <= 48: return '2-4 yr'
    else: return '4+ yr'
df['TenureBucket'] = df['tenure'].apply(tenure_bucket)

# Count of add-on services subscribed (proxy for engagement/stickiness)
addon_cols = ['OnlineSecurity','OnlineBackup','DeviceProtection','TechSupport','StreamingTV','StreamingMovies']
df['NumAddonServices'] = df[addon_cols].apply(lambda row: sum(row == 'Yes'), axis=1)

# Revenue at risk = TotalCharges lost if a churned customer leaves (for $ impact calc)
df['CLV_Proxy'] = df['MonthlyCharges'] * df['tenure']

df.to_csv('/home/claude/churn_project/data/telco_churn_clean.csv', index=False)
print("\n=== CLEAN SHAPE ===", df.shape)
print("\n=== CHURN RATE ===")
print(df['Churn'].value_counts(normalize=True) * 100)
print("\nSaved to telco_churn_clean.csv")
