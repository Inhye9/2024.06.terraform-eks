# ------------------------------------------------------------------------
# AWS Auth 설정 
# ------------------------------------------------------------------------
# AWS Auth 설정을 위한 ConfigMap 생성
module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "${aws_iam_role.eks_node_group_role.arn}"
      #username = "node-group-role"
      username  = "system:node:{{EC2PrivateDNSName}}"
      groups = ["system:bootstrappers", "system:master", "system:nodes"]
    }
  ]
  
  #force = true
}
