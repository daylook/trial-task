# Application Load Balancer for EKS Ingress
resource "aws_lb" "eks_alb" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  enable_http2                     = true

  tags = {
    Name        = "${var.cluster_name}-alb"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.cluster_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-alb-sg"
    Environment = var.environment
  }
}

# Target Group for HTTP traffic
resource "aws_lb_target_group" "http" {
  name        = "${var.cluster_name}-http-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Name        = "${var.cluster_name}-http-tg"
    Environment = var.environment
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.eks_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

# Optional: HTTPS Listener (requires ACM certificate)
# Uncomment when you have an ACM certificate ARN
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.eks_alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = var.certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.http.arn
#   }
# }

# Allow traffic from ALB to EKS nodes
resource "aws_security_group_rule" "eks_from_alb" {
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = var.eks_security_group_id
  source_security_group_id = aws_security_group.alb_sg.id
  description              = "Allow NodePort traffic from ALB"
}
