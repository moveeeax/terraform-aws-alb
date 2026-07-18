output "id" {
  description = "ARN of the load balancer."
  value       = aws_lb.this.id
}

output "arn" {
  description = "ARN of the load balancer."
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Route 53 hosted zone ID of the load balancer."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group."
  value       = aws_lb_target_group.this.arn
}
