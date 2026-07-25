# Test-only requirement: `mock_provider` needs Terraform >= 1.7. The module
# itself still supports >= 1.5 (see versions.tf); only `terraform test` runs
# need the newer CLI. These runs use mocked AWS credentials and never talk to
# the AWS API.

mock_provider "aws" {}

variables {
  name    = "test-alb"
  vpc_id  = "vpc-00000000000000000"
  subnets = ["subnet-0000000000000000a", "subnet-0000000000000000b"]
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = aws_lb.this.drop_invalid_header_fields == true
    error_message = "Invalid HTTP header fields must be dropped by default."
  }

  assert {
    condition     = aws_lb.this.load_balancer_type == "application"
    error_message = "The module must always create an application load balancer."
  }

  assert {
    condition     = aws_lb.this.internal == false
    error_message = "The internal flag must default to false."
  }

  assert {
    condition     = length(aws_lb.this.access_logs) == 0
    error_message = "No access_logs block must be emitted when var.access_logs is null."
  }
}

run "access_logs_are_wired_through_when_configured" {
  command = plan

  variables {
    access_logs = {
      bucket = "example-alb-logs"
      prefix = "test-alb"
    }
  }

  assert {
    condition     = one(aws_lb.this.access_logs).bucket == "example-alb-logs"
    error_message = "The configured access log bucket must be passed to the load balancer."
  }

  assert {
    condition     = one(aws_lb.this.access_logs).prefix == "test-alb"
    error_message = "The configured access log prefix must be passed to the load balancer."
  }

  assert {
    condition     = one(aws_lb.this.access_logs).enabled == true
    error_message = "Access logging must be enabled by default once a bucket is configured."
  }
}

run "drop_invalid_header_fields_can_be_disabled_explicitly" {
  command = plan

  variables {
    drop_invalid_header_fields = false
  }

  assert {
    condition     = aws_lb.this.drop_invalid_header_fields == false
    error_message = "Operators must still be able to opt out of dropping invalid header fields."
  }
}

run "health_check_follows_the_target_protocol" {
  command = plan

  variables {
    target_protocol   = "HTTPS"
    target_port       = 443
    health_check_path = "/healthz"
  }

  assert {
    condition     = one(aws_lb_target_group.this.health_check).protocol == "HTTPS"
    error_message = "The health check must use the same protocol as the target group."
  }

  assert {
    condition     = one(aws_lb_target_group.this.health_check).path == "/healthz"
    error_message = "The health check must use the configured path."
  }
}
