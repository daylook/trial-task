resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-subnet-${count.index}"
    # "kubernetes.io/role/internal-elb"              = "1"
    # "kubernetes.io/cluster/${var.env}-eks-cluster" = "owned"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index + 2)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${var.project}-private-subnet-${count.index}"
    # "kubernetes.io/role/internal-elb"              = "1"
    # "kubernetes.io/cluster/${var.env}-eks-cluster" = "owned"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Create a public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.project}-public-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Create a NAT Gateway for private subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "eks_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "eks-nat-gateway"
  }
}

# Create a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gateway.id
  }

  tags = {
    Name = "eks-private-route-table"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = 2
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

# -------------------
# security group
# -------------------
resource "aws_security_group" "eks_security_group" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-security-group"
  }
}

# Inbound rule to allow HTTPS traffic for Kubernetes API
resource "aws_security_group_rule" "eks_inbound_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_security_group.id
}

# Inbound rule to allow SSH traffic (optional)
resource "aws_security_group_rule" "eks_inbound_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_security_group.id
}

# Outbound rule to allow all traffic to the internet
resource "aws_security_group_rule" "eks_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_security_group.id
}