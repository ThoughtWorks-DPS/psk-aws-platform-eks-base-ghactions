{
    "aws_region": "us-east-2",
    "assume_role": "DPSTerraformRole",
    "account_id": "{{ twdps/di/svc/aws/dps-2/aws-account-id }}",

    "cluster_name": "gha-preview",
    "cluster_version": "1.21",
    "cluster_vpc_name": "preview",

    "node_group_a_desired_capacity": "1",
    "node_group_a_capacity_type": "ON_DEMAND",
    "node_group_a_max_capacity": "3",
    "node_group_a_min_capacity": "1",
    "node_group_a_disk_size": "40",
    "node_group_a_instance_types": ["t2.large"]
}
