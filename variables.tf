variable "name" {
  description = "Name of the load balancer."
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal rather than internet-facing."
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnet IDs to attach to the load balancer."
  type        = list(string)

  validation {
    condition     = length(var.subnets) >= 2
    error_message = "An application load balancer requires at least two subnets."
  }
}

variable "security_groups" {
  description = "List of security group IDs to associate with the load balancer."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the target group."
  type        = string
}

variable "target_port" {
  description = "Port on which targets receive traffic."
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Protocol to use for routing traffic to targets."
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target registered with the target group."
  type        = string
  default     = "instance"
}

variable "health_check_path" {
  description = "Destination path for target group health checks."
  type        = string
  default     = "/"
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on the load balancer."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the load balancer and target group."
  type        = map(string)
  default     = {}
}
