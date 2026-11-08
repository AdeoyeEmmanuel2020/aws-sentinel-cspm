# Security policy

Please report suspected vulnerabilities privately through GitHub's **Report a
vulnerability** feature. Do not include credentials, account identifiers, or live
exploit data in a public issue.

This project is a research prototype. Deploy it first in an isolated AWS account,
review the Terraform plan, and retain `response_mode = "audit"` until the response
policy and rollback procedure have been approved and tested.
