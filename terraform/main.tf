# Uses the default VPC and its subnets, as the capstone brief specifies.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# The EKS module builds the control plane and a managed node group for us.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access = true

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  # Give the identity running terraform admin access to the cluster.
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      desired_size   = var.desired_nodes
      min_size       = var.min_nodes
      max_size       = var.max_nodes
    }
  }

  tags = {
    Project = "voting-app-capstone"
  }
}
