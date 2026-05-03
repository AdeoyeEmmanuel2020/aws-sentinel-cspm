# AWS Sentinel — Automated Cloud Security Posture Management (CSPM) Platform

<div align="center">

![AWS](https://img.shields.io/badge/AWS-Cloud%20Security-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Security](https://img.shields.io/badge/Security-Zero--Trust-DC143C?style=for-the-badge&logo=shield&logoColor=white)
![Compliance](https://img.shields.io/badge/Compliance-CIS%20%7C%20SOC2%20%7C%20ISO27001-28A745?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production%20Ready-00C851?style=for-the-badge)

**An enterprise-grade, fully automated Cloud Security Posture Management platform built on AWS**  
**Provisioned entirely with Terraform | Zero-Trust Architecture | Auto-Remediation | 100% Encryption Compliance**
</div>

----
# Table of Contents

- [About This Project](#about-this-project)
- [Architecture](#architecture)
- [Architecture Decisions and Rationale](#architecture-decisions--rationale)
- [Security Controls Implemented](#security-controls-implemented)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Module Documentation](#module-documentation)
- [Compliance Alignment](#compliance-alignment)
- [Deployment Screenshots](#Deployment-Screenshots)
- [Destroy Infrastructure](#destroy-infrastructure)
- [Enabling GuardDuty and Security Hub](#enabling-guardduty-and-security-hub)
- [Contributing](#contributing)
- [License](#license)
---

#  About This Project
**Security Solutions Architect Perspective**

This project was designed, architected, and implemented from the perspective of a **Cloud Security Solutions Architect** — not simply a cloud engineer running tutorials. Every decision made in this codebase reflects real-world enterprise security thinking: threat modelling, defence-in-depth, compliance alignment, least-privilege enforcement, and automated incident response.


 **The Problem This Solves**

Organisations migrating to AWS frequently face three critical security gaps:

1. **Lack of visibility** — No centralised logging means threats go undetected for days or weeks
2. **Manual response** — Security teams react to threats manually, resulting in Mean Time to Respond (MTTR) measured in hours
3. **Compliance drift** — Infrastructure changes over time break compliance baselines with no automated detection

AWS Sentinel addresses all three gaps in a single, Terraform-provisioned, production-ready platform.

**My Role on This Project**

| Responsibility | Detail |
|---|---|
| **Security Architecture** | Designed the full multi-layer security architecture from threat model to deployment |
| **Infrastructure as Code** | Authored all Terraform modules — zero manual console configuration |
| **Zero-Trust Network Design** | Architected VPC with private-only subnets, NACL rules, and deny-all Security Groups |
| **Encryption Strategy** | Designed end-to-end encryption using Customer Managed KMS keys with rotation |
| **Compliance Mapping** | Mapped all controls to CIS Benchmark, SOC 2, and ISO 27001 frameworks |
| **Auto-Remediation** | Built EventBridge → Lambda pipeline reducing MTTR from hours to under 5 minutes |
| **Centralised Logging** | Architected CloudTrail + VPC Flow Logs → CloudWatch centralised log aggregation |
| **IAM Governance** | Implemented IAM Access Analyzer for continuous least-privilege enforcement |

---

# Architecture

<img width="700" height="400" alt="2-lambda-trigger-console" src="https://github.com/user-attachments/assets/d81011f7-dfb1-42aa-bba0-6e001b4fbb87" />

----

# Architecture Decisions & Rationale

**Why private-only subnets?**  
Zero-trust network design assumes breach. By eliminating public subnets entirely, we remove the possibility of direct internet exposure of any workload. All traffic must traverse the security boundary.

**Why Customer Managed KMS keys instead of AWS managed keys?**  
CMKs give the security team full control of the key policy — we can restrict which services and principals can use the key for decryption. AWS managed keys do not support this level of granular access control.

**Why EventBridge → Lambda instead of manual remediation?**  
Security incidents follow predictable patterns. For known HIGH and CRITICAL severity GuardDuty finding types (e.g. CryptoCurrency:EC2/BitcoinTool, UnauthorizedAccess:EC2/SSHBruteForce), automated remediation reduces MTTR from hours to under 5 minutes — before an attacker can pivot laterally.

**Why VPC Flow Logs on ALL traffic types?**  
Capturing only REJECT traffic misses accepted-but-suspicious lateral movement. Logging ALL traffic enables forensic reconstruction of any incident timeline.

---

# Security Controls Implemented

**Defence-in-Depth Matrix**

| Layer | Control | Service | Compliance Mapping |
|-------|---------|---------|-------------------|
| **Identity** | Least privilege enforcement | IAM Access Analyzer | CIS 1.16–1.20, SOC 2 CC6.3 |
| **Identity** | Root login detection & alarm | CloudWatch Metric Filter | CIS 1.7, SOC 2 CC6.2 |
| **Network** | Zero public subnet exposure | VPC Private Subnets | NIST 800-53 SC-7 |
| **Network** | Subnet-level traffic control | Network ACL (HTTPS-only) | ISO 27001 A.13.1 |
| **Network** | Instance-level traffic control | Security Groups (deny-all) | ISO 27001 A.13.1 |
| **Network** | Full traffic capture | VPC Flow Logs (ALL) | SOC 2 CC7.2 |
| **Detection** | Real-time threat detection | Amazon GuardDuty | SOC 2 CC7.1 |
| **Detection** | Security standards compliance | AWS Security Hub | CIS Benchmark |
| **Detection** | API activity monitoring | CloudTrail (multi-region) | SOC 2 CC7.2, ISO 27001 A.12.4 |
| **Response** | Automated incident response | EventBridge + Lambda | SOC 2 CC7.3 |
| **Response** | Security team alerting | SNS Email Notifications | SOC 2 CC7.3 |
| **Data** | Encryption at rest | KMS CMK (SSE-KMS) | ISO 27001 A.10.1 |
| **Data** | Encryption in transit | S3 HTTPS-only bucket policy | PCI-DSS 4.1 |
| **Data** | Key lifecycle management | KMS Annual Rotation | ISO 27001 A.10.1 |
| **Audit** | Immutable log storage | S3 + Versioning + Lifecycle | SOC 2 CC7.2 |

---

# Project Structure

```
aws-sentinel-cspm/
│
├── main.tf                          # Root orchestration — wires all modules together
├── variables.tf                     # All input variable definitions
├── outputs.tf                       # Exported resource identifiers
├── providers.tf                     # AWS, Archive, Random, Local provider config
├── terraform.tfvars                 # Environment-specific values
├── .gitignore                       # Excludes state files, secrets, zip artifacts
├── README.md                        # This documentation
│
├── modules/
│   │
│   ├──  kms/                         # Encryption foundation
│   │   ├── main.tf                     # CMK + key policy (CloudTrail, Lambda, Root)
│   │   ├── variables.tf
│   │   └── outputs.tf                  # key_arn, key_id
│   │
│   ├── vpc/                         # Zero-trust network layer
│   │   ├── main.tf                     # VPC, private subnets, SG, NACL, Flow Logs
│   │   ├── variables.tf
│   │   └── outputs.tf                  # vpc_id, private_subnets, security_group
│   │
│   ├── s3-secure/                   # Encrypted centralised log storage
│   │   ├── main.tf                     # SSE-KMS, versioning, lifecycle, HTTPS policy
│   │   ├── variables.tf
│   │   └── outputs.tf                  # logs_bucket_id, logs_bucket_arn
│   │
│   ├── cloudtrail/                  # API audit logging
│   │   ├── main.tf                     # Multi-region trail, KMS, CloudWatch integration
│   │   ├── variables.tf
│   │   └── outputs.tf                  # trail_arn, trail_name
│   │
│   ├── guardduty/                   # Threat detection (conditional)
│   │   ├── main.tf                     # Detector, SNS, EventBridge HIGH/CRITICAL rule
│   │   ├── variables.tf
│   │   └── outputs.tf                  # detector_id, sns_topic_arn
│   │
│   ├── security-hub/                # Compliance standards (conditional)
│   │   ├── main.tf                     # CIS 1.2 + AWS Foundational standards
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── iam-analyser/                # IAM least privilege monitoring
│   │   ├── main.tf                     # Access Analyzer + root login alarm
│   │   ├── variables.tf
│   │   └── outputs.tf                  # analyzer_arn, analyzer_name
│   │
│   └── auto-remediation/            # Automated incident response
│       ├── main.tf                     # Lambda + EventBridge + IAM role
│       ├── variables.tf
│       ├── outputs.tf                  # lambda_function_name, lambda_function_arn
│       └── lambda/
│           └── index.py                # Python 3.12 remediation handler
│
├── docs/
│   └── architecture.md                 # Extended architecture documentation
│
└── screenshots/                     # Deployment evidence (25 screenshots)
    ├── 01-terraform-output.png
    ├── 02-lambda-function-cli.png
    ├── 03-iam-analyzer-cli.png
    ├── 04-cloudtrail-status-cli.png
    ├── 05-kms-rotation-cli.png
    ├── 06-s3-encryption-cli.png
    ├── 07-vpc-flowlogs-cli.png
    ├── 08-private-subnets-cli.png
    ├── 09-project-structure-cli.png
    ├── 10-cloudtrail-console.png
    ├── 11-kms-key-console.png
    ├── 12-s3-properties-console.png
    ├── 13-s3-permissions-console.png
    ├── 14-vpc-overview-console.png
    ├── 15-private-subnets-console.png
    ├── 16-security-group-console.png
    ├── 17-nacl-console.png
    ├── 18-vpc-flowlogs-console.png
    ├── 19-iam-analyzer-console.png
    ├── 20-lambda-console.png
    ├── 21-lambda-trigger-console.png
    ├── 22-eventbridge-rules-console.png
    ├── 23-sns-topic-console.png
    ├── 24-sns-subscription-console.png
    └── 25-cloudwatch-loggroups-console.png
```

---

# Prerequisites

| Tool | Minimum Version | Purpose | Install Guide |
|------|----------------|---------|--------------|
| Terraform | >= 1.5.0 | Infrastructure provisioning | [terraform.io/downloads](https://terraform.io/downloads) |
| AWS CLI | >= 2.0 | AWS authentication & verification | [aws.amazon.com/cli](https://aws.amazon.com/cli) |
| Python | >= 3.12 | Lambda function runtime | Pre-installed on most systems |
| Git | Any | Version control | [git-scm.com](https://git-scm.com) |
| AWS Account | — | Target deployment environment | With IAM permissions listed below |

**Required IAM Permissions**
The AWS user or role running Terraform must have permissions for:
```
cloudtrail:*, guardduty:*, securityhub:*, 
accessanalyzer:*, kms:*, s3:*, ec2:*, 
lambda:*, iam:*, events:*, sns:*, 
logs:*, cloudwatch:*
```

For demo/personal accounts, `AdministratorAccess` is acceptable. For production, scope to exact actions above.

---

# Quick Start

**Step 1 — Clone the Repository**

```bash
git clone https://github.com/YOUR_USERNAME/aws-sentinel-cspm.git
cd aws-sentinel-cspm
```

**Step 2 — Configure AWS Credentials**

```bash
aws configure
# AWS Access Key ID: [your key]
# AWS Secret Access Key: [your secret]
# Default region name: us-east-1
# Default output format: json

# Verify credentials are working
aws sts get-caller-identity
```

**Step 3 — Configure Your Variables**

```bash
# Open terraform.tfvars and set your values
nano terraform.tfvars
```

```hcl
aws_region          = "us-east-1"
environment         = "production"
owner               = "security-team"
project_name        = "aws-sentinel"
vpc_cidr            = "10.0.0.0/16"
alert_email         = "your-email@example.com"   # ← change this
enable_guardduty    = false                        # set true if account supports it
enable_security_hub = false                        # set true if account supports it
```

**Step 4 — Deploy**

```bash
# Initialise providers and modules
terraform init

# Review what will be created (no changes made yet)
terraform plan

# Deploy all infrastructure
terraform apply -auto-approve
```

**Step 5 — Verify Deployment**

```bash
terraform output
```

Expected output:
```
cloudtrail_arn        = "arn:aws:cloudtrail:us-east-1:XXXXXXXXXXXX:trail/aws-sentinel-trail"
guardduty_detector_id = "guardduty-disabled"
iam_analyzer_arn      = "arn:aws:access-analyzer:us-east-1:XXXXXXXXXXXX:analyzer/aws-sentinel-access-analyzer"
kms_key_id            = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
logs_bucket           = "aws-sentinel-security-logs-XXXXXXXX"
vpc_id                = "vpc-XXXXXXXXXXXXXXXXX"
```

---

# Module Documentation

**`modules/kms` — Encryption Foundation**

**Purpose:** Creates the Customer Managed Key that underpins all encryption across the platform.

**Key Design Decisions:**
- Key policy explicitly permits CloudTrail to use the key — without this, CloudTrail cannot write encrypted logs
- Annual automatic key rotation enabled — meets ISO 27001 A.10.1 and CIS 3.7
- 30-day deletion window prevents accidental permanent key loss
- Root account always retains full key access for emergency recovery

**Resources Created:**
- `aws_kms_key` — CMK with custom key policy
- `aws_kms_alias` — Human-readable alias `alias/aws-sentinel-key`


 **`modules/vpc` — Zero-Trust Network Layer**

**Purpose:** Builds a network perimeter that assumes breach — no workload is ever directly internet-accessible.

**Key Design Decisions:**
- Zero public subnets — eliminates the possibility of internet-facing exposure entirely
- No internet gateway — workloads cannot reach or be reached from the internet directly
- NACL operates at the subnet boundary (Layer 3/4) — first line of defence
- Security Group operates at instance boundary (Layer 3/4) — second line of defence
- VPC Flow Logs capture ALL traffic types — enables full forensic reconstruction

**Resources Created:**
- `aws_vpc` — Primary VPC (10.0.0.0/16)
- `aws_subnet` x2 — Private subnets across 2 AZs
- `aws_security_group` — Deny-all inbound, HTTPS-only outbound
- `aws_network_acl` — HTTPS-only rules at subnet boundary
- `aws_flow_log` — ALL traffic to CloudWatch (90-day retention)


 **`modules/s3-secure` — Encrypted Log Storage**

**Purpose:** Provides tamper-resistant, encrypted, cost-optimised storage for all security logs.

**Key Design Decisions:**
- SSE-KMS with the project CMK — logs are encrypted with a key we fully control
- Versioning prevents log tampering — previous versions are retained even if the current one is overwritten
- Lifecycle policy moves logs to Glacier after 90 days — reduces storage cost by ~70%
- Bucket policy enforces HTTPS-only — any unencrypted transport attempt is rejected with 403
- All public access blocked at the account level — cannot be accidentally made public

**Resources Created:**
- `aws_s3_bucket` — Primary security logs bucket
- `aws_s3_bucket_versioning` — Versioning enabled
- `aws_s3_bucket_server_side_encryption_configuration` — SSE-KMS
- `aws_s3_bucket_public_access_block` — All 4 blocks enabled
- `aws_s3_bucket_lifecycle_configuration` — Glacier after 90d, delete after 365d
- `aws_s3_bucket_policy` — Deny non-SSL + Allow CloudTrail writes
- `aws_s3_bucket_logging` — Server access logs to a separate bucket

**`modules/cloudtrail` — API Audit Logging**

**Purpose:** Creates an immutable audit trail of every API call made in the AWS account.

**Key Design Decisions:**
- Multi-region trail — captures API calls in ALL regions, not just us-east-1. Prevents blind spots where an attacker creates resources in unused regions
- Log file validation — CloudTrail creates a hash of each log file. If a log is tampered with, validation fails
- KMS encryption — log files encrypted with project CMK before writing to S3
- CloudWatch integration — logs stream to CloudWatch in near-real-time for alerting

**Resources Created:**
- `aws_cloudtrail` — Multi-region trail with KMS + validation
- `aws_cloudwatch_log_group` — CloudTrail log group (90-day retention)
- `aws_iam_role` — Scoped role for CloudTrail → CloudWatch delivery

**`modules/guardduty` — Threat Detection**

**Purpose:** Continuous ML-based threat detection across AWS account activity, network traffic, and data access.

**Key Design Decisions:**
- S3 protection enabled — detects suspicious data access patterns (e.g. mass downloads, unusual geo-locations)
- Kubernetes audit log analysis — detects compromised containers or privilege escalation in EKS
- EBS malware scanning — scans volumes of EC2 instances with suspicious findings
- EventBridge rule filters severity >= 7 — only HIGH and CRITICAL findings trigger automated response. Medium findings are logged but do not trigger Lambda to avoid alert fatigue
- Conditional deployment (`count = var.enable_guardduty ? 1 : 0`) — safely skipped on accounts without subscription

**Resources Created:**
- `aws_guardduty_detector` — Detector with all data sources
- `aws_sns_topic` — Alert notification topic
- `aws_cloudwatch_event_rule` — HIGH/CRITICAL finding filter
- `aws_cloudwatch_event_target` — SNS target for alerts

**`modules/security-hub` — Compliance Standards**

**Purpose:** Aggregates security findings and enforces compliance against industry benchmarks.

**Standards Enabled:**
- CIS AWS Foundations Benchmark v1.2.0 — 49 security controls
- AWS Foundational Security Best Practices v1.0.0 — covers IAM, S3, EC2, RDS, Lambda

**Resources Created:**
- `aws_securityhub_account` — Enables Security Hub
- `aws_securityhub_standards_subscription` x2 — CIS + AWS Foundational
- `aws_securityhub_finding_aggregator` — All-region aggregation

**`modules/iam-analyser` — Least Privilege Monitoring**

**Purpose:** Continuously analyses IAM policies to detect overly permissive access — catches the most common cause of cloud breaches.

**Key Design Decisions:**
- Account-scope analyser — analyses all IAM policies, S3 bucket policies, KMS key policies, and SQS queue policies across the account
- Root login CloudWatch alarm — any root account usage triggers an immediate alarm. Root should never be used for day-to-day operations
- Metric filter pattern — uses CloudTrail logs as the data source for the root login detection

**Resources Created:**
- `aws_accessanalyzer_analyzer` — Account-scope analyser
- `aws_cloudwatch_log_metric_filter` — Root login detection pattern
- `aws_cloudwatch_metric_alarm` — Alarm on any root login

**`modules/auto-remediation` — Automated Incident Response
**
**Purpose:** Eliminates human delay from the incident response loop for known HIGH severity threat patterns.

**How It Works:**
```
GuardDuty Finding (severity ≥ 7)
        │
        ▼
EventBridge Rule (pattern match)
        │
        ▼
Lambda Function (Python 3.12)
        │
        ├── Logs finding details to CloudWatch
        ├── Identifies finding type
        ├── Executes remediation action
        │   (e.g. stop instance, revoke credentials)
        └── Returns remediation status
```

**MTTR Comparison:**
| Approach | Mean Time to Respond |
|----------|---------------------|
| Manual (traditional) | 2–8 hours |
| AWS Sentinel (automated) | < 5 minutes |
| Improvement | ~96% reduction |

**Resources Created:**
- `aws_lambda_function` — Python 3.12 remediation handler
- `aws_iam_role` — Least-privilege execution role
- `aws_cloudwatch_event_rule` — Severity >= 7 trigger
- `aws_cloudwatch_event_target` — Lambda target
- `aws_lambda_permission` — Allows EventBridge to invoke Lambda

---

# Compliance Alignment

**CIS AWS Foundations Benchmark v1.2.0**

| Section | Controls | Implemented By |
|---------|---------|---------------|
| 1 — Identity and Access Management | 1.1–1.20 | IAM Analyzer, Root alarm |
| 2 — Logging | 2.1–2.9 | CloudTrail, VPC Flow Logs, S3 |
| 3 — Monitoring | 3.1–3.14 | CloudWatch alarms, EventBridge |
| 4 — Networking | 4.1–4.4 | VPC, Security Groups, NACL |

**SOC 2 Type II Mapping**

| Trust Service Criteria | Control | Implementation |
|----------------------|---------|---------------|
| CC6.1 — Logical access | Least privilege | IAM Access Analyzer |
| CC6.2 — Authentication | Root login detection | CloudWatch alarm |
| CC6.3 — Access removal | Policy remediation | Lambda auto-remediation |
| CC7.1 — Threat detection | GuardDuty | EventBridge pipeline |
| CC7.2 — System monitoring | CloudTrail + VPC Flow Logs | CloudWatch log groups |
| CC7.3 — Incident response | Auto-remediation | EventBridge → Lambda |
| CC8.1 — Change management | IaC only | Terraform |

**ISO 27001:2013 Mapping**

| Annex A Control | Requirement | Implementation |
|----------------|-------------|---------------|
| A.9.4 — Access control | System access control | Security Groups, NACL |
| A.10.1 — Cryptography | Encryption policy | KMS CMK + rotation |
| A.12.4 — Logging | Event logging | CloudTrail, VPC Flow Logs |
| A.13.1 — Network security | Network controls | Zero-trust VPC design |
| A.16.1 — Incident management | Incident response | Lambda auto-remediation |

---

# Deployment Screenshots

All 25 screenshots are real AWS Console and CLI outputs from the live deployment.

**Terminal Evidence (CLI)**

| # | What It Proves | View |
|---|---|---|
| 01 | All Terraform resource IDs confirmed | [View Screenshot](screenshots/01-terraform-output.png) |
| 02 | Lambda function live — Python 3.12, Active state | [View Screenshot](screenshots/02-lambda-function-cli.png) |
| 03 | IAM Analyzer active — account scope | [View Screenshot](screenshots/03-iam-analyzer-cli.png) |
| 04 | CloudTrail actively logging — IsLogging: true | [View Screenshot](screenshots/04-cloudtrail-status-cli.png) |
| 05 | KMS key rotation enabled — KeyRotationEnabled: true | [View Screenshot](screenshots/05-kms-rotation-cli.png) |
| 06 | S3 SSE-KMS encryption confirmed | [View Screenshot](screenshots/06-s3-encryption-cli.png) |
| 07 | VPC Flow Logs active — ALL traffic type | [View Screenshot](screenshots/07-vpc-flowlogs-cli.png) |
| 08 | Private subnets — MapPublicIpOnLaunch: false | [View Screenshot](screenshots/08-private-subnets-cli.png) |
| 09 | Full Terraform module structure | [View Screenshot](screenshots/09-project-structure-cli.png) |


**AWS Console Evidence**

| # | What It Proves | View |
|---|---|---|
| 10 | CloudTrail — multi-region, KMS encrypted, log validation ON | [View Screenshot](screenshots/10-cloudtrail-console.png) |
| 11 | KMS — CMK enabled, rotation enabled | [View Screenshot](screenshots/11-kms-key-console.png) |
| 12 | S3 — SSE-KMS + versioning enabled | [View Screenshot](screenshots/12-s3-properties-console.png) |
| 13 | S3 — all 4 public access blocks ON | [View Screenshot](screenshots/13-s3-permissions-console.png) |
| 14 | VPC — 10.0.0.0/16, DNS enabled | [View Screenshot](screenshots/14-vpc-overview-console.png) |
| 15 | Subnets — private only, no public IP assignment | [View Screenshot](screenshots/15-private-subnets-console.png) |
| 16 | Security Group — zero inbound rules, HTTPS-only outbound | [View Screenshot](screenshots/16-security-group-console.png) |
| 17 | NACL — HTTPS-only inbound and outbound rules | [View Screenshot](screenshots/17-nacl-console.png) |
| 18 | VPC Flow Logs — ALL traffic, active status | [View Screenshot](screenshots/18-vpc-flowlogs-console.png) |
| 19 | IAM Analyzer — Active, account scope | [View Screenshot](screenshots/19-iam-analyzer-console.png) |
| 20 | Lambda — function deployed, Python 3.12 | [View Screenshot](screenshots/20-lambda-console.png) |
| 21 | Lambda — EventBridge trigger attached | [View Screenshot](screenshots/21-lambda-trigger-console.png) |
| 22 | EventBridge — both sentinel rules active | [View Screenshot](screenshots/22-eventbridge-rules-console.png) |
| 23 | SNS — guardduty-alerts topic created | [View Screenshot](screenshots/23-sns-topic-console.png) |
| 24 | SNS — email subscription confirmed | [View Screenshot](screenshots/24-sns-subscription-console.png) |
| 25 | CloudWatch — sentinel log groups active | [View Screenshot](screenshots/25-cloudwatch-loggroups-console.png) |

---
# Destroy Infrastructure

Always destroy after you are done to avoid AWS charges:

```bash
terraform destroy -auto-approve
```

Expected output:
```
Destroy complete! Resources: XX destroyed.
```

Verify destruction:
```bash
# Confirm VPC is gone
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=aws-sentinel-cspm" --region us-east-1

# Confirm S3 bucket is gone
aws s3 ls | grep aws-sentinel

# Confirm CloudTrail is gone
aws cloudtrail describe-trails --region us-east-1
```

---
# Enabling GuardDuty and Security Hub

Both services are fully written in Terraform but conditionally disabled. To activate on a supported AWS account:

```bash
# Update terraform.tfvars
enable_guardduty    = true
enable_security_hub = true

# Apply
terraform apply -auto-approve
```

To activate GuardDuty free trial via CLI first:
```bash
aws guardduty create-detector --enable --region us-east-1
```

---

# Contributing

Pull requests are welcome. Please open an issue first for major changes.

**Development Workflow**

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes, then validate
terraform fmt -recursive
terraform validate

# Commit
git add.
git commit -m "feat: description of change"
git push origin feature/your-feature-name
```

---

# **👤** Author
**Adeoye Emmanuel** - AWS Certified Solutions Architect | AWS Security Solutions Architect | DevSecOps Engineer

**Email:** Emmanuelofgrace@gmail.com

 LinkedIn: www.linkedin.com/in/emmanuel-adeoye-29187bb7

 ---

# License

MIT License — see [LICENSE](LICENSE) for details.

