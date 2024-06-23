# 클러스터 엔드포인트 출력
output "cluster_endpoint" {
  value = aws_eks_cluster.blue.endpoint
}

# 클러스터 인증 기관 정보 출력
output "cluster_certificate_authority" {
  value = aws_eks_cluster.blue.certificate_authority[0].data
}

# 클러스터 이름 출력
output "cluster_name" {
  value = aws_eks_cluster.blue.name
}