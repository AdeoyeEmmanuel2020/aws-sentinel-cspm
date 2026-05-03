output "vpc_id" {
  description = "ID of the secure VPC"
  value       = module.vpc.vpc_id
}

output "kms_key_id" {
  description = "KMS Key ID for encryption"
  value       = module.kms.key_id
}

output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = module.guardduty.detector_id
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = module.cloudtrail.trail_arn
}

output "logs_bucket" {
  description = "S3 bucket for security logs"
  value       = module.s3_secure.logs_bucket_id
}

output "iam_analyzer_arn" {
  description = "IAM Access Analyzer ARN"
  value       = module.iam_analyser.analyzer_arn
}
