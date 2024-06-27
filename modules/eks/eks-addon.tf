# ------------------------------------------------------------------------
# Add-on 설정 
# ------------------------------------------------------------------------
# vpc_cni addon 

resource "aws_eks_addon" "vpc_cni" {
  cluster_name          = aws_eks_cluster.blue.name
  addon_name            = "vpc-cni"
  addon_version         = var.vpc_cni_version
  #resolve_conflicts     = "OVERWRITE"
  #service_account_role_arn = aws_iam_role.vpc_cni_irsa.arn   # IRSA 
  service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn   # IRSA 
  #before_compute        = true 

  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"   # prefix assignment mode 활성화 
      WARM_PREFIX_TARGET       = "1"      # 기본 권장 값 
    }
  })

  tags = local.common_tags
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.blue.name
  addon_name        = "kube-proxy"
  addon_version     = var.kube_proxy_version
  #resolve_conflicts = "OVERWRITE"

  tags = local.common_tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.blue.name
  addon_name        = "coredns"
  addon_version     = var.coredns_version
  #resolve_conflicts = "OVERWRITE"

  tags = local.common_tags
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.blue.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.aws_ebs_csi_driver_version
  #resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = module.ebs_csi_driver_irsa_role.iam_role_arn

  tags = local.common_tags
}

resource "aws_eks_addon" "aws_efs_csi_driver" {
  cluster_name             = aws_eks_cluster.blue.name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = var.aws_efs_csi_driver_version
  #resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = module.efs_csi_driver_irsa_role.iam_role_arn

  tags = local.common_tags
}

#aws_eks_addon.aws_load_balancer_controller is not supported 
#resource "aws_eks_addon" "aws_load_balancer_controller" {
#  cluster_name             = aws_eks_cluster.blue.name
#  addon_name               = "aws-load-balancer-controller"
#  addon_version            = var.aws_load_balancer_controller_version
#  #resolve_conflicts        = "OVERWRITE"
#  service_account_role_arn = module.load_balancer_controller_irsa_role.iam_role_arn
#
#  tags = local.common_tags
#}

#aws_eks_addon.external_dns is not supported 
#resource "aws_eks_addon" "external_dns" {
#  cluster_name             = aws_eks_cluster.blue.name
#  addon_name               = "external-dns"
#  addon_version            = var.external_dns_version
#  #resolve_conflicts        = "OVERWRITE"
#  service_account_role_arn = module.external_dns_irsa_role.iam_role_arn
#
#  tags = local.common_tags
#}


# ------------------------------------------------------------------------
# Add-on irsa 설정 
# ------------------------------------------------------------------------
# VPC CNI IRSA------------------------------------------------------------
module "vpc_cni_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  
  #name 		     = "${var.cluster_name}-vpc-cni-irsa"
  role_name          = "${var.cluster_name}-vpc-cni-irsa"
  #policy_name        = "${var.cluster_name}-vpc-cni-irsa-pol"
  #policy_name_prefix = "${var.cluster_name}-vpc-cni-irsa-pol-"
  policy_name_prefix = "${var.cluster_name}-"


  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      #provider_arn               = aws_eks_cluster.blue.oidc_provider_arn
      provider_arn = replace(
        aws_eks_cluster.blue.identity[0].oidc[0].issuer,
        "https://",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/"
      )
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = local.common_tags
}

# EBS CSI Driver IRSA------------------------------------------------------
module "ebs_csi_driver_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
 
  #name 	             = "${var.cluster_name}-ebs-csi-driver-irsa" 
  role_name          = "${var.cluster_name}-ebs-csi-driver-irsa"
  #policy_name        = "${var.cluster_name}-ebs-csi-driver-irsa-pol"
  #policy_name_prefix = "${var.cluster_name}-ebs-csi-driver-irsa-pol-"
  policy_name_prefix = "${var.cluster_name}-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      #provider_arn               = aws_eks_cluster.blue.oidc_provider_arn
       provider_arn = replace(
        aws_eks_cluster.blue.identity[0].oidc[0].issuer,
        "https://",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/"
      )
      namespace_service_accounts = ["kube-system:ebs-csi-driver-sa"]
    }
  }

  tags = local.common_tags
}
# EFS CSI Driver IRSA------------------------------------------------------
module "efs_csi_driver_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  #name 				= "${var.cluster_name}-efs-csi-irsa"
  role_name                     = "${var.cluster_name}-efs-csi-irsa"
  #policy_name                   = "${var.cluster_name}-efs-csi-irsa-pol"
  #policy_name_prefix            = "${var.cluster_name}-efs-csi-irsa-pol-"
  policy_name_prefix            = "${var.cluster_name}-"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      #provider_arn               = aws_eks_cluster.blue.oidc_provider_arn 
      provider_arn = replace(
        aws_eks_cluster.blue.identity[0].oidc[0].issuer,
        "https://",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/"
      )
      namespace_service_accounts = ["kube-system:efs-csi-driver-sa"]
    }
  }

  tags = local.common_tags
}

