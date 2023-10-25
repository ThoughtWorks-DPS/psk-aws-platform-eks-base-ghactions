data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.instance_vpc_name}-vpc"
  }
}

data "aws_subnets" "cluster_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Tier = var.subnet_identifier
  }
}


# data "aws_subnet" "private_subnets" {
#   for_each = data.aws_subnet_ids.private.ids
#   id       = each.value
# }

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }
