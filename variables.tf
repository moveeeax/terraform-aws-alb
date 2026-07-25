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

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535 && floor(var.target_port) == var.target_port
    error_message = "The target_port must be a whole number between 1 and 65535."
  }
}

variable "target_protocol" {
  description = "Protocol to use for routing traffic to targets. Application load balancers support HTTP and HTTPS only."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_protocol)
    error_message = "The target_protocol must be either HTTP or HTTPS; application load balancers do not support other protocols."
  }
}

variable "target_type" {
  description = "Type of target registered with the target group."
  type        = string
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip"], var.target_type)
    error_message = "The target_type must be either instance or ip."
  }
}

variable "health_check_path" {
  description = "Destination path for target group health checks."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "The health_check_path must start with a forward slash."
  }
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on the load balancer."
  type        = bool
  default     = false
}

variable "drop_invalid_header_fields" {
  description = "Whether HTTP headers with invalid header fields are removed by the load balancer before reaching targets. Defaults to true; disabling it lets malformed headers through and exposes targets to request smuggling."
  type        = bool
  default     = true
}

variable "access_logs" {
  description = "Access log configuration for the load balancer. Set to null to disable access logging. The bucket must already exist and grant the ELB log delivery account write access."
  type = object({
    bucket  = string
    prefix  = optional(string)
    enabled = optional(bool, true)
  })
  default = null

  validation {
    condition     = var.access_logs == null || try(length(var.access_logs.bucket) > 0, false)
    error_message = "The access_logs.bucket must be a non-empty S3 bucket name."
  }
}

variable "tags" {
  description = "Tags applied to the load balancer and target group."
  type        = map(string)
  default     = {}
}