# AWS Load Balancer Controller IRSA------------------------------------------------
# oidc 생성 
data "tls_certificate" "eks" {
   url = aws_eks_cluster.blue.identity[0].oidc[0].issuer 
}

resource "aws_iam_openid_connect_provider" "eks" { 
   client_id_list  = ["sts.amazonaws.com"] 
   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
   url             = aws_eks_cluster.blue.identity[0].oidc[0].issuer 

   tags = local.common_tags
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
  name               = "${var.cluster_name}-aws-load-balancer-controller"

  tags = local.common_tags
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy = file("../../modules/eks/AWSLoadBalancerController.json")
  name   = "${var.cluster_name}-aws-load-balancer-controller-pol"

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}


#module "load_balancer_controller_irsa_role" {
#  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#
#  #name                  = "${var.cluster_name}-loadbalancer-controller-irsa"
#  role_name             = "${var.cluster_name}-loadbalancer-controller-irsa"
#  policy_name           = "${var.cluster_name}-loadbalancer-controller-irsa-pol"
#  #policy_name_prefix    = "${var.cluster_name}-loadbalancer-controller-irsa-pol-"  
#
#  attach_load_balancer_controller_policy = true
#  
#  oidc_providers = {
#    main = {
#      #provider_arn               = aws_eks_cluster.blue.oidc_provider_arn 
#       provider_arn = replace(
#        aws_eks_cluster.blue.identity[0].oidc[0].issuer,
#        "https://",
#        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/"
#      )
#      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#    }
#  }
#
#  tags = local.common_tags
#}

#module "load_balancer_controller_targetgroup_binding_only_irsa_role" {
#  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#
#  #name      = "${var.cluster_name}-loadbalancer-controller-target-binding-irsa"
#  role_name = "${var.cluster_name}-loadbalancer-controller-target-binding-irsa"
#  #policy_name = "${var.cluster_name}-loadbalancer-controller-target-binding-irsa-pol"
#  #policy_name_prefix    = "${var.cluster_name}-loadbalancer-controller-target-binding-irsa-pol-"  
#  policy_name_prefix    = "${var.cluster_name}-"
#
#  attach_load_balancer_controller_targetgroup_binding_only_policy = true
#
#  oidc_providers = {
#    main = {
#      #provider_arn               = aws_eks_cluster.blue.oidc_provider_arn 
#       provider_arn = replace(
#        aws_eks_cluster.blue.identity[0].oidc[0].issuer,
#        "https://",
#        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/"
#      )
#      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#    }
#  }
#
#  tags = local.common_tags
#}

# External DNS IRSA---------------------------------------------------------------
module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  #name 				= "${var.cluster_name}-external-dns-irsa"
  role_name                     = "${var.cluster_name}-external-dns-irsa"
  #policy_name                   = "${var.cluster_name}-external-dns-irsa-pol"
  #policy_name_prefix            = "${var.cluster_name}-external-dns-irsa-pol-"  
  policy_name_prefix            = "${var.cluster_name}-"

  attach_external_dns_policy    = true
  #external_dns_hosted_zone_arns = [local.external_dns_arn]

  oidc_providers = {
    main = {
      #provider_arn               = aws_eks_cluster.blue.oidc_provider_arn 
      #provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.blue.identity[0].oidc[0].issuer, "https://", "")}"
      provider_arn = replace(
        aws_eks_cluster.blue.identity[0].oidc[0].issuer,
        "https://",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/"
      )
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = local.common_tags
}


# # ------------------------------------------------------------------------
# # Helm 설정 
# # ------------------------------------------------------------------------
resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name        = "aws-load-balancer-controller"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn  # irsa 생성 모듈에서 output으로 iam_role_arn을 제공한다.
    }

#    labels = {
#      "app.kubernetes.io/component" = "controller"
#      "app.kubernetes.io/name" = "aws-load-balancer-controller"
#    }
  }
  depends_on = [aws_iam_role.aws_load_balancer_controller]
}

resource "kubernetes_service_account" "external-dns" {
  metadata {
    name        = "external-dns"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.external_dns_irsa_role.iam_role_arn
    }
  }
  depends_on = [module.external_dns_irsa_role]
}

# https://github.com/GSA/terraform-kubernetes-aws-load-balancer-controller/blob/main/main.tf
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/
resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name = "clusterName"
    value = aws_eks_cluster.blue.name
  }
  set {
    name = "serviceAccount.create"
    value = false
  }
  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  ## no endpoints available for service "aws-load-balancer-webhook-service" 이슈 해결을 위한 옵션 추가
  set {
    name = "region"
    value = var.region 
  }
  set {
    name = "vpcid"
    value = var.vpc_id
  }  
}

# https://tech.polyconseil.fr/external-dns-helm-terraform.html
# parameter https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns
resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  wait       = false  ## 서비스가 완전히 올라올때 까지 대기
  set {
    name = "provider"
    value = "aws"
  }
  set {
    name = "serviceAccount.create"
    value = false
  }
  set {
    name = "serviceAccount.name"
    value = "external-dns"
  }
  set {
    name  = "policy"
    value = "sync"
  }     
}
