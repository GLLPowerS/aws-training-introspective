Apply these base manifests first:
- namespace.yaml
- serviceaccounts.yaml (wire IRSA later)

Components applied cluster-wide but namespace-scoped (e.g., Dapr components in namespace introspect).
