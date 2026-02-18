# Architecture Overview

## Resource Map

```
Azure Subscription
└── rg-{project}-{environment}
    ├── kv-{project}-{environment}          Key Vault
    │   ├── secret: custom-connector-api-key
    │   ├── secret: storage-connection-string
    │   ├── secret: connector-client-id
    │   ├── secret: connector-client-secret
    │   └── secret: apim-subscription-key
    │
    ├── st{project}{environment}            Storage Account
    │   ├── container: uploads
    │   ├── container: processed
    │   └── container: archive
    │
    ├── func-{project}-{environment}        Function App (Consumption)
    │   └── SystemAssigned Managed Identity → Key Vault (Get, List)
    │
    ├── asp-{project}-{environment}         App Service Plan (Y1)
    ├── appi-{project}-{environment}        Application Insights
    │
    └── apim-{project}-{environment}        API Management (prod only)
        └── api: pp-connector-api

Microsoft Entra ID (Azure AD)
└── app-{project}-connector-{environment}  App Registration
    ├── API permission: Dataverse user_impersonation
    └── Service Principal
```

## Data Flow

```
Power Automate Flow
    │
    ▼
Custom Connector  ──────────────────────────────────────┐
    │                                                    │
    │ (via subscription key from Key Vault)              │
    ▼                                                    ▼
Azure API Management                         Azure Function App
    │                                              │
    │                                              │ (Managed Identity)
    ▼                                              ▼
Azure Function App                           Azure Key Vault
    │
    ▼
Dataverse / External API
```

## Environment Matrix

| Feature | dev | test | prod |
|---------|-----|------|------|
| Key Vault | ✅ standard | ✅ standard | ✅ standard |
| Storage | ✅ LRS | ✅ LRS | ✅ ZRS |
| Function App | ✅ | ✅ | ✅ |
| APIM | ❌ (cost saving) | ❌ | ✅ Standard_1 |
| App Registration | ✅ | ✅ | ✅ |
| Purge Protection | ❌ | ❌ | ✅ |
| Approval Gate | ❌ | ❌ | ✅ |

## Naming Convention

Following [Azure CAF naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

| Resource | Pattern | Example |
|----------|---------|---------|
| Resource Group | `rg-{project}-{env}` | `rg-myproj-dev` |
| Key Vault | `kv-{project}-{env}` | `kv-myproj-dev` |
| Storage Account | `st{project}{env}` | `stmyprojdev` |
| Function App | `func-{project}-{env}` | `func-myproj-dev` |
| App Service Plan | `asp-{project}-{env}` | `asp-myproj-dev` |
| App Insights | `appi-{project}-{env}` | `appi-myproj-dev` |
| API Management | `apim-{project}-{env}` | `apim-myproj-prod` |
