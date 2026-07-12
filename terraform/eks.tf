# TODO (Phase 3, step 1): write your EKS cluster + node group here.
#
# Write raw aws_eks_cluster / aws_eks_node_group resources yourself rather than importing the
# community terraform-aws-modules/eks module — you can compare your work against that module
# afterward, once you understand what it's doing for you.
#
# What this file needs to end up with:
#   - aws_eks_cluster referencing your Phase 1 VPC subnets
#   - aws_eks_node_group referencing the AMI you baked in Phase 2 (packer/rhel9-stig.pkr.hcl)
#   - IAM roles for the cluster and node group (separate from the Phase 1 operator/auditor roles)
#
# Reference: registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
#
# After it's up, point kubectl at it:
#   aws eks update-kubeconfig --name <cluster-name> --region us-east-1
#
# Cost note: EKS control plane + running node group is real hourly spend even idle. Destroy
# between work sessions: terraform destroy -target=aws_eks_cluster.this (or the whole stack).
