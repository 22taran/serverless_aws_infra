# 💰 AWS Cost Analysis - Serverless TODO Application

## Executive Summary

This document provides a comprehensive cost analysis for the Serverless TODO Application deployed on AWS. The architecture is designed to be cost-effective, with estimated monthly costs ranging from **$0-5** (free tier) to **$50-100** (moderate traffic) depending on usage patterns.

---

## 📊 Cost Breakdown by Service

### 1. AWS Lambda

**Pricing Model**: Pay per request + compute time

#### Cost Components:
- **Requests**: $0.20 per 1 million requests
- **Compute**: $0.0000166667 per GB-second
- **Free Tier**: 1 million requests/month + 400,000 GB-seconds/month (permanent)

#### Example Calculations:

**Low Traffic (1,000 requests/day = 30,000/month)**:
- Requests: 30,000 × $0.20 / 1,000,000 = **$0.006**
- Compute: 30,000 requests × 0.5s × 256MB = 3,840 GB-seconds
  - Free tier covers this (400,000 GB-seconds available)
- **Total: $0.01/month** (covered by free tier)

**Moderate Traffic (100,000 requests/day = 3M/month)**:
- Requests: 3,000,000 × $0.20 / 1,000,000 = **$0.60**
- Compute: 3M × 0.5s × 256MB = 384,000 GB-seconds
  - Free tier: 400,000 GB-seconds covers this
- **Total: $0.60/month**

**High Traffic (1M requests/day = 30M/month)**:
- Requests: 30,000,000 × $0.20 / 1,000,000 = **$6.00**
- Compute: 30M × 0.5s × 256MB = 3,840,000 GB-seconds
  - Free tier: 400,000 GB-seconds
  - Billable: 3,440,000 GB-seconds × $0.0000166667 = **$57.33**
- **Total: $63.33/month**

---

### 2. Amazon API Gateway

**Pricing Model**: Pay per API call

#### Cost Components:
- **REST API**: $3.50 per million requests
- **Data Transfer Out**: $0.09 per GB (first 10 TB/month)
- **Free Tier**: 1 million requests/month (first 12 months)

#### Example Calculations:

**Low Traffic (30,000 requests/month)**:
- API Calls: 30,000 × $3.50 / 1,000,000 = **$0.11**
- Data Transfer: ~100MB = **$0.01**
- **Total: $0.12/month** (covered by free tier)

**Moderate Traffic (3M requests/month)**:
- API Calls: 3,000,000 × $3.50 / 1,000,000 = **$10.50**
- Data Transfer: ~10GB = **$0.90**
- **Total: $11.40/month**

**High Traffic (30M requests/month)**:
- API Calls: 30,000,000 × $3.50 / 1,000,000 = **$105.00**
- Data Transfer: ~100GB = **$9.00**
- **Total: $114.00/month**

---

### 3. Amazon DynamoDB

**Pricing Model**: On-Demand or Provisioned Capacity

#### Cost Components (On-Demand):
- **Read Request Units**: $0.25 per million
- **Write Request Units**: $1.25 per million
- **Storage**: $0.25 per GB/month
- **Free Tier**: 25 GB storage + 25 RCU + 25 WCU (permanent)

#### Cost Components (Provisioned with Autoscaling):
- **Read Capacity Units (RCU)**: $0.00013 per RCU/hour
- **Write Capacity Units (WCU)**: $0.00065 per WCU/hour
- **Storage**: $0.25 per GB/month

#### Example Calculations (On-Demand):

**Low Traffic (10,000 reads + 1,000 writes/day)**:
- Reads: 300,000/month × $0.25 / 1,000,000 = **$0.08**
- Writes: 30,000/month × $1.25 / 1,000,000 = **$0.04**
- Storage: 0.1 GB × $0.25 = **$0.03**
- **Total: $0.15/month** (mostly covered by free tier)

**Moderate Traffic (1M reads + 100K writes/day)**:
- Reads: 30M/month × $0.25 / 1,000,000 = **$7.50**
- Writes: 3M/month × $1.25 / 1,000,000 = **$3.75**
- Storage: 1 GB × $0.25 = **$0.25**
- **Total: $11.50/month**

**High Traffic (10M reads + 1M writes/day)**:
- Reads: 300M/month × $0.25 / 1,000,000 = **$75.00**
- Writes: 30M/month × $1.25 / 1,000,000 = **$37.50**
- Storage: 10 GB × $0.25 = **$2.50**
- **Total: $115.00/month**

