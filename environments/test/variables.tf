
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "thm-test"
}

variable "region" {
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "vpc_id" {
  description = "The ID of the existing VPC: ih-vpc"
  type        = string
}

variable "eks_version" {
  description = "The EKS version for the green cluster"
  type        = string
  default     = "1.27"
}

variable "key_path" {
  description = "Path to the key file"
  type        = string
}


variable "key_pair_name" {
  description = "key_pair_name"
  type        = string
}

# variable "blue_eks_role_name" {
#   description = "The name of the existing blue EKS cluster IAM role"
#   type        = string
# }

# variable "blue_eks_nodes_role_name" {
#   description = "The name of the existing blue EKS nodes IAM role"
#   type        = string
# }
