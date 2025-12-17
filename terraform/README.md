# Terraform Deployment Guide

This folder provisions VPC, EKS (IRSA-enabled), ECR repos, and IAM policy/roles for product-service and order-service.

## Prerequisites
- Terraform >= 1.5
- AWS CLI configured (profile or env vars); run `aws sso login --profile <p>` if using SSO.
- Kustomize binary for later Kubernetes apply (or `kubectl kustomize` if it supports external paths).

## Key Variables (with defaults)
- `aws_region` (us-east-1)
- `cluster_name` (cl-01)
- `create_irsa_roles` (false) — set true in a new/empty account.
- `sns_sqs_policy_arn` (empty) — leave empty to have TF create the policy from `../infra/iam-policies/sns-sqs-pubsub-policy.json`.
- `create_pubsub_infra` (true) — create the SNS topic + SQS queue used by the Dapr `pubsub.aws.snssqs` component.
- `pubsub_topic_name` (product-events) — must match what your apps publish/subscribe to (for example `DAPR_PUBSUB_TOPIC=product-events`).
- `pubsub_queue_name` (order-service) — for `pubsub.aws.snssqs`, the SQS queue name is the runtime `consumerID` (normally the Dapr app-id). In this repo the subscriber is `order-service`.
- `pubsub_queue_message_retention_seconds` (1209600) — must match the existing queue if one already exists.
- `pubsub_queue_visibility_timeout_seconds` (30) — must match the existing queue if one already exists.
- `cluster_access_entries` (empty) — optional list of IAM principals and EKS access policy ARNs to manage cluster access entries.
- `add_current_caller_access` (false) — when true, auto-grant the current AWS caller the policies in `current_caller_policy_arns` as an access entry.
- `current_caller_policy_arns` (Admin/ClusterAdmin/View) — policies applied when `add_current_caller_access` is true.
- `cluster_access_entries` (empty) — optional list of IAM principals and EKS access policy ARNs to manage cluster access entries.

## First-Time Apply (empty account)
```pwsh
cd terraform
$env:AWS_PROFILE="<your-profile>"   # or set AWS_ACCESS_KEY_ID/SECRET
terraform init
terraform apply `
  -var="cluster_name=cl-01" `
  -var="create_irsa_roles=true" `
  -var=cluster_access_entries='[{
    principal_arn="arn:aws:sts::139592182912:federated-user/c04-vlabuser177@stackroute.in",
    policy_arns=[
      "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
      "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
      "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    ]
  }]'
```
This creates VPC, EKS 1.29 with a managed node group, ECR repos, SNS/SQS IAM policy, and IRSA roles bound to the cluster OIDC provider.

### Grant Cluster Access Entries (new EKS access management)
- Supply principals and desired access policies (for example ClusterAdmin/View) at apply time:
```pwsh
terraform apply `
  -var='cluster_access_entries=[{principal_arn="arn:aws:iam::123456789012:user/example",policy_arns=["arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy","arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"]}]'
```
- To just grant the **current caller** admin/cluster-admin/view in one flag (matches the three policies you mentioned):
```pwsh
terraform apply -var="add_current_caller_access=true"
```
- Common policy ARNs:
  - Admin: `arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy`
  - Cluster admin (RBAC cluster-admin): `arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy`
  - View: `arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy`

## If a Cluster Already Exists
- Use a new name: `-var="cluster_name=introspect-eks-02"`, or
- Skip EKS creation (not currently scaffolded; simpler to pick a new name).

## If IRSA Roles Already Exist
```pwsh
terraform apply `
  -var="create_irsa_roles=false" `
  -var="product_irsa_role_arn=arn:aws:iam::<acct>:role/introspect-product-service-irsa" `
  -var="order_irsa_role_arn=arn:aws:iam::<acct>:role/introspect-order-service-irsa"
```

## Control-Plane Logs With Existing Log Group
If `/aws/eks/<name>/cluster` already exists:
```hcl
create_cloudwatch_log_group = false
cloudwatch_log_group_name   = "/aws/eks/<name>/cluster"
cluster_enabled_log_types   = ["api","audit","authenticator"]
```
Ensure the log group exists or import it before enabling log types.

## After Terraform Apply
1) Update kubeconfig for the new cluster:
```pwsh
aws eks update-kubeconfig --name <cluster_name> --region <region>
```
2) Log in to ECR and push images:
```pwsh
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <acct>.dkr.ecr.<region>.amazonaws.com
# build & push your images to product-service and order-service repos
```
3) Apply Kubernetes manifests:
```pwsh
kubectl apply -k ../k8s/base
kustomize build ../k8s/aws --load-restrictor=LoadRestrictionsNone | kubectl apply -f -
```

### Pub/Sub resources
Because the Dapr component sets `disableEntityManagement: "true"`, the SNS topic + SQS queue must exist.
Terraform will create them by default (names: `product-events` and `order-service`).
If you already created them manually, set `create_pubsub_infra=false` to avoid name conflicts.

## Cleanup
```pwsh
terraform destroy
```

## Notes
- Secrets encryption via KMS is disabled (`create_kms_key=false`). Enable only if you have KMS permissions and want EKS secrets encryption.
- Defaults assume a new account with no conflicting names. If name collisions occur, change `cluster_name` or IRSA role names/ARNs accordingly.
