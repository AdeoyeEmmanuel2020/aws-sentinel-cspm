variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "owner" {
  description = "Owner name for tagging"
  type        = string
  default     = "security-team"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "aws-sentinel"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "alert_email" {
  description = "Email address for security alerts"
  type        = string
}

variable "enable_guardduty" {
  description = "Set to true if your AWS account has GuardDuty subscription"
  type        = bool
  default     = false
}

variable "enable_security_hub" {
  description = "Set to true if your AWS account has Security Hub subscription"
  type        = bool
  default     = false
}
