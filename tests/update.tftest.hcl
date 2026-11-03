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

# mock_provider doesn't run the provider's own plan logic, so ForceNew
# attributes don't trigger a replacement here and target group names aren't
# checked for uniqueness. These runs only confirm the inputs reach the target
# group; the replacement itself (and the duplicate-name failure the fixed-name
# mode hits on real AWS) is beyond what a mocked run can show.
run "opting_into_a_name_prefix" {
  command = apply

  variables {
    target_group_name_prefix = "tg-"
  }

  assert {
    condition     = aws_lb_target_group.this.name_prefix == "tg-"
    error_message = "The target group must be named from the configured prefix."
  }
}

run "changing_the_target_port_with_a_name_prefix" {
  command = apply

  variables {
    target_group_name_prefix = "tg-"
    target_port              = 8080
  }

  assert {
    condition     = aws_lb_target_group.this.port == 8080
    error_message = "The target group must pick up the new port after applying the change."
  }
}
