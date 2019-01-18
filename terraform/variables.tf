# AWS CREDENTIALS
variable "vpc_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment_tag" {
  description = "Name of environment"
  default = "midproj"
}

# VPC Config
variable "vpc_name" {
  description = "VPC for building demos"
  default     = "midproj"
}

variable "vpc_cidr_block" {
  description = "IP addressing for VPC Network"
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "default AMI ID of ubuntu18 image"
  default = "ami-0ac019f4fcb7cb7e6"
}

variable "instance_type" {
  description = "Amazon instance type for new instances"
  default     = "t3.medium"
}
