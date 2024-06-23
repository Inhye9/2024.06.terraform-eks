provider "aws" {
  region = var.region
}

# ------------------------------------------------------------------------
# Tag
# ------------------------------------------------------------------------
locals {
  common_tags = {
    CreatedBy = "Terraform"
    Group     = "${var.cluster_name}-group"
  }
}

# ------------------------------------------------------------------------
# DataSource
# ------------------------------------------------------------------------
data "aws_eks_cluster_auth" "eks-blue-auth" {name = aws_eks_cluster.blue.name}  
data "aws_availability_zones" "available" {} 
data "aws_caller_identity" "current" {}  

# ------------------------------------------------------------------------
# VPC & Subnets(VPC & Subnet)
# ------------------------------------------------------------------------
# VPC ID를 통해 VPC 정보를 가져옴
data "aws_vpc" "selected_vpc" {
  id = var.vpc_id
}

# VPC ID를 통해 서브넷 정보를 가져옴
data "aws_subnets" "selected_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected_vpc.id]
  }
}


# ------------------------------------------------------------------------
# EKS 클러스터(EKS Cluster)
# ------------------------------------------------------------------------
# EKS(blue) 클러스터 생성
resource "aws_eks_cluster" "blue" {
  name     = var.cluster_name
  version  = var.eks_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = data.aws_subnets.selected_subnets.ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}"
  })
}

# ------------------------------------------------------------------------
# EKS 클러스터 노드그룹 시작 템플릿(EKS Cluster NodeGroup Launch Template)
# ------------------------------------------------------------------------
# 시작 템플릿(Launch Template) - tags
variable "lt_resource_tags" {  # LT 리소스 태깅을 위한 변수
  type    = set(string)
  default = ["instance", "volume", "spot-instances-request"]
}

# 시작 템플릿(Launch Template) - app 
resource "aws_launch_template" "app_launch_template" {
  name     = "${var.cluster_name}-app-node-template"
  #image_id = "AL2_x86_64"
  #instance_type = ["t3.micro"]
  key_name = var.key_pair_name
  # vpc_security_group_ids = [module.eks.cluster_primary_security_group_id]#, aws_security_group.remote_access.id]

  user_data = base64encode(<<-EOF
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="//"

    --//
    Content-Type: text/x-shellscript; charset="us-ascii"
    #!/bin/bash

    set -ex
    /etc/eks/bootstrap.sh ${var.cluster_name} \
      --b64-cluster-ca ${aws_eks_cluster.blue.certificate_authority[0].data} \
      --apiserver-endpoint ${aws_eks_cluster.blue.endpoint}  \
      --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup=${var.cluster_name}-app-ng, eks.amazonaws.com/nodegroup-image=ami-05dbe6c320b293cea'
 
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="//"

    --//--
    EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }  

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name = "${var.cluster_name}-app-node"
    })
  }


  #dynamic "tag_specifications" {
  #  for_each = var.lt_resource_tags
  #  content {
  #    #resource_type = tag_specifications.key
  #    tags = merge(local.common_tags, {
  #      Name = "${var.cluster_name}-node-template"
  #    })
  #  }
  #}

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.eks_cluster_node_sg.id]
  }

}

# ------------------------------------------------------------------------
# EKS 클러스터 노드그룹 (Node Group)
# ------------------------------------------------------------------------
# EKS 노드 그룹 생성 (앱 노드 그룹)
resource "aws_eks_node_group" "app_ng" {
  cluster_name    = aws_eks_cluster.blue.name
  node_group_name = "${var.cluster_name}-app-ng"
  #node_group_name_prefix = "${var.cluster_name}-app-ng-"
  ami_type        = "AL2_x86_64"
  #instance_types  = ["t3.micro"] 
  labels 	  = {
	node-group = "app" 
  }

  #arn             = aws_iam_role.eks_node_group_role.arn
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = data.aws_subnets.selected_subnets.ids

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = var.app_ng_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_eks_cluster.blue,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-app-ng",
    kubernetes.io/cluster/"${var.cluster_name}" = owned
  })
}
