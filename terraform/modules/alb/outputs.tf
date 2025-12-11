output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.eks_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.eks_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.eks_alb.zone_id
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "http_target_group_arn" {
  description = "ARN of the HTTP target group"
  value       = aws_lb_target_group.http.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}
