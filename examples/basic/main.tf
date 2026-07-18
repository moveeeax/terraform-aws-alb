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

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "alb_dns_name" {
  value = module.alb.dns_name
}
