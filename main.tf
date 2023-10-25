#tfsec:ignore:aws-eks-no-public-cluster-access
#tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name                   = var.instance_name
  cluster_version                = var.eks_version
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id     = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.cluster_private_subnets.ids

  manage_aws_auth_configmap = true
  aws_auth_roles = concat(
    var.aws_auth_roles,
    [{
      rolearn  = module.common_node_role.iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes"
      ]
    }]
  )

  create_kms_key            = false
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.cluster_encyption_key.arn
    resources        = ["secrets"]
  }

  iam_role_use_name_prefix = false

  cluster_addons = {

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
    }

    coredns = {
      most_recent          = true
      configuration_values = jsonencode({
        nodeSelector = {
          "node.kubernetes.io/role" = "management"
        }
        tolerations = [
          {
            key      = "dedicated"
            operator = "Equal"
            value    = "management"
            effect   = "NoSchedule"
          }
        ]
      })
    }

    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      configuration_values     = jsonencode({
        nodeSelector = {
          "node.kubernetes.io/role" = "management"
        }
        tolerations = [
          {
            key      = "dedicated"
            operator = "Equal"
            value    = "management"
            effect   = "NoSchedule"
          }
        ]
      })
    }
  }

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    allow_control_plane_tcp = {
      description                   = "Allow TCP Protocol Port"
      protocol                      = "TCP"
      from_port                     = 1024
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_group_defaults = {
    force_update_version = true
    enable_monitoring    = true
  }

  eks_managed_node_groups = {
    # dedicated mgmt node group, other node groups managed by karpenter
    (var.management_node_group_name) = {
      ami_type       = var.management_node_group_ami_type
      platform       = var.management_node_group_platform
      instance_types = var.management_node_group_instance_types
      capacity_type  = var.management_node_group_capacity_type
      min_size       = var.management_node_group_min_size
      max_size       = var.management_node_group_max_size
      desired_size   = var.management_node_group_desired_size
      disk_size      = var.management_node_group_disk_size
      labels = {
        "nodegroup"               = var.management_node_group_name
        "node.kubernetes.io/role" = var.management_node_group_role
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = var.management_node_group_role
          effect = "NO_SCHEDULE"
        }
      }
    }
  }
}

resource "aws_kms_key" "cluster_encyption_key" {
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = {
    Name = "${var.instance_name}-kms"
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.instance_name}-kms"
  target_key_id = aws_kms_key.cluster_encyption_key.key_id
}

module "vpc_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name             = "${var.instance_name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name             = "${var.instance_name}-ebs-csi-controller-sa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "common_node_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.30.0"

  create_instance_profile = true
  create_role             = true
  role_name               = "${var.instance_name}-common-node-role"
  trusted_role_services   = ["ec2.amazonaws.com"]
  role_requires_mfa       = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}