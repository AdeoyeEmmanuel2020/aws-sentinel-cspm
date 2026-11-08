variable "project_name" { type = string }
variable "environment" { type = string }
variable "alert_email" {
  description = "Optional email endpoint for GuardDuty alerts. Leave empty to omit the subscription."
  type        = string
  default     = ""

  validation {
    condition     = var.alert_email == "" || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be empty or a syntactically valid email address."
  }
}
variable "enable_guardduty" {
  type    = bool
  default = false
}
