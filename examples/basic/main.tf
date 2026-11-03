terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region to deploy the example load balancer into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for the target group."
  type        = string
}

variable "subnet_ids" {
  description = "At least two subnet IDs for the load balancer."
  type        = list(string)
}

provider "aws" {
  region = var.region
}

module "alb" {
  source = "../.."

  name    = "example-alb"
  vpc_id  = var.vpc_id
  subnets = var.subnet_ids

  target_port     = 80
  target_protocol = "HTTP"

  # Lets a later change to the target port or protocol replace the target
  # group in one apply; see the README's Scope section.
  target_group_name_prefix = "ex-"

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "alb_dns_name" {
  value = module.alb.dns_name
}
