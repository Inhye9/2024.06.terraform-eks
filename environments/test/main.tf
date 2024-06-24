provider "aws" {
  region = var.region
}

# ------------------------------------------------------------------------
#  EKS Cluster(eks-blue) 생성 
# ------------------------------------------------------------------------
# EKS Cluster(eks-blue) 생성
module "eks-blue" {
  source = "../../modules/eks"

  region                          = var.region
  vpc_id                          = var.vpc_id
  cluster_name                    = var.cluster_name
  eks_version                     = var.eks_version 
  public_key_path                 = var.key_path
  key_pair_name                   = var.key_pair_name  
  app_ng_version                  = "1"
  mgmt_ng_version                  = "1"

  # aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version 1.29
  vpc_cni_version                 = "v1.18.1-eksbuild.1"
  kube_proxy_version              = "v1.29.1-eksbuild.2"
  coredns_version                 = "v1.11.1-eksbuild.8"
  aws_ebs_csi_driver_version      = "v1.31.0-eksbuild.1"
  aws_efs_csi_driver_version      = "v2.0.2-eksbuild.1"
  aws_load_balancer_controller_version    = "v2.5.2"
  external_dns_version            = "v0.12.2"
} 

