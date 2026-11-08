variable "project_name" { type = string }
variable "environment" { type = string }

variable "response_mode" {
  description = "Response behavior: audit logs the proposed action; enforce stops a GuardDuty-identified EC2 instance."
  type        = string
  default     = "audit"

  validation {
    condition     = contains(["audit", "enforce"], var.response_mode)
    error_message = "response_mode must be either audit or enforce."
  }
}
