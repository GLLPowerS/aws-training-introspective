
## Create cluster
eksctl create cluster -f cluster-config.yaml

## Add access
$callerArn = aws sts get-caller-identity --query 'Arn' --output text
eksctl create iamidentitymapping `
   --cluster cl-02 `
   --arn $callerArn `
   --username admin `
   --group system:masters

## Get security groups
aws ec2 describe-security-groups --region us-east-1 --query 'SecurityGroups[*].[GroupId,GroupName,VpcId]' --output table

## Update the security group rule to allow the EKS cluster to communicate with the Dapr Sidecar
aws ec2 authorize-security-group-ingress `
  --region us-east-1 `
  --group-id sg-0fdfbd6104abd3a02 `
  --protocol tcp `
  --port 4000 `
  --source-group sg-0fdfbd6104abd3a02

## Add a default storage class
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

## Install dapr
dapr init -k



@'
apiVersion: v1
kind: Pod
metadata:
  name: dapr-smoke
  namespace: introspect
  annotations:
    dapr.io/enabled: "true"
    dapr.io/app-id: "dapr-smoke"
    dapr.io/app-port: "80"
    dapr.io/app-protocol: "http"
spec:
  containers:
  - name: web
    image: nginx
    ports:
    - containerPort: 80
'@ | kubectl apply -f -


kubectl delete pod dapr-smoke -n introspect
@'
apiVersion: v1
kind: Pod
metadata:
  name: dapr-smoke
  namespace: introspect
  annotations:
    dapr.io/enabled: "true"
    dapr.io/app-id: "dapr-smoke"
    dapr.io/app-port: "80"
    dapr.io/app-protocol: "http"
spec:
  containers:
  - name: web
    image: nginx
    ports:
    - containerPort: 80
'@ | kubectl apply -f -

kubectl get pods -n dapr-system