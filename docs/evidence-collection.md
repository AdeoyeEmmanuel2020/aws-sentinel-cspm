# Deployment evidence collection protocol

## Purpose

This protocol prevents screenshots from being mistaken for reproducible evidence.
Run it against an isolated AWS research account after deploying the exact commit
under evaluation. A screenshot supports an observation; it does not prove a
control is effective or establish compliance.

## Required provenance

Create a new directory named `evidence/YYYY-MM-DD-<short-commit>/` and record:

- full Git commit SHA and clean/dirty working-tree status;
- Terraform, AWS provider, AWS CLI, and Python versions;
- AWS region and an anonymised account label;
- UTC deployment start and completion times;
- configuration values with email addresses and identifiers redacted;
- `terraform plan` exit code and `terraform apply` result;
- commands used to obtain every observation.

## Minimum evidence set

| ID | Observation | Preferred machine-readable source |
|---|---|---|
| E01 | CloudTrail is multi-region, logging, KMS-encrypted, and validating logs | `aws cloudtrail get-trail` and `get-trail-status` JSON |
| E02 | Primary evidence bucket has versioning, SSE-KMS, TLS-only policy, and public-access blocks | `aws s3api` JSON for the primary bucket—not the access-log bucket |
| E03 | Both subnets disable public-IP assignment | `aws ec2 describe-subnets` JSON |
| E04 | Security group has no ingress and only intended egress | `aws ec2 describe-security-groups` JSON |
| E05 | VPC Flow Logs are active for `ALL` traffic | `aws ec2 describe-flow-logs` JSON |
| E06 | Access Analyzer is active at account scope | `aws accessanalyzer get-analyzer` JSON |
| E07 | EventBridge patterns route severity ≥ 7 GuardDuty findings | `aws events describe-rule` and `list-targets-by-rule` JSON |
| E08 | Lambda environment is `audit` for the baseline experiment | `aws lambda get-function-configuration` JSON |
| E09 | Audit-mode test causes no mutating EC2 API call | CloudTrail query plus versioned synthetic event and Lambda logs |
| E10 | Enforce-mode test stops only a tagged disposable instance | CloudTrail event, before/after instance state, and rollback record |

## Screenshot standard

If console screenshots accompany the JSON evidence:

1. Capture only the relevant panel; omit browser tabs, address bars, bookmarks,
   desktop menus, and unrelated commands.
2. Redact the 12-digit AWS account ID, ARNs containing it, email addresses, user or
   role names tied to a person, bucket suffixes, key IDs, resource IDs, and URLs.
3. Use opaque redaction—not blur—and inspect image metadata before publication.
4. Show the AWS region, control state, and the observation time in the caption or
   manifest, not by exposing the account menu.
5. Use filenames `E##_short-description.png`; never use spaces, duplicate suffixes,
   or numbering that disagrees with the manifest.
6. Do not draw highlight boxes over unrelated output. Crop to the evidence instead.
7. Never reuse a screenshot after the implementation or deployed commit changes.

## Manifest

Each evidence directory must include `manifest.csv` with these columns:

```text
evidence_id,claim,source_file,command,observed_at_utc,region,commit_sha,redacted,reviewer
```

Every screenshot and JSON file must have one manifest row and a SHA-256 checksum.
Record failed or contradictory observations; do not delete them from the research
record. Publication copies may be redacted, while originals remain in the secured
research archive outside the public repository.

## Acceptance criteria

Evidence is publishable only when it is current for the cited commit, contains no
personal or account-identifying data, has a manifest and checksums, matches the
claimed AWS resource, and can be independently reproduced from the recorded
commands. Two-person review is recommended before public release.
