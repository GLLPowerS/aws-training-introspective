variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cl-01"
}

variable "cluster_access_entries" {
  description = "List of principals to grant EKS access entries. Each entry supplies the principal ARN and one or more EKS access policy ARNs (for example AmazonEKSClusterAdminPolicy)."
  type = list(object({
    principal_arn = string
    policy_arns   = list(string)
  }))
  default = []
}

variable "add_current_caller_access" {
  description = "If true, grant the current AWS caller the access policies in current_caller_policy_arns as a cluster access entry."
  type        = bool
  default     = false
}

variable "current_caller_policy_arns" {
  description = "EKS access policy ARNs to apply when add_current_caller_access is true."
  type        = list(string)
  default = [
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy",
  ]
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
  ]
}

variable "sns_sqs_policy_arn" {
  description = "Optional existing IAM policy ARN granting SNS/SQS access for pub/sub; leave empty to let Terraform create it"
  type        = string
  default     = ""
}

variable "serviceaccount_namespace" {
  description = "Namespace for service accounts"
  type        = string
  default     = "introspect"
}

variable "create_irsa_roles" {
  description = "Whether to create IRSA roles (set false if roles already exist)"
  type        = bool
  default     = false
}

variable "product_irsa_role_arn" {
  description = "Existing IRSA role ARN for product-service (used when create_irsa_roles=false)"
  type        = string
  default     = ""
}

variable "order_irsa_role_arn" {
  description = "Existing IRSA role ARN for order-service (used when create_irsa_roles=false)"
  type        = string
  default     = ""
}

variable "product_service_sa" {
  description = "Service account name for product-service"
  type        = string
  default     = "product-service-sa"
}

variable "order_service_sa" {
  description = "Service account name for order-service"
  type        = string
  default     = "order-service-sa"
}
