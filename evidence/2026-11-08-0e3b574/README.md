# Live AWS validation record

This package records a controlled deployment of commit
`0e3b5745df5ed15ee9c523a7af0071a9cc18660f` to an isolated AWS account in
`us-east-1` on 8 November 2026. Account, principal, resource, bucket, and key
identifiers are omitted from the public record.

## Outcome

- Terraform converged with no drift after creating 42 managed resources.
- CloudTrail, S3 evidence controls, private subnets, the security group, VPC Flow
  Logs, IAM Access Analyzer, EventBridge targets, and Lambda were observed live.
- The Lambda was invoked with low- and high-severity synthetic findings.
- Audit mode returned `would-stop-instance` for the high-severity EC2 finding.
- CloudTrail contained zero `StopInstances` events during the test window.
- Terraform destroyed all 42 managed resources after evidence collection.
- Post-destroy API checks found no remaining named project resources.
- The KMS key entered AWS `PendingDeletion`, with deletion scheduled for
  8 December 2026, as required by the configured 30-day deletion window.

## Scope limitations

GuardDuty and Security Hub were intentionally disabled to avoid enabling paid
security services without a separate approval. The EventBridge pattern was tested
with `test-event-pattern`, and the Lambda target was tested directly; this run did
not evaluate a real GuardDuty-generated finding. SNS email delivery was not tested.
No EC2 instance was created, stopped, or otherwise modified.

## Evidence interpretation

The files in this directory are redacted summaries of machine-readable API
observations. They demonstrate the state observed for this commit and test window;
they do not constitute certification or prove future deployments will behave
identically. See `manifest.csv` for evidence-to-claim mappings.
