# Threat model

## Scope and security objective

AWS Sentinel protects the AWS account and the resources instantiated by this
repository. Its objective is to reduce the time between a detectable control-plane
or workload signal and a reviewed containment decision while preserving evidence.
It is not a complete CSPM product: it does not inventory every AWS service, prove
regulatory compliance, or replace an incident-response process.

## Trust boundaries and assets

| Boundary | Assets | Principal threats |
|---|---|---|
| AWS account | IAM identities, KMS key, audit configuration | credential theft, privilege escalation, logging disabled |
| VPC | private subnets, security groups, flow logs | exposed workload, lateral movement, covert egress |
| Evidence plane | CloudTrail and flow-log groups, S3 log bucket | deletion, modification, loss of availability |
| Response plane | EventBridge, Lambda role and code | forged event, excessive privilege, unsafe containment |
| Operator boundary | Terraform credentials, state and CI | secret disclosure, malicious change, configuration drift |

## Threat analysis

| ID | Threat | Existing control | Residual risk / required work |
|---|---|---|---|
| T1 | Stolen IAM credentials perform API actions | Multi-region CloudTrail, root-use metric | Detection is not prevention; add identity-specific detections and tested notification routing. |
| T2 | Public or unintended S3 access | Account-level bucket block and TLS-deny policy | Organisational SCPs and continuous policy analysis are outside this repository. |
| T3 | Audit evidence is altered or removed | KMS encryption, versioning, log-file validation | Same-account administrators can still affect evidence; use a dedicated log-archive account and Object Lock for stronger immutability. |
| T4 | Compromised EC2 instance communicates externally | Default-deny ingress and HTTPS-only egress | HTTPS egress remains a broad channel; introduce VPC endpoints, DNS controls, and an egress proxy. |
| T5 | Automated response disrupts a legitimate workload | Audit-by-default response mode and severity gate | Severity alone is insufficient for production; require allow/deny lists, resource criticality, approval, and rollback. |
| T6 | Lambda role is abused | EC2-only policy, instance resource type, and `AllowAutomatedResponse=true` tag condition | Tag governance remains essential; protect the response-eligibility tag with organisational policy. |
| T7 | Terraform supply chain is compromised | Version constraints and CI validation | Commit the provider lock file and add provenance/vulnerability scanning. |

## Assumptions

- AWS emits the documented GuardDuty and CloudTrail event shapes.
- The deployer protects Terraform state and uses short-lived credentials.
- Operators validate `response_mode = "enforce"` in an isolated account first.
- Email subscription confirmation and incident ownership are external procedures.

## Explicit non-goals

- Certification against CIS, ISO 27001, SOC 2, or PCI DSS.
- Multi-account delegated administration.
- Automated remediation of IAM, S3, Kubernetes, or credential findings.
- Claims of a measured MTTR until experiments in the evaluation protocol are run.
