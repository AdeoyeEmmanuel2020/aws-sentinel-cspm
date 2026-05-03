resource "aws_accessanalyzer_analyzer" "sentinel" {
  analyzer_name = "${var.project_name}-access-analyzer"
  type          = "ACCOUNT"

  tags = { Name = "${var.project_name}-iam-analyzer" }
}

# CloudWatch alarm for IAM Analyser findings
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "${var.project_name}-root-login-filter"
  log_group_name = "/aws/${var.project_name}/cloudtrail"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"

  metric_transformation {
    name      = "RootLoginCount"
    namespace = "${var.project_name}/SecurityMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login" {
  alarm_name          = "${var.project_name}-root-login-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootLoginCount"
  namespace           = "${var.project_name}/SecurityMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alert on root account login"
  treat_missing_data  = "notBreaching"
}
