# Research methodology and evaluation protocol

## Research question

To what extent can an infrastructure-as-code security baseline reduce detection
and containment latency for high-severity AWS findings without introducing
unacceptable false containment or loss of audit evidence?

## Falsifiable hypotheses

- **H1:** For synthetic high-severity EC2 findings, the median time from EventBridge
  ingestion to a Lambda decision is below 60 seconds under the stated test load.
- **H2:** In audit mode, zero evaluated findings cause an AWS mutating API call.
- **H3:** The decision function returns the expected action for every case in the
  versioned test corpus.
- **H4:** A fresh deployment passes Terraform validation and all specified control
  observations in two supported regions.

## Experimental design

1. Deploy to an isolated AWS research account using a versioned commit and record
   region, provider lock file, Terraform version, and deployment timestamp.
2. Run a pre-registered corpus containing low/high severity EC2 findings, non-EC2
   findings, malformed events, and duplicate events. Never inject real credentials.
3. Execute the corpus in `audit` mode first. Capture EventBridge ingestion time,
   Lambda start/end time, decision, error count, and CloudTrail mutating calls.
4. After approval, repeat EC2 cases in `enforce` mode against disposable tagged
   instances. Verify stop state and document recovery time.
5. Repeat each condition at least 30 times per region. Report median, p95, range,
   failures, and confidence intervals; retain raw, de-identified observations.

## Variables and metrics

| Category | Measure |
|---|---|
| Independent | response mode, region, finding type, severity, event validity |
| Primary | decision latency, end-to-end containment latency, correct-action rate |
| Safety | unintended mutations, false containment, duplicate containment calls |
| Reliability | Lambda errors/throttles, EventBridge failed invocations |
| Cost | invocations, log ingestion/storage, GuardDuty and Security Hub charges |

## Reproducibility record

Each result must include the Git commit, Terraform/provider versions, variable
values with secrets removed, AWS region, test-corpus version, UTC timestamps, and
the exact analysis script. Store raw results separately from screenshots; a
screenshot is supporting evidence, not a machine-verifiable measurement.

## Validity limitations

Synthetic findings test orchestration rather than GuardDuty's detection quality.
An isolated account may not reproduce production quotas, organisational policies,
or workload dependencies. A severity threshold is not a causal risk model. Results
therefore support claims about this pipeline under the recorded conditions, not a
general claim of compliance, zero trust, or enterprise readiness.

## Ethical and operational safeguards

Use only owned sandbox accounts and disposable resources. Keep audit mode as the
default, require human approval for enforce mode, redact identifiers in published
datasets, define rollback before each run, and cap experiment duration and spend.
