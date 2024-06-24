variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
}

# variable "eks_role_name" {
#   description = "IAM role name for EKS"
#   type        = string
# }

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_version" {
  description = "EKS cluster version"
  type        = string
}

# variable "app_launch_template_id" {
#   description = "Launch template ID for app node group"
#   type        = string
# }

# variable "app_launch_template_version" {
#   description = "Launch template version for app node group"
#   type        = string
# }

# variable "mgmt_launch_template_id" {
#   description = "Launch template ID for management node group"
#   type        = string
# }

# variable "mgmt_launch_template_version" {
#   description = "Launch template version for management node group"
#   type        = string
# }

# variable "front_launch_template_id" {
#   description = "Launch template ID for front node group"
#   type        = string
# }

# variable "front_launch_template_version" {
#   description = "Launch template version for front node group"
#   type        = string
# }

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
}

variable "key_pair_name" {
  description = "key_pair_name"
  type        = string
}

variable "app_ng_version" {
  description = "App NodeGroup Version"
  type        = string
}

variable "mgmt_ng_version" {
  description = "Mgmt NodeGroup Version"
  type        = string
}
# variable "front_ng_version" {
#   description = "Front NodeGroup Version"
#   type        = string
# }

# variable "mgmt_ng_version" {
#   description = "Mgmt NodeGroup Version"
#   type        = string
# }

# variable "tags" {
#   description = "Tags"
#   type        = string
# }

variable "vpc_cni_version" {
  description = "Version of the VPC CNI add-on"
  type        = string
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy add-on"
  type        = string
}

variable "coredns_version" {
  description = "Version of the CoreDNS add-on"
  type        = string
}

variable "aws_ebs_csi_driver_version" {
  description = "Version of the EBS CSI Driver add-on"
  type        = string
}

variable "aws_efs_csi_driver_version" {
  description = "Version of the EFS CSI Driver add-on"
  type        = string
}

variable "aws_load_balancer_controller_version" {
  description = "Version of the AWS Load Balancer Controller add-on"
  type        = string
}

variable "external_dns_version" {
  description = "Version of the External DNS add-on"
  type        = string
}


