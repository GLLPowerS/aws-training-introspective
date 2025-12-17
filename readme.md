## Run terraform
$env:AWS_PROFILE="org-demo"

cd terraform

terraform init

terraform apply "-target=module.vpc" "-target=module.eks" -auto-approve
terraform apply -auto-approve

## Install dapr
aws eks update-kubeconfig --name cl-01 --region us-east-1
kubectl get nodes
helm upgrade --install dapr dapr/dapr 

## Install kubernetes services
cd ..
kubectl kustomize k8s/aws --load-restrictor=LoadRestrictionsNone | kubectl apply -f -

## Ship pod logs to CloudWatch (Fluent Bit)
# Creates a DaemonSet in kube-system that tails /var/log/containers and ships to:
#   /aws/containerinsights/cl-01/application
kubectl apply -k k8s/aws-logging

# Verify it’s running
kubectl -n kube-system get pods -l k8s-app=aws-for-fluent-bit

## Dapr tracing to AWS X-Ray
# Terraform creates IRSA role introspect-aws-otel-collector-irsa (attach AWSXRayDaemonWriteAccess)
kubectl apply -k k8s/aws-xray

# Verify collector is running
kubectl -n observability get deploy/aws-otel-collector

# Restart apps so the Dapr sidecars pick up updated tracing config
kubectl -n introspect rollout restart deploy/product-service deploy/order-service

### login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 139592182912.dkr.ecr.us-east-1.amazonaws.com

## Build and push dockers

docker build -t product-service:latest services/product-service
docker build -t order-service:latest services/order-service
docker tag product-service:latest 139592182912.dkr.ecr.us-east-1.amazonaws.com/product-service:latest
docker tag order-service:latest   139592182912.dkr.ecr.us-east-1.amazonaws.com/order-service:latest
docker push 139592182912.dkr.ecr.us-east-1.amazonaws.com/product-service:latest
docker push 139592182912.dkr.ecr.us-east-1.amazonaws.com/order-service:latest

### Proxy to port
kubectl -n introspect port-forward svc/product-service 8000:8000

### Restart services
kubectl -n introspect rollout restart deploy/product-service deploy/order-service

### View service logs
kubectl -n introspect logs deploy/order-service -c order-service --tail 100