# TODO (Phase 1, step 2): write your VPC here.
#
# Before writing any resource blocks, do the HashiCorp "Get Started - AWS" tutorial
# (developer.hashicorp.com/terraform/tutorials/aws-get-started) if you haven't already, so the
# init/plan/apply loop is already familiar.
#
# What this file needs to end up with:
#   - one aws_vpc
#   - at least one public subnet (aws_subnet with map_public_ip_on_launch = true, routed to an
#     internet gateway) and one private subnet (no route to the internet)
#   - an aws_internet_gateway attached to the VPC
#   - route tables + associations wiring the subnets to the right routing behavior
#   - security groups — start from deny-by-default, only open exactly the ports you need
#
# Reference: registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
#
# Reminder from the bible (Phase 1 "why"): almost nothing in this project needs to be in a
# public subnet — even your services are reached through the cluster, not directly. Think about
# which resources actually need one before defaulting everything to public.

resource "aws_vpc" "aegis" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "aegis-vpc" }
}

resource "aws_internet_gateway" "aegis" {
  vpc_id = aws_vpc.aegis.id
  tags   = { Name = "aegis-igw" }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.aegis.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                     = "aegis-public-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.aegis.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                              = "aegis-private-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "aegis-nat-eip" }
}

resource "aws_nat_gateway" "aegis" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = { Name = "aegis-nat" }

  depends_on = [aws_internet_gateway.aegis]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aegis.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aegis.id
  }

  tags = { Name = "aegis-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.aegis.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aegis.id
  }

  tags = { Name = "aegis-private-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "eks_cluster" {
  name        = "aegis-eks-cluster-sg"
  description = "EKS control plane to node communication"
  vpc_id      = aws_vpc.aegis.id

  tags = { Name = "aegis-eks-cluster-sg" }
}

resource "aws_security_group_rule" "cluster_ingress_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  description              = "Allow worker nodes to reach the EKS API server"
}

resource "aws_security_group" "eks_nodes" {
  name        = "aegis-eks-nodes-sg"
  description = "Allow node-to-node, EKS API, and node-to-egress traffic"
  vpc_id      = aws_vpc.aegis.id

  ingress {
    description = "Node to node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Control plane to node (kubelet, webhooks)"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    description = "Nodes need outbound for image pulls, Bedrock calls, Helm chart repos"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "aegis-eks-nodes-sg" }
}
