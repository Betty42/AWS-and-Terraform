variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  type = "list"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  type = "list"
  default = ["us-east-1a", "us-east-1b"]
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}


variable "webserver_logs_bucket" {
  description = "S3 bucket name for the webserver logs"
  type        = string
}

variable "webserver_remote_state_key" {
  description = "path for webserver remote state in S3"
  type        = string
}