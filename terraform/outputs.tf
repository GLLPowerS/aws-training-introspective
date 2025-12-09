output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "cluster_oidc_issuer" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "EKS OIDC issuer URL"
}

output "product_repository_url" {
  value       = aws_ecr_repository.product.repository_url
  description = "ECR URL for product-service"
}

output "order_repository_url" {
  value       = aws_ecr_repository.order.repository_url
  description = "ECR URL for order-service"
}

output "product_irsa_role_arn" {
  value       = local.product_irsa_arn
  description = "IRSA role ARN for product-service"
}

output "order_irsa_role_arn" {
  value       = local.order_irsa_arn
  description = "IRSA role ARN for order-service"
}
