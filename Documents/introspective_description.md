# Introspect 1 B (Hands On)

**Individual Submission**  
**Due date – 17th Dec 2025**

***

## 1. Objective

Deploy a containerized microservice using **Amazon Elastic Kubernetes Service (EKS)** with **Dapr sidecars** to implement pub/sub messaging and observe real-time event-driven interactions between microservices running on Kubernetes.

***

## 2. Prerequisites

*   **AWS Account** with EKS, ECR, IAM, CloudWatch, and VPC permissions
*   **Docker** installed locally
*   **AWS CLI**, **kubectl**, and **eksctl** installed
*   **Helm 3+** installed
*   Languages/SDKs as per your choice (same as Azure doc):

| Language | Latest LTS Version (Public) | SDK / Runtime Link | IDE / Editor                  |
| -------- | --------------------------- | ------------------ | ----------------------------- |
| .NET     | 8.0 (LTS)                   | .NET SDK 8.0       | VS Code / Visual Studio 2022+ |
| Python   | 3.12                        | Python 3.12        | VS Code                       |
| Node.js  | 20.x (LTS)                  | Node.js 20         | VS Code                       |
| Java     | 17 (LTS)                    | OpenJDK 17         | VS Code / IntelliJ            |
| Go       | 1.22                        | Go 1.22            | VS Code                       |

***

## 3. Steps

*   Containerize the Microservice
*   Push the Image to Amazon ECR
*   Create or Use an Existing Amazon EKS Cluster
*   Install Dapr on the EKS Cluster
*   Deploy **ProductService** with Dapr Enabled
*   Deploy **OrderService** as a Subscriber
*   Configure Dapr Pub/Sub using AWS SNS or SQS
*   Monitor Logs and Interactions

***

## 4. GenAI-Assisted Tasks

Use **Amazon Bedrock models** (Claude, Amazon Titan) to:

*   Suggest missing telemetry points in your microservice
*   Recommend retry + resiliency patterns for event-driven architecture
*   Analyze your Dockerfile, Kubernetes manifests, and Dapr components
*   Recommend scaling patterns for SNS/SQS-based pub/sub on EKS

***

## 5. Learning Outcomes

After completing this Introspect, you will be able to:

*   Deploy and run microservices on **Amazon EKS**
*   Enable **Dapr sidecars** to handle service-to-service communication
*   Implement pub/sub workflows using **AWS SNS/SQS** as Dapr components
*   Observe distributed interactions through **Dapr logs + CloudWatch**
*   Understand how Kubernetes deployment objects work on AWS

***

## 6. Deliverables

*   Source Code Folder
*   Dockerfile
*   Container Image pushed to ECR
*   Kubernetes Deployment & Service YAML
*   Dapr Components Configuration (SNS/SQS pub/sub)
*   EKS Deployment Configuration (eksctl YAML if used)
*   Architecture Diagram
*   Screenshots and Logs (**ProductService → OrderService flow**)
*   `README.md`
*   Optional: Bedrock-generated insights

**Note:** The deliverables should be a repo in **GitHub**.