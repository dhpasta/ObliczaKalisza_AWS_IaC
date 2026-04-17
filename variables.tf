variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "credentials_files" {
  description = "aws credentails files list, store in local.auto.tfvars"
  type        = list(any)
}

variable "app_name" {
  type        = string
  description = "Deployed application name for services names"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "aws_key_pair name"
}

variable "key_filename" {
  type        = string
  description = "local aws_key_pair public_key filename, ed25519, store in local.auto.tfvars"
}

variable "db_username" {
  type        = string
  description = "created database username"
  default     = "admin"
}

variable "db_name" {
  type        = string
  description = "created database name"
  default     = "data"
}