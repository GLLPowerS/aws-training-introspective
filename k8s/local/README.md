Local Kubernetes deploy (Docker Desktop + Dapr):

Prereqs:
- kubectl points to Docker Desktop
- Dapr CLI installed
- Helm installed

Steps:
1) Install Dapr to the cluster:
   dapr init -k

2) Create namespace and service accounts:
   kubectl apply -f ../base/namespace.yaml
   kubectl apply -f ../base/serviceaccounts.yaml

3) Install Redis (no auth) into the same namespace:
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm upgrade --install redis bitnami/redis \
     --set auth.enabled=false \
     --namespace introspect \
     --create-namespace

4) Build images (Docker Desktop shares the daemon with k8s, so no push needed):
   cd ../../services/product-service; docker build -t product-service:local .
   cd ../../services/order-service; docker build -t order-service:local .

5) Apply app manifests and Dapr component:
   kubectl apply -f product-service.yaml
   kubectl apply -f order-service.yaml
   kubectl apply -f ../../dapr/components/redis-pubsub.yaml

6) Test publish -> subscribe:
   # port-forward product-service
   kubectl -n introspect port-forward deploy/product-service 8001:8000
   curl -X POST http://localhost:3500/v1.0/publish/redis-pubsub/product-events \
     -H "Content-Type: application/json" \
     -d '{"id":123,"name":"Widget"}'
   # or call app directly if port-forwarded: http://localhost:8001/products

Logs:
- App:   kubectl -n introspect logs deploy/product-service -c product-service
- Dapr:  kubectl -n introspect logs deploy/product-service -c daprd