#### Example Calculations (Provisioned with Autoscaling):

**Low Traffic (5 RCU, 5 WCU average)**:
- RCU: 5 × 730 hours × $0.00013 = **$0.47**
- WCU: 5 × 730 hours × $0.00065 = **$2.38**
- Storage: 0.1 GB × $0.25 = **$0.03**
- **Total: $2.88/month**

**Moderate Traffic (50 RCU, 50 WCU average)**:
- RCU: 50 × 730 hours × $0.00013 = **$4.75**
- WCU: 50 × 730 hours × $0.00065 = **$23.75**
- Storage: 1 GB × $0.25 = **$0.25**
- **Total: $28.75/month**

---

### 4. Amazon S3

**Pricing Model**: Storage + Requests + Data Transfer

#### Cost Components:
- **Standard Storage**: $0.023 per GB/month (first 50 TB)
- **PUT Requests**: $0.005 per 1,000 requests
- **GET Requests**: $0.0004 per 1,000 requests
- **Data Transfer Out**: $0.09 per GB (first 10 TB)
- **Free Tier**: 5 GB storage + 20,000 GET requests + 2,000 PUT requests (first 12 months)

#### Example Calculations:

**Low Traffic (1 GB storage, 1,000 uploads/month)**:
- Storage: 1 GB × $0.023 = **$0.02**
- PUT Requests: 1,000 × $0.005 / 1,000 = **$0.01**
- GET Requests: 10,000 × $0.0004 / 1,000 = **$0.00**
- Data Transfer: 5 GB × $0.09 = **$0.45**
- **Total: $0.48/month** (mostly covered by free tier)

**Moderate Traffic (5 GB storage, 10,000 uploads/month)**:
- Storage: 5 GB × $0.023 = **$0.12**
- PUT Requests: 10,000 × $0.005 / 1,000 = **$0.05**
- GET Requests: 100,000 × $0.0004 / 1,000 = **$0.04**
- Data Transfer: 50 GB × $0.09 = **$4.50**
- **Total: $4.71/month**

---

### 5. Amazon CloudFront

**Pricing Model**: Data Transfer + Requests

#### Cost Components:
- **Data Transfer Out**: $0.085 per GB (first 10 TB/month)
- **HTTPS Requests**: $0.0100 per 10,000 requests
- **Free Tier**: 1 TB data transfer + 10M HTTPS requests (first 12 months)

#### Example Calculations:

**Low Traffic (10 GB transfer, 100K requests/month)**:
- Data Transfer: 10 GB × $0.085 = **$0.85**
- Requests: 100,000 × $0.0100 / 10,000 = **$0.10**
- **Total: $0.95/month** (covered by free tier)

**Moderate Traffic (100 GB transfer, 1M requests/month)**:
- Data Transfer: 100 GB × $0.085 = **$8.50**
- Requests: 1,000,000 × $0.0100 / 10,000 = **$1.00**
- **Total: $9.50/month**

**High Traffic (1 TB transfer, 10M requests/month)**:
- Data Transfer: 1,000 GB × $0.085 = **$85.00**
- Requests: 10,000,000 × $0.0100 / 10,000 = **$10.00**
- **Total: $95.00/month**

---

### 6. AWS CodePipeline

**Pricing Model**: Per active pipeline per month

#### Cost Components:
- **Active Pipeline**: $1.00 per month (first pipeline free for first 12 months)
- **Additional Pipelines**: $1.00 per month each

#### Example Calculations:

**Single Pipeline**:
- **Total: $1.00/month** (free for first 12 months, then $1/month)

---

### 7. AWS CodeBuild

**Pricing Model**: Per build minute

#### Cost Components:
- **Build Time**: $0.005 per build minute (Linux, general1.small)
- **Free Tier**: 100 build minutes/month (first 12 months)

#### Example Calculations:

**Low Usage (10 builds/month, 5 minutes each = 50 minutes)**:
- Build Time: 50 minutes × $0.005 = **$0.25**
- **Total: $0.25/month** (covered by free tier)

**Moderate Usage (20 builds/month, 10 minutes each = 200 minutes)**:
- Free tier: 100 minutes
- Billable: 100 minutes × $0.005 = **$0.50**
- **Total: $0.50/month**

**High Usage (50 builds/month, 15 minutes each = 750 minutes)**:
- Free tier: 100 minutes
- Billable: 650 minutes × $0.005 = **$3.25**
- **Total: $3.25/month**

---

### 8. Amazon CloudWatch

**Pricing Model**: Logs + Metrics + Alarms

