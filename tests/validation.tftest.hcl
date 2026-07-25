# Test-only requirement: `mock_provider` needs Terraform >= 1.7. The module
# itself still supports >= 1.5 (see versions.tf).

mock_provider "aws" {}

variables {
  name    = "test-alb"
  vpc_id  = "vpc-00000000000000000"
  subnets = ["subnet-0000000000000000a", "subnet-0000000000000000b"]
}

run "rejects_a_single_subnet" {
  command = plan

  variables {
    subnets = ["subnet-0000000000000000a"]
  }

  expect_failures = [var.subnets]
}

run "rejects_a_non_alb_target_protocol" {
  command = plan

  variables {
    target_protocol = "TCP"
  }

  expect_failures = [var.target_protocol]
}

run "rejects_an_unknown_target_type" {
  command = plan

  variables {
    target_type = "container"
  }

  expect_failures = [var.target_type]
}

run "rejects_an_out_of_range_target_port" {
  command = plan

  variables {
    target_port = 70000
  }

  expect_failures = [var.target_port]
}

run "rejects_a_relative_health_check_path" {
  command = plan

  variables {
    health_check_path = "healthz"
  }

  expect_failures = [var.health_check_path]
}

run "rejects_access_logs_without_a_bucket" {
  command = plan

  variables {
    access_logs = {
      bucket = ""
    }
  }

  expect_failures = [var.access_logs]
}
