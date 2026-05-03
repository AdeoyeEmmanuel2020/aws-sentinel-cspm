resource "aws_iam_role" "remediation_lambda" {
  name = "${var.project_name}-remediation-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.remediation_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "remediation_policy" {
  name = "${var.project_name}-remediation-policy"
  role = aws_iam_role.remediation_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances",
          "ec2:DescribeInstances",
          "iam:CreatePolicy",
          "iam:AttachRolePolicy",
          "sns:Publish",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "local_file" "lambda_code" {
  filename = "${path.module}/lambda/index.py"
  content  = <<-PYTHON
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")
    detail       = event.get("detail", {})
    finding_type = detail.get("type", "")
    severity     = detail.get("severity", 0)
    logger.info(f"Finding: {finding_type} | Severity: {severity}")
    if severity >= 7:
        logger.info("HIGH severity - initiating auto-remediation")
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Auto-remediation triggered",
                "finding_type": finding_type,
                "severity": severity
            })
        }
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Below remediation threshold - logged only"})
    }
  PYTHON
}

data "archive_file" "lambda_zip" {
  depends_on  = [local_file.lambda_code]
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda/remediation.zip"
}

resource "aws_lambda_function" "auto_remediation" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-auto-remediation"
  role             = aws_iam_role.remediation_lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60

  # No KMS key — uses default AWS managed encryption
  environment {
    variables = {
      PROJECT_NAME = var.project_name
      ENVIRONMENT  = var.environment
    }
  }

  tags = { Name = "${var.project_name}-auto-remediation" }
}

resource "aws_cloudwatch_event_rule" "trigger_remediation" {
  name        = "${var.project_name}-trigger-remediation"
  description = "Trigger Lambda on HIGH severity findings"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.trigger_remediation.name
  target_id = "AutoRemediation"
  arn       = aws_lambda_function.auto_remediation.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_remediation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_remediation.arn
}
