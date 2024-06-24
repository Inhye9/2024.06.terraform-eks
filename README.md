# 📌 Terraform - eks blue cluster 생성

## 1. Terraform 설치

- Terraform 1.4.6 설치

```bash
wget https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip

unzip terraform_1.4.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

terraform --version
```

## 2. AWS Configure 등록

```bash
# aws 자격 증명 확인 
aws sts get-caller-identity

# aws 자격 증명 등록 
aws configure 

# aws credentials 확인 
cat ~/.aws/credentials 
[default]
aws_access_key_id = your-access-key-id
aws_secret_access_key = your-secret-access-key
```

## 3. AWS Keypair 생성하기

AWS 웹콘솔 > EC2 > Key pair > Key pair 생성하기

## 4. Kubectl 설치

```bash
# kubectl 설치 
# https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.3/2024-04-19/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin

# kubectl 버전 확인 
kubectl version --client 
```

## 5. Git clone

```bash
git clone https://github.com/Inhye9/2024.06.terraform-eks.git
```

## 6. Terraform 수행

### 1)  test.tfvars에서 변수 입력값 설정

`~/environments/test/test.tfvars`

```bash
region        = "ap-northeast-2"
vpc_id        = <vpc-id>             #"vpc-xxxxxxxx"
cluster_name  = <cluster-name>       # "eks-blue-cluster"
eks_version   = <eks-version>        # "1.29"
key_path      = <pem key 저장 path>  # "/root/eks/keypath"
key_pair_name = <pem key 이름>       # "eks-blue-cluster-key-pair"
```

### 2) terraform 수행

```bash

#terraform init 
terraform init 

#terraform 문법 검사
terraform validate 

#terraform plan 으로 생성 리소스 확인
terraform plan -tf-file=test.tfvars

#terraform 리소스 적용 
terraform apply -tf-file=test.tfvars 

#(참고) terraform 리소스 삭제 
terraform destroy -tf-file=test.tfvars 

```

## 7. Kubeconfig 업데이트

```bash
# 1. **EKS 클러스터에 대한 kubeconfig 파일 생성**
aws eks update-kubeconfig --name <your-cluster-name> --region <your-region>
aws eks update-kubeconfig --name <your-cluster-name> --region <your-region>

# 2. kubeconfig 파일 확인 
cat ~/.kube/config 

```
