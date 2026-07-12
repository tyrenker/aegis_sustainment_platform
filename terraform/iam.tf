# TODO (Phase 1, step 3): write your IAM roles here.
#
# What this file needs to end up with:
#   - one role for whatever will manage/operate the cluster (least-privilege — only the actions
#     it actually needs, not AdministratorAccess)
#   - one separate, read-only "auditor" role
#
# Reference: registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
#
# Testing note from the bible: don't trust a policy because it looks right on paper. Use the AWS
# IAM policy simulator, or more convincingly, actually attempt an action that should be denied
# with credentials assuming this role and confirm it fails.
#
# Break-it exercise (do this before moving on): write one deliberately over-permissive policy
# ("Action": "*") attached to a test role, confirm the simulator flags it, then fix it and delete
# the test role.

# EKS cluster service role: what EKS itself assumes to manage the control plane
resource "aws_iam_role" "eks_cluster" {
  name = "aegis-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS node group role: what worker node EC2 instances assume 
resource "aws_iam_role" "eks_node" {
  name = "aegis-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"


}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Bedrock invocation policy
resource "aws_iam_policy" "bedrock_invoke" {
  name        = "aegis-bedrock-invoke"
  description = "Least privilege Bedrock model invocation for the AI assistant's summarization path"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["bedrock:InvokeModel"]
      Resource = [
        "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_bedrock" {
  role       = aws_iam_role.eks_node.name
  policy_arn = aws_iam_policy.bedrock_invoke.arn
}

# Auditor role: read-only with explicit denies for sensitive actions
resource "aws_iam_role" "auditor" {
  name = "aegis-auditor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "sts:AssumeRole"
      Condition = {
        # Real orgs would scope this to a specific IAM user/group ARN, not account root —
        # left broader here since this is a single-operator lab account.
        Bool = { "aws:MultiFactorAuthPresent" = "true" }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "auditor_readonly" {
  role       = aws_iam_role.auditor.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Explicit deny, layered on top of ReadOnlyAccess, blocking the handful of read-adjacent actions
# that can still exfiltrate sensitive data (e.g., pulling a Secrets Manager secret value is
# technically a "read" but should never be available to an auditor role).
resource "aws_iam_role_policy" "auditor_explicit_deny" {
  name = "aegis-auditor-explicit-deny"
  role = aws_iam_role.auditor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Deny"
      Action = [
        "secretsmanager:GetSecretValue",
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Resource = "*"
    }]
  })
}

data "aws_caller_identity" "current" {}
