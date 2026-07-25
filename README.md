# terraform-aws-alb

Terraform module that manages an [AWS Application Load
Balancer](https://aws.amazon.com/elasticloadbalancing/). It creates a single
application load balancer and a companion target group, exposing the DNS name
and target group ARN so listeners and DNS records can be built on top.

## Usage

```hcl
module "alb" {
  source = "github.com/moveeeax/terraform-aws-alb"

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

## Scope

The module deliberately stops at the load balancer and its target group. It does
**not** create listeners, certificates, or security groups — build those in the
calling configuration on top of `arn` and `target_group_arn`. Two consequences
are worth calling out:

- **Terminate TLS yourself.** Because no listener is created here, there is no
  `ssl_policy` for this module to set. When you add an `aws_lb_listener`, use an
  `HTTPS` listener with a modern policy (for example
  `ELBSecurityPolicy-TLS13-1-2-2021-06`) and redirect any port 80 listener to it
  rather than serving traffic over plain HTTP.
- **Pass a security group.** `security_groups` defaults to `[]`, which makes AWS
  attach the VPC default security group. Pass an explicit, narrowly scoped
  security group for anything beyond a scratch environment.

## Secure defaults

- `drop_invalid_header_fields` defaults to `true`, so malformed HTTP headers are
  stripped before they reach targets.
- Access logging is off until you supply a bucket, since the bucket has to exist
  and carry an ELB log-delivery policy first. Enabling it is a single input:

```hcl
module "alb" {
  source = "github.com/moveeeax/terraform-aws-alb"

  name    = "prod-alb"
  vpc_id  = "vpc-0abc123"
  subnets = ["subnet-0a", "subnet-0b"]

  access_logs = {
    bucket = "my-elb-log-bucket"
    prefix = "prod-alb"
  }

  enable_deletion_protection = true
}
```

- `enable_deletion_protection` defaults to `false` so that ephemeral
  environments can still be torn down. Turn it on for anything long-lived.

## Testing

The module ships a `terraform test` suite that runs against a mocked AWS
provider, so it needs no credentials and no network access:

```sh
terraform init -backend=false
terraform test
```

Running the suite requires Terraform >= 1.7 for `mock_provider`; consuming the
module itself still only requires >= 1.5.

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
| `target_port`                | Port on which targets receive traffic (1-65535).  | `number`       | `80`         |    no    |
| `target_protocol`            | Protocol used to route traffic (`HTTP`/`HTTPS`).  | `string`       | `"HTTP"`     |    no    |
| `target_type`                | Type of target registered (`instance`/`ip`).      | `string`       | `"instance"` |    no    |
| `health_check_path`          | Destination path for health checks.               | `string`       | `"/"`        |    no    |
| `enable_deletion_protection` | Enable deletion protection.                       | `bool`         | `false`      |    no    |
| `drop_invalid_header_fields` | Strip malformed HTTP headers before targets.      | `bool`         | `true`       |    no    |
| `access_logs`                | Access log config, see below. `null` disables.    | `object`       | `null`       |    no    |
| `tags`                       | Tags applied to both resources.                   | `map(string)`  | `{}`         |    no    |

`access_logs` is an object with the following attributes:

| Attribute | Description                                    | Type     | Default  | Required |
|-----------|------------------------------------------------|----------|----------|:--------:|
| `bucket`  | S3 bucket that receives the access logs.       | `string` | n/a      |   yes    |
| `prefix`  | Key prefix within the bucket.                  | `string` | `null`   |    no    |
| `enabled` | Whether log delivery is active.                | `bool`   | `true`   |    no    |

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
