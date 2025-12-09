# Case Study 3: U.S. Healthcare Provider Modernizes Scheduling System

## About Customer

A large U.S.-based healthcare provider managing a network of **200+ hospitals and outpatient centers**.  
The legacy monolithic scheduling system frequently failed during peak seasons like flu outbreaks, affecting both **patient care** and **staff efficiency**.

## Customer Requirement

- **Real-time appointment scheduling** with adaptive slotting, cancellation handling, and role-based access control.
- **Transition from on-premises to AWS** while ensuring **HIPAA** and **HITRUST** compliance.
- Support **event-driven interactions** for instant status updates and backend decoupling.

## Additional Comments

- Must support **multi-channel access**: mobile app, web portal, IVR/voice assistants.
- Prioritize **fault isolation** to prevent cascading failures across modules.

## GenAI Assistance

- Analyze **historical logs** and **patient flow telemetry** to recommend scaling windows and bottleneck modules.
- Simulate **autoscaling policies** under variable loads and validate regional failover readiness.
- Assist in refining **notification cadence rules** based on cancellation/rebooking trends.

## Expected Output

- **Microservices** for Booking, Doctor Availability, Notifications, Waitlist handling, and more.
- **Amazon EventBridge** and **AWS Lambda** for event-based workflows  
    _(e.g., appointment confirmed → notification triggered)_.
- **Amazon API Gateway** for secure exposure to external health apps and internal portals.
- _(Optional)_ Sample **GitHub Actions CI/CD pipeline** deploying to:
    - **Amazon EKS** (core services)
    - **AWS App Runner / AWS Fargate** (edge services)

## Future Vision

- Leverage **GenAI** to perform version drift analysis, uncover regional inefficiencies, and recommend workflow optimizations based on **patient throughput metrics**.

## Deliverables

The deliverable document should include the below sections but **NOT limited only to them**:

- **Executive Summary**
- **Current Challenges**
- **Goals & Success Criteria**
- **Domain Model / Service Map**
- **DevOps Strategy**
- **Observability Plan**
- **Future Enhancements**
- **Appendix / Any other supporting artifacts**