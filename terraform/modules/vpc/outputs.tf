output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "eks_security_group_ids" {
  value = [aws_security_group.eks_security_group.id]
}