# terraform-aws-alb

Terraform module that manages an [AWS Application Load
Balancer](https://aws.amazon.com/elasticloadbalancing/). It creates a single
application load balancer and a companion target group, exposing the DNS name
and target group ARN so listeners and DNS records can be built on top.

## Usage

```hcl
module "alb" {
  source = "github.com/cybercapybara/terraform-aws-alb"

  name    = "prod-alb"
  vpc_id  = "vpc-0abc123"
  subnets = ["subnet-0a", "subnet-0b"]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                         | Description                                       | Type           | Default      | Required |
|------------------------------|---------------------------------------------------|----------------|--------------|:--------:|
| `name`                       | Name of the load balancer.                        | `string`       | n/a          |   yes    |
| `internal`                   | Whether the load balancer is internal.            | `bool`         | `false`      |    no    |
| `subnets`                    | Subnet IDs to attach (at least two).              | `list(string)` | n/a          |   yes    |
| `security_groups`            | Security group IDs to associate.                  | `list(string)` | `[]`         |    no    |
| `vpc_id`                     | VPC ID for the target group.                      | `string`       | n/a          |   yes    |
| `target_port`                | Port on which targets receive traffic.            | `number`       | `80`         |    no    |
| `target_protocol`            | Protocol used to route traffic to targets.        | `string`       | `"HTTP"`     |    no    |
| `target_type`                | Type of target registered.                        | `string`       | `"instance"` |    no    |
| `health_check_path`          | Destination path for health checks.               | `string`       | `"/"`        |    no    |
| `enable_deletion_protection` | Enable deletion protection.                       | `bool`         | `false`      |    no    |
| `tags`                       | Tags applied to both resources.                   | `map(string)`  | `{}`         |    no    |

## Outputs

| Name               | Description                                   |
|--------------------|-----------------------------------------------|
| `id`               | ARN of the load balancer.                     |
| `arn`              | ARN of the load balancer.                     |
| `dns_name`         | DNS name of the load balancer.                |
| `zone_id`          | Route 53 hosted zone ID of the load balancer. |
| `target_group_arn` | ARN of the target group.                      |

## License

[MIT](LICENSE)