#### Cost Components:
- **Logs Ingestion**: $0.50 per GB
- **Logs Storage**: $0.03 per GB/month
- **Custom Metrics**: $0.30 per metric/month
- **Alarms**: $0.10 per alarm/month
- **Free Tier**: 5 GB logs ingestion + 10 custom metrics + 10 alarms (permanent)

#### Example Calculations:

**Low Traffic (1 GB logs/month, 5 metrics, 5 alarms)**:
- Logs Ingestion: 1 GB × $0.50 = **$0.50**
- Logs Storage: 1 GB × $0.03 = **$0.03**
- Metrics: Covered by free tier
- Alarms: Covered by free tier
- **Total: $0.53/month**

**Moderate Traffic (10 GB logs/month, 10 metrics, 10 alarms)**:
- Logs Ingestion: 10 GB × $0.50 = **$5.00**
- Logs Storage: 10 GB × $0.03 = **$0.30**
- Metrics: Covered by free tier
- Alarms: Covered by free tier
- **Total: $5.30/month**

---

## 📈 Total Cost Scenarios

### Scenario 1: Low Traffic (Personal/Small Project)
**Usage**: 1,000 API requests/day, minimal storage, occasional deployments

| Service | Monthly Cost |
|---------|--------------|
| Lambda | $0.01 (free tier) |
| API Gateway | $0.12 (free tier) |
| DynamoDB (On-Demand) | $0.15 (free tier) |
| S3 | $0.48 (free tier) |
| CloudFront | $0.95 (free tier) |
| CodePipeline | $0.00 (free tier) |
| CodeBuild | $0.25 (free tier) |
| CloudWatch | $0.53 |
| **TOTAL** | **~$1.50/month** |

**With AWS Free Tier (first 12 months)**: **~$0.50/month**

---

### Scenario 2: Moderate Traffic (Small Business/Startup)
**Usage**: 100,000 API requests/day, 1 GB storage, regular deployments

| Service | Monthly Cost |
|---------|--------------|
| Lambda | $0.60 |
| API Gateway | $11.40 |
| DynamoDB (On-Demand) | $11.50 |
| S3 | $4.71 |
| CloudFront | $9.50 |
| CodePipeline | $1.00 |
| CodeBuild | $0.50 |
| CloudWatch | $5.30 |
| **TOTAL** | **~$44.51/month** |

**With AWS Free Tier (first 12 months)**: **~$30/month**

---

### Scenario 3: High Traffic (Growing Business)
**Usage**: 1M API requests/day, 10 GB storage, frequent deployments

| Service | Monthly Cost |
|---------|--------------|
| Lambda | $63.33 |
| API Gateway | $114.00 |
| DynamoDB (On-Demand) | $115.00 |
| S3 | $47.10 |
| CloudFront | $95.00 |
| CodePipeline | $1.00 |
| CodeBuild | $3.25 |
| CloudWatch | $53.00 |
| **TOTAL** | **~$491.68/month** |

---

### Scenario 4: Enterprise Scale
**Usage**: 10M API requests/day, 100 GB storage, continuous deployments

| Service | Monthly Cost |
|---------|--------------|
| Lambda | $633.33 |
| API Gateway | $1,140.00 |
| DynamoDB (On-Demand) | $1,150.00 |
| S3 | $471.00 |
| CloudFront | $950.00 |
| CodePipeline | $1.00 |
| CodeBuild | $32.50 |
| CloudWatch | $530.00 |
| **TOTAL** | **~$4,908.83/month** |

---

## 💡 Cost Optimization Strategies

### 1. Use AWS Free Tier
- **Lambda**: 1M requests + 400K GB-seconds/month (permanent)
- **API Gateway**: 1M requests/month (first 12 months)
- **DynamoDB**: 25 GB storage + 25 RCU + 25 WCU (permanent)
- **S3**: 5 GB storage + 20K GET requests (first 12 months)
- **CloudFront**: 1 TB transfer + 10M requests (first 12 months)
- **CodeBuild**: 100 build minutes/month (first 12 months)

**Savings**: Up to $50-100/month in first year

### 2. DynamoDB Autoscaling
- Automatically scales down during low-traffic periods
- Reduces costs by 50-70% compared to fixed capacity
- **Savings**: $10-50/month depending on traffic patterns

### 3. CloudFront Caching
- Reduces origin requests by 80-90%
- Lowers S3 and API Gateway costs
- **Savings**: $5-20/month

