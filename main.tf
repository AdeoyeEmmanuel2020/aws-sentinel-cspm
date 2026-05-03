module "kms" {
  source       = "./modules/kms"
  project_name = var.project_name
  environment  = var.environment
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}

module "s3_secure" {
  source       = "./modules/s3-secure"
  project_name = var.project_name
  environment  = var.environment
  kms_key_arn  = module.kms.key_arn
}

module "cloudtrail" {
  source        = "./modules/cloudtrail"
  project_name  = var.project_name
  environment   = var.environment
  kms_key_arn   = module.kms.key_arn
  s3_bucket_id  = module.s3_secure.logs_bucket_id
  s3_bucket_arn = module.s3_secure.logs_bucket_arn
}

module "guardduty" {
  source           = "./modules/guardduty"
  project_name     = var.project_name
  environment      = var.environment
  alert_email      = var.alert_email
  enable_guardduty = var.enable_guardduty
}

module "security_hub" {
  source              = "./modules/security-hub"
  project_name        = var.project_name
  environment         = var.environment
  enable_security_hub = var.enable_security_hub
}

module "iam_analyser" {
  source       = "./modules/iam-analyser"
  project_name = var.project_name
  environment  = var.environment
}

module "auto_remediation" {
  source            = "./modules/auto-remediation"
  project_name      = var.project_name
  environment       = var.environment
  alert_email       = var.alert_email
  guardduty_enabled = var.enable_guardduty
}
