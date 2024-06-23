output "cluster_endpoint" {
  value = module.eks-blue.cluster_endpoint
}

output "cluster_certificate_authority" {
  value = module.eks-blue.cluster_certificate_authority
}

output "cluster_name" {
  value = module.eks-blue.cluster_name
}