### 4. Log Retention Policies
- Set CloudWatch log retention to 7 days (dev) or 30 days (prod)
- Reduces storage costs by 70-90%
- **Savings**: $2-10/month

### 5. S3 Lifecycle Policies
- Automatically delete old artifacts and logs
- Move infrequently accessed data to cheaper storage classes
- **Savings**: $1-5/month

### 6. Right-Size Lambda Memory
- Optimize Lambda memory allocation (test different sizes)
- Balance between cost and performance
- **Savings**: $5-15/month

### 7. Use Provisioned Capacity for Predictable Workloads
- If traffic is predictable, use DynamoDB provisioned capacity
- Can be 30-50% cheaper than on-demand for steady workloads
- **Savings**: $5-20/month

### 8. Monitor and Alert on Costs
- Set up AWS Cost Anomaly Detection
- Create CloudWatch alarms for unexpected cost spikes
- **Prevents**: Unexpected bills

---

## 📊 Cost Comparison: Serverless vs Traditional

### Traditional Architecture (EC2-based)

**Monthly Costs**:
- EC2 t3.small (24/7): $15.00
- Application Load Balancer: $16.20
- RDS db.t3.micro: $15.00
- S3 (1 GB): $0.02
- CloudWatch: $5.00
- **Total: ~$51.22/month**

### Serverless Architecture (Low Traffic)

**Monthly Costs**: **~$1.50/month**

**Savings**: **97% cost reduction** 🎉

### Serverless Architecture (Moderate Traffic)

**Monthly Costs**: **~$44.51/month**

**Savings**: **13% cost reduction**

### Serverless Architecture (High Traffic)

**Monthly Costs**: **~$491.68/month**

**Note**: At high traffic, serverless may be more expensive, but provides:
- Automatic scaling
- Zero server management
- Built-in high availability
- Pay-per-use model

---

## 🎯 Cost Estimation Calculator

Use this formula to estimate your costs:

```
Total Monthly Cost = 
  Lambda Cost (requests + compute) +
  API Gateway Cost (requests + data transfer) +
  DynamoDB Cost (reads + writes + storage) +
  S3 Cost (storage + requests + data transfer) +
  CloudFront Cost (data transfer + requests) +
  CodePipeline Cost ($1/pipeline) +
  CodeBuild Cost (build minutes) +
  CloudWatch Cost (logs + metrics + alarms)
```

### Quick Estimation Tool

**For your usage pattern, estimate**:
1. Daily API requests: _______
2. Average request size: _______
3. Storage needs (GB): _______
4. Monthly deployments: _______

**Then use the scenarios above as a reference.**

---

## ⚠️ Hidden Costs to Watch

1. **Data Transfer**: Can add up quickly, especially CloudFront egress
2. **DynamoDB On-Demand**: Can be expensive at high traffic (consider provisioned)
3. **CloudWatch Logs**: Large applications generate significant log volume
4. **Lambda Cold Starts**: May require provisioned concurrency (additional cost)
5. **API Gateway Cache**: Consider enabling caching to reduce Lambda invocations

---

## 📝 Cost Monitoring Best Practices

1. **Enable AWS Cost Explorer**: Track spending trends
2. **Set Budget Alerts**: Get notified when costs exceed thresholds
3. **Use Cost Allocation Tags**: Track costs by project/environment
4. **Review Monthly**: Analyze cost trends and optimize
5. **Use AWS Cost Anomaly Detection**: Automatic alerts for unusual spending

---

## 🆓 Free Tier Summary

### Always Free (Permanent):
- Lambda: 1M requests + 400K GB-seconds/month
- DynamoDB: 25 GB storage + 25 RCU + 25 WCU/month
- CloudWatch: 5 GB logs + 10 metrics + 10 alarms/month

### Free for 12 Months:
- API Gateway: 1M requests/month
- S3: 5 GB storage + 20K GET requests/month
- CloudFront: 1 TB transfer + 10M requests/month
- CodeBuild: 100 build minutes/month
- CodePipeline: 1 active pipeline/month

**Total Free Tier Value**: ~$50-100/month for first year

---

## 📞 Support and Resources

- **AWS Pricing Calculator**: https://calculator.aws/
- **AWS Cost Management**: https://aws.amazon.com/aws-cost-management/
- **AWS Free Tier**: https://aws.amazon.com/free/
- **AWS Support Plans**: Start with Basic (free), upgrade as needed

---

**Last Updated**: 2024  
**Note**: AWS pricing is subject to change. Always verify current pricing on AWS website.

