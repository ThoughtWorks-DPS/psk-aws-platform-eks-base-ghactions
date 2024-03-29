variable "aws_region" {
  type = string
  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
    error_message = "Invalid AWS Region name."
  }
}

variable "aws_account_id" {
  type = string
  validation {
    condition     = length(var.aws_account_id) == 12 && can(regex("^\\d{12}$", var.aws_account_id))
    error_message = "Invalid AWS account ID"
  }
}

variable "aws_assume_role" { type = string }

variable "instance_name" {
  type        = string
}

variable "instance_vpc_name" { type = string }

variable "eks_version" {
  type        = string

  validation {
    condition     = can(regex("^1.[2-3][0-9]$", var.eks_version))
    error_message = "Invalid EKS version number"
  }
}

variable "subnet_identifier" {
  type        = string
}

variable "aws_auth_roles" {
  type = list(object({
    rolearn  = string
    groups   = list(string)
    username = string
  }))
}

variable "management_node_group_name" {
  type = string
  validation {
    condition     = (length(var.management_node_group_name) < 63)
    error_message = "Invalid node group name. Must be less than 63 characters."
  }
}

variable "management_node_group_role" {
  type = string
  validation {
    condition     = (length(var.management_node_group_role) < 128)
    error_message = "Invalid node group role name. Must be less than 128 characters."
  }
}

variable "management_node_group_ami_type" {
  type = string
  validation {
    condition     = contains(["AL2_x86_64", "BOTTLEROCKET_x86_64", "AL2_ARM_64", "BOTTLEROCKET_x86_64"], var.management_node_group_ami_type)
    error_message = "Invalid AMI Type. Use AL2_x86_64 | BOTTLEROCKET_x86_64 | AL2_ARM_64 | BOTTLEROCKET_x86_64"
  }
}

variable "management_node_group_platform" {
  type = string
  validation {
    condition     = contains(["linux", "bottlerocket"], var.management_node_group_platform)
    error_message = "Invalid platform Type. Use linux | bottlerocket"
  }
}

variable "management_node_group_disk_size" {
  type = string
  validation {
    condition     = can(regex("^[1-9][0-9]$", var.management_node_group_disk_size))
    error_message = "Invalid node disk size. Use value between 10 to 99gb."
  }
}

variable "management_node_group_capacity_type" {
  type = string
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.management_node_group_capacity_type)
    error_message = "Invalid capacity Type. Use ON_DEMAND | SPOT"
  }
}

variable "management_node_group_desired_size" {
  type = string
  validation {
    condition     = can(regex("^[1-9][0-9]{0,2}$", var.management_node_group_desired_size))
    error_message = "Invalid desired node group size. Must be number beween 1-999"
  }
}

variable "management_node_group_max_size" {
  type = string
  validation {
    condition     = can(regex("^[1-9][0-9]{0,2}$", var.management_node_group_max_size))
    error_message = "Invalid max node group size. Must be number beween 1-999"
  }
}

variable "management_node_group_min_size" {
  type = string
  validation {
    condition     = can(regex("^[1-9][0-9]{0,2}$", var.management_node_group_min_size))
    error_message = "Invalid min node group size. Must be number beween 1-999"
  }
}

variable "management_node_group_instance_types" {
  description = "list of allowable ec2 instance types"
  type        = list(string)
}
