variable "project_name"      { type = string }
variable "environment"       { type = string }
variable "alert_email"       { type = string }
variable "enable_guardduty"  {
  type    = bool
  default = false
}
