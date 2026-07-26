# These runs use `apply` against the mocked AWS provider (still no real
# credentials or network access) so that state carries over between runs,
# letting us exercise update-in-place behavior rather than only fresh plans.

mock_provider "aws" {}

variables {
  name    = "test-alb"
  vpc_id  = "vpc-00000000000000000"
  subnets = ["subnet-0000000000000000a", "subnet-0000000000000000b"]
}

run "initial_apply" {
  command = apply
}

run "updating_tags_in_place_does_not_replace_the_target_group" {
  command = apply

  variables {
    tags = {
      Environment = "production"
    }
  }

  assert {
    condition     = aws_lb_target_group.this.arn == run.initial_apply.target_group_arn
    error_message = "A tag-only update must not replace the target group."
  }

  assert {
    condition     = aws_lb_target_group.this.tags["Environment"] == "production"
    error_message = "The updated tag must be applied to the existing target group."
  }
}

run "changing_the_target_port_replaces_the_target_group_in_place" {
  command = apply

  variables {
    target_port = 8080
  }

  assert {
    condition     = aws_lb_target_group.this.port == 8080
    error_message = "The target group must pick up the new port after applying the change."
  }
}
