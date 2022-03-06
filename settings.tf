# Application name
variable "app_name" {
  default     = "ndvi_stat"
  description = "Application name"
}

# TF_VAR_AWS_ACCESS_KEY must be defined and exported
variable "AWS_ACCESS_KEY" {
  type = string
}

# TF_VAR_AWS_SECRET_KEY must be defined and exported
variable "AWS_SECRET_KEY" {
  type = string
}

# TF_VAR_AWS_REGION have default value
variable "AWS_REGION" {
  type    = string
  default = "ap-northeast-3"
}

# TF_VAR_AWS_AZ have default value
variable "AWS_AZ" {
  type    = string
  default = "ap-northeast-3a"
}

# TF_VAR_SH_INSTANCE_ID must be defined and exported
variable "SH_INSTANCE_ID" {
 type    = string
}

# TF_VAR_SH_CLIENT_ID must be defined and exported
variable "SH_CLIENT_ID" {
 type    = string
}

# TF_VAR_SH_CLIENT_SECRET must be defined and exported
variable "SH_CLIENT_SECRET" {
 type    = string
}

# AWS Provider settings
provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}
