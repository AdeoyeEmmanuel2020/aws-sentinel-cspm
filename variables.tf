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
  description = "Optional email address for security alerts. Empty disables the email subscription."
  type        = string
  default     = ""

  validation {
    condition     = var.alert_email == "" || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be empty or a syntactically valid email address."
  }
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

variable "response_mode" {
  description = "GuardDuty response behavior. Keep audit for evaluation; use enforce only after operational approval."
  type        = string
  default     = "audit"

  validation {
    condition     = contains(["audit", "enforce"], var.response_mode)
    error_message = "response_mode must be either audit or enforce."
  }
}
