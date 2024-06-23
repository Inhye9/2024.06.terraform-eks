# ------------------------------------------------------------------------
# 보안그룹(security group)
# ------------------------------------------------------------------------
# 보안 그룹 생성(eks-cluster security group)
resource "aws_security_group" "eks_cluster_sg" {
  name = "${var.cluster_name}-eks-cluster-sg"
  #name_prefix = "${var.cluster_name}-eks-cluster-sg"  #난수 자동 생성
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags,{
    Name = "${var.cluster_name}-sg"
  })
}

# 보안 그룹 생성(eks-cluster node security group)
resource "aws_security_group" "eks_cluster_node_sg" {
  name = "${var.cluster_name}-eks-node-sg"
  #name_prefix = "${var.cluster_name}-eks-node-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9443
    to_port     = 9443 
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = [ "${aws_security_group.eks_cluster_sg.id}" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags,{
    Name = "${var.cluster_name}-node-sg"
  })
}
