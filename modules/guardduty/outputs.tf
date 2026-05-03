output "detector_id"   { value = var.enable_guardduty ? aws_guardduty_detector.sentinel[0].id : "guardduty-disabled" }
output "sns_topic_arn" { value = aws_sns_topic.guardduty_alerts.arn }
