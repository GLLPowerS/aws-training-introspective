## Run terraform
$env:AWS_PROFILE="org-demo"

cd terraform

terraform init

terraform apply `
   -var="cluster_name=cl-01" `
   -var="create_irsa_roles=true" `
   -var="add_current_caller_access=true" `
   -var=cluster_access_entries='[{
     principal_arn="arn:aws:sts::139592182912:federated-user/c04-vlabuser177@stackroute.in",
     policy_arns=[
       "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
       "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
       "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
     ]
   }]' "-target=module.vpc" "-target=module.eks" "-target=module.iam"


terraform apply `
   -var="cluster_name=cl-01" `
   -var="create_irsa_roles=true" `
   -var="add_current_caller_access=true" `
   -var=cluster_access_entries='[{
     principal_arn="arn:aws:sts::139592182912:federated-user/c04-vlabuser177@stackroute.in",
     policy_arns=[
       "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
       "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
       "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
     ]
   }]'


## Install dapr
aws eks update-kubeconfig --name cl-01 --region us-east-1
kubectl get nodes
helm upgrade --install dapr dapr/dapr 

## Install kubernetes services
cd ..
kubectl kustomize k8s/aws --load-restrictor=LoadRestrictionsNone | kubectl apply -f -

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