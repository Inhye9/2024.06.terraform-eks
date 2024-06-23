# ------------------------------------------------------------------------
# Provider 설정 
# ------------------------------------------------------------------------
provider "kubernetes" {
  host                   = aws_eks_cluster.blue.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.blue.certificate_authority[0].data)
#  token                  = data.aws_eks_cluster_auth.eks-blue-auth.token
#  load_config_file       = false
  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--region", "${var.region}",  "--cluster-name", aws_eks_cluster.blue.name]
      command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.blue.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.blue.certificate_authority[0].data)
#    token                  = data.aws_eks_cluster_auth.eks-blue-auth.token
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--region", "${var.region}",  "--cluster-name", aws_eks_cluster.blue.name]
      command     = "aws"
    }
#    #load_config_file       = false
  }
}

#provider "kubernetes" {
#  config_path = "~/.kube/config"
#}

#provider "helm" {
#  kubernetes {
#    config_path = "~/.kube/config"
#  }
#}
