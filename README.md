# Customer Churn Prediction and Retention Insights

## Project Overview
This project analyses customer churn using Python, SQL, machine learning and Power BI to identify churn patterns and support customer retention decisions.

## Business Problem
The aim is to identify customers at high risk of churn, explore factors associated with customer attrition and provide potential retention recommendations.

## Tools Used
- Python (pandas, scikit-learn, matplotlib, seaborn)
- SQL (SQLite and MySQL)
- Power BI
- Jupyter Notebook

## Key Findings
- Customers with month-to-month contracts had the highest churn rate.
- Customers with higher monthly charges tended to have higher churn rates.
- Customers with shorter tenure showed higher churn risk.
- Customers using electronic check payments had higher churn rates than those using other payment methods.

## Machine Learning
Two classification models were developed to predict customer churn:

| Model | Accuracy | Precision | Recall | F1 score | ROC-AUC |
| Logistic Regression | 0.80 | 0.65 | 0.57 | 0.61 | 0.84 |
| Random Forest | 0.79 | 0.63 | 0.52 | 0.57 | 0.82 |

Logistic Regression achieved the better overall performance on the test dataset.

## Power BI Dashboard
![View Customer Churn Dashboard](powerbi/customer_churn_analysis_dashboard.png)
The updated Power BI dashboard presents customer churn KPIs and churn-rate comparisons across contract types, customer tenure and payment methods. It also summarises key findings and potential retention strategies.

The original exploratory dashboard is retained in the powerbi/archive/ folder for reference.

## Suggestions
- Prioritise retention efforts for customers with month-to-month contracts.
- Explore opportunities to encourage longer-term contracts.
- Strengthen early customer engagement and on-boarding.
- Investigate pricing and perceived value among customers with higher monthly charges.
- Examine factors associated with higher churn among electronic check users.
