{
    "aws_region": "us-east-1",
    "assume_role": "PSKRoles/PSKPlatformEKSBaseRole",
    "account_id": "{{ twdps/di/svc/aws/dps-2/aws-account-id }}",090950721693

    "cluster_name": "gha-sandbox",
    "cluster_version": "1.27",
    "cluster_vpc_name": "sbx-i01-aws-us-east-1",
    "subnet_identifier": "node",
    "aws_auth_roles": [
        {
        "rolearn": "arn:aws:iam::${SANDBOX_AWS_ACCOUNT_ID}:role/di-roles/di-global-platform-eks-base-role",
        "username": "di-global-platform-eks-base-role",
        "groups": [
            "system:masters"
        ]
        }
    ],

    "node_group_a_capacity_type": "SPOT",
    "node_group_a_desired_capacity": "1",
    "node_group_a_min_capacity": "1",
    "node_group_a_max_capacity": "3",
    "node_group_a_disk_size": "40",
    "node_group_a_instance_types": [
        "t2.2xlarge",
        "t3.2xlarge",
        "t3a.2xlarge",
        "m5.2xlarge",
        "m5n.2xlarge",
        "m4.2xlarge"
    ]
}
