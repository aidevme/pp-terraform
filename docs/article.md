---
title: "Terraform for Power Platform Developers: Provision Azure Resources & Automate CI/CD"
description: "Learn how to use Terraform to provision Azure Key Vault, Storage, Function Apps, API Management, and App Registrations for Microsoft Power Platform — with full GitHub Actions and Azure DevOps pipeline integration."
slug: terraform-azure-power-platform-developers
date: 2025-02-18
author: Zsolt Zombik
tags:
  - Terraform
  - Power Platform
  - Azure
  - Infrastructure as Code
  - GitHub Actions
  - Azure DevOps
  - Power Automate
  - Custom Connectors
  - DevOps
  - ALM
canonical_url: https://aidevme.com/terraform-azure-power-platform-developers
---

# Terraform for Power Platform Developers: Provision Azure Resources & Automate CI/CD

> **TL;DR:** This guide shows Power Platform developers how to use Terraform to provision and manage Azure resources — Key Vault, Storage, Function Apps, API Management, and App Registrations — and integrate the full infrastructure lifecycle into GitHub Actions and Azure DevOps pipelines. All code samples are production-ready and environment-parameterized.

If you've been building solutions on Microsoft Power Platform, you know that the app itself is only part of the story. Behind every enterprise-grade Power Apps solution sits a collection of Azure resources — Dataverse environments, Key Vaults, storage accounts, API connections, App Registrations, and more. Managing these manually through the Azure Portal doesn't scale. It leads to configuration drift, undocumented changes, and painful environment promotion processes.

This is where **Terraform** comes in — specifically the [AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) and [AzureAD](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs) providers that let you define your entire Azure infrastructure as code (IaC). In this article, I'll walk you through the essential Terraform patterns for Power Platform developers, from provisioning core Azure services to automating deployments through both GitHub Actions and Azure DevOps pipelines.

**What you'll learn:**
- Why Terraform is a natural fit for Power Platform ALM
- 5 practical provisioning scenarios for Power Platform developers
- How to integrate Terraform into GitHub Actions workflows
- How to integrate Terraform into Azure DevOps multi-stage pipelines
- Best practices, naming conventions, and security patterns

---

## Table of Contents

1. [🏢 For Decision Makers: Why Your Organisation Needs This](#decision-makers)
2. [Why Terraform for Power Platform Developers?](#why-terraform)
3. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Provider Setup](#provider-setup)
5. [Scenario 1 — Azure Key Vault for Custom Connector Secrets](#scenario-1)
6. [Scenario 2 — Azure Storage for Power Automate File Handling](#scenario-2)
7. [Scenario 3 — Azure Function App as Custom Connector Backend](#scenario-3)
8. [Scenario 4 — App Registration for Dataverse Authentication](#scenario-4)
9. [Scenario 5 — Azure API Management for Secure Custom Connectors](#scenario-5)
10. [GitHub Actions Integration](#github-actions)
11. [Azure DevOps Pipeline Integration](#azure-devops)
12. [Best Practices](#best-practices)
13. [FAQ](#faq)
14. [Official References](#references)

---

## 🏢 For Decision Makers: Why Your Organisation Needs This {#decision-makers}

> *Not a developer? This section is written specifically for IT managers, enterprise architects, CIOs, and Power Platform sponsors evaluating whether to invest in Terraform-based infrastructure automation for their teams.*

### The Business Problem This Solves

Most organisations using Microsoft Power Platform start small — a few apps, a handful of flows, maybe a custom connector or two. Then adoption grows. Suddenly you have dozens of solutions, multiple environments (dev, test, production, plus UAT for every project), and a growing list of Azure resources that someone created manually in the portal three years ago. Nobody is quite sure what they do, whether they're still needed, or whether they're configured securely.

This is known as **infrastructure drift** — and it is one of the most common reasons enterprise Power Platform projects slow down, fail audits, or suffer unexpected outages. It is also entirely preventable.

**Terraform solves infrastructure drift** by treating your Azure environment the same way your developers treat application code: every resource is defined in a file, every change is reviewed before it is applied, and the complete history of every decision lives in your version control system.

---

### The Real Cost of Manual Infrastructure Management

Before committing to Terraform, decision makers often ask: *"Our team manages this manually today — how bad can it really be?"* The answer depends on scale, but the patterns are consistent across organisations:

| Pain Point | Manual Approach | Terraform Approach |
|---|---|---|
| New environment setup | 2–5 days of portal clicks, tickets, and waiting | 15–30 minutes, fully automated |
| Environment consistency | "It works in dev" problems are routine | Identical configuration guaranteed |
| Security audit trail | Screenshot-based, incomplete | Full Git history, every change attributed |
| Secret rotation | Manual, often deferred, risky | Automated, version-controlled, safe |
| Cost of idle environments | Always-on, always-billing | Destroy on Friday, recreate on Monday |
| Onboarding a new developer | Days of access requests and tribal knowledge | Clone the repo, run one command |
| Disaster recovery | Weeks to rebuild from memory | Hours to rebuild from code |

For a team running three Power Platform environments across five active projects, the time savings alone typically justify the initial investment within the first quarter.

---

### Strategic Benefits for the Organisation

**Governance and Compliance**

In regulated industries — banking, insurance, healthcare, public sector — infrastructure auditability is not optional. Terraform gives your compliance team a complete, timestamped record of every change to every Azure resource, who approved it, and when it was applied. This is far stronger evidence for an auditor than a collection of Azure Activity Log screenshots.

For organisations following [Microsoft's Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/overview), Terraform is the recommended approach for implementing the [Azure Landing Zone](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) patterns that underpin enterprise governance.

**Security Posture**

Manual infrastructure management is a security risk. Developers with portal access create resources with overly permissive settings because it is faster. Secrets end up hardcoded in flow definitions or shared in emails. Access policies drift over time.

Terraform enforces a **"policy as code"** model: security requirements (TLS versions, public access disabled, soft-delete enabled, managed identities instead of stored credentials) are codified once and applied consistently to every environment. Tools like [Checkov](https://www.checkov.io/) can scan your Terraform code for misconfigurations before anything is deployed to Azure, acting as an automated security reviewer on every pull request.

**Cost Optimisation**

Azure costs money when resources run. Non-production Power Platform environments — development, testing, UAT — typically only need to be running during business hours. With Terraform integrated into a scheduled pipeline, you can destroy non-production infrastructure at the end of every working day and recreate it each morning in under 30 minutes, at a fraction of the cost of leaving it running continuously.

**Faster, More Reliable Delivery**

Teams using Infrastructure as Code consistently deliver new environments faster and with fewer incidents than teams managing infrastructure manually. The [DORA State of DevOps Report](https://dora.dev/research/) consistently shows that elite performing software organisations treat infrastructure as code as a foundational practice — not an optional extra.

For Power Platform specifically, this means: when a new project is approved, the Azure infrastructure it needs (Key Vault, storage, API Management, App Registration) can be provisioned and ready within the same sprint, not waiting weeks on a manual provisioning backlog.

---

### What Does Implementation Actually Require?

A common concern from decision makers is that Terraform requires specialist DevOps expertise that the team doesn't have. This is less true than it used to be, especially for Power Platform scenarios.

**What your team needs:**

- One developer or architect comfortable with Azure and willing to learn HCL (Terraform's configuration language) — typically a 1–2 week ramp-up for someone already familiar with Azure
- A Git repository (Azure DevOps or GitHub — your team almost certainly has one already)
- An Azure subscription with Contributor access for the service account running the pipelines
- The pipeline examples in this article as a starting point

**What you do NOT need:**

- A dedicated DevOps engineer or platform team
- Any new tooling licences (Terraform is open source, the Azure providers are free)
- Changes to your Power Platform licencing or environments
- Rewriting any existing Power Platform solutions

**Realistic timeline for a first implementation:**

| Phase | Duration | Output |
|---|---|---|
| Setup & learning | Week 1–2 | State storage, provider config, first resource deployed |
| Core scenarios | Week 3–4 | Key Vault, Storage, Function App provisioned via pipeline |
| CI/CD integration | Week 5–6 | GitHub Actions or Azure DevOps pipeline live for dev environment |
| Full multi-environment | Week 7–8 | Dev, test, prod pipelines with approval gates |

By the end of week 8, your team has repeatable, auditable, secure infrastructure automation for all Power Platform environments — and the knowledge to extend it to every future project.

---

### Questions to Ask Your Team

If you are evaluating whether to prioritise this work, these are the right questions to bring to your Power Platform architects and developers:

1. **"How long does it take to set up a new environment for a new project today?"** If the answer is more than two days, Terraform will save significant time.
2. **"If we lost our production Azure resources tomorrow, how long would it take to rebuild them?"** If nobody knows the answer confidently, that is a risk.
3. **"Can we prove to an auditor exactly who changed what in our Azure environment and when?"** If the answer relies on manual documentation, Terraform closes that gap.
4. **"Are our dev and test environments configured identically to production?"** If not, that is a source of bugs and incidents waiting to happen.
5. **"How much are we spending on Azure resources that only need to run during business hours?"** The answer is usually surprising.

---

### The Bottom Line

Adopting Terraform for your Power Platform Azure infrastructure is not a radical transformation — it is a targeted, incremental improvement that pays dividends from the first month. It makes your team faster, your environments more secure, your costs more predictable, and your organisation better prepared for audits and growth.

The technical implementation is covered in detail in the sections below. If you would like to discuss the business case further or need help building an internal proposal, the [Microsoft Power Platform adoption resources](https://learn.microsoft.com/en-us/power-platform/guidance/adoption/methodology) and [Azure Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/overview) are the best starting points for framing the conversation with stakeholders.

> 📘 **Official resource:** [DORA DevOps Research — Infrastructure as Code practices](https://dora.dev/research/)
> 📘 **Official resource:** [Microsoft Cloud Adoption Framework — Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
> 📘 **Official resource:** [Power Platform adoption maturity model](https://learn.microsoft.com/en-us/power-platform/guidance/adoption/maturity-model)

---

## 1. Why Terraform for Power Platform Developers? {#why-terraform}

[Microsoft Power Platform](https://learn.microsoft.com/en-us/power-platform/) — comprising Power Apps, Power Automate, Power BI, and Copilot Studio — relies heavily on Azure services as its backbone. Every real-world solution eventually needs:

- **[Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)** — for secrets used in custom connectors and cloud flows
- **[Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)** — for file handling, blob triggers, and data archival
- **[Azure SQL](https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview)** or **[Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/introduction)** — for virtual table connectors or Dataverse federation
- **[Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-overview)** — for custom connectors and webhook endpoints
- **[Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts)** — for securing and publishing APIs consumed by Power Apps
- **[App Registrations (Microsoft Entra ID)](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals)** — for authenticating custom connectors and Dataverse integrations

Without Infrastructure as Code, these resources are created manually, differ between environments, and are invisible to your version control history. [Terraform by HashiCorp](https://www.terraform.io/) solves this: define resources once in `.tf` files, apply them consistently across dev, test, and production, and integrate the whole process into your existing [Power Platform ALM pipeline](https://learn.microsoft.com/en-us/power-platform/alm/overview-alm).

**Key advantages of Terraform for Power Platform teams:**

- **Repeatability** — identical infrastructure across all environments, no more "works in dev, broken in prod"
- **Version control** — infrastructure changes reviewed in pull requests, just like application code
- **Auditability** — complete change history in Git
- **Collaboration** — remote state with locking prevents conflicts in multi-developer teams
- **Cost control** — destroy non-production environments when not in use and recreate them in minutes

> 📘 **Official resource:** [What is Infrastructure as Code? — Microsoft Learn](https://learn.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)

---

## 2. Prerequisites {#prerequisites}

Before you start, install and configure the following:

| Tool | Version | Link |
|------|---------|------|
| Terraform CLI | v1.5+ | [Install Terraform](https://developer.hashicorp.com/terraform/install) |
| Azure CLI | Latest | [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| Azure Subscription | Contributor role | [Azure free account](https://azure.microsoft.com/en-us/free/) |
| VS Code + Terraform extension | Latest | [HashiCorp Terraform for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform) |

Authenticate your local environment:

```bash
az login
az account set --subscription "<your-subscription-id>"

# Verify
az account show
```

> 📘 **Official resource:** [Authenticate Terraform to Azure — Microsoft Learn](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure)

---

## 3. Project Structure {#project-structure}

A clean, scalable Terraform project for Power Platform infrastructure looks like this:

```
terraform/
├── main.tf               # Core resource definitions
├── variables.tf          # Input variable declarations
├── outputs.tf            # Output values (connection strings, URIs)
├── providers.tf          # Provider configuration and backend
├── environments/
│   ├── backend-dev.hcl   # Dev backend configuration (state storage)
│   ├── backend-test.hcl  # Test backend configuration
│   ├── backend-prod.hcl  # Prod backend configuration
│   ├── dev.tfvars        # Dev-specific variable overrides
│   ├── test.tfvars       # Test-specific variable overrides
│   └── prod.tfvars       # Prod-specific variable overrides
├── modules/
│   ├── apim/             # API Management module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── app-registration/ # Azure AD App Registration module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── function-app/     # Function App module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── keyvault/         # Key Vault module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── storage/          # Storage Account module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── docs/
│   ├── pre-checklist.md  # Setup guide with all prerequisites
│   ├── architecture.md   # Architecture documentation
│   ├── runbook.md        # Operational runbook
│   └── article.md        # This guide
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml  # CI/CD pipeline
└── CONTRIBUTING.md       # Contributor guidelines with CLA info
```

This structure follows [Terraform's recommended module patterns](https://developer.hashicorp.com/terraform/language/modules/develop/structure) and aligns with [Microsoft's naming conventions for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming).

> 📘 **Repository Setup Guide:** For complete first-time setup instructions including service principal configuration, Azure AD permissions, and GitHub secrets, see [docs/pre-checklist.md](pre-checklist.md).

---

## 4. Provider Setup {#provider-setup}

```hcl
# providers.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }

  # Remote state in Azure Blob Storage — required for team environments
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate<unique-suffix>"
    container_name       = "tfstate"
    key                  = "powerplatform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuread" {}
```

**Variables file:**

```hcl
# variables.tf
variable "environment" {
  description = "Deployment environment (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "Short project name used for resource naming (max 8 chars)"
  type        = string
}

variable "tags" {
  description = "Resource tags applied to all resources"
  type        = map(string)
  default     = {}
}
```

**Environment-specific values:**

```hcl
# environments/dev.tfvars
environment  = "dev"
location     = "westeurope"
project_name = "myproj"

tags = {
  Environment = "Development"
  Project     = "MyProject"
  ManagedBy   = "Terraform"
  Owner       = "PowerPlatformTeam"
  CostCenter  = "IT-Dev"
}
```

> 📘 **Official resource:** [AzureRM Provider documentation — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
> 📘 **Official resource:** [AzureAD Provider documentation — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)

---

## 5. Scenario 1: Azure Key Vault for Custom Connector Secrets {#scenario-1}

**Use case:** Store API keys, client secrets, and connection strings used by Power Platform custom connectors and Power Automate cloud flows, so they are never hardcoded or exposed in flow definitions.

[Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview) is the recommended Microsoft solution for secrets management. Power Automate supports [Key Vault references natively](https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references) and custom connectors can retrieve secrets at runtime via HTTP calls authenticated with Managed Identity.

```hcl
# main.tf

data "azurerm_client_config" "current" {}

# Resource Group following Azure naming conventions
# https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "kv-${var.project_name}-${var.environment}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # Set to true for production compliance

  tags = var.tags
}

# Grant the deploying service principal access
resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Purge"
  ]
}

# Store a custom connector API key as a Key Vault secret
resource "azurerm_key_vault_secret" "connector_api_key" {
  name         = "custom-connector-api-key"
  value        = var.connector_api_key   # injected from pipeline secret variable
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.deployer]

  tags = var.tags
}
```

> 📘 **Official resource:** [azurerm_key_vault — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
> 📘 **Official resource:** [Use Key Vault references in Power Platform — Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/environmentvariables-azure-key-vault-secrets)

---

## 6. Scenario 2: Azure Storage Account for Power Automate File Handling {#scenario-2}

**Use case:** Power Automate flows processing documents, images, or CSV exports need a reliable, secure staging area. Azure Blob Storage integrates natively with the [Azure Blob Storage connector](https://learn.microsoft.com/en-us/connectors/azureblob/) in Power Automate.

```hcl
# Storage Account — naming: no hyphens, max 24 chars, lowercase
resource "azurerm_storage_account" "main" {
  name                     = "st${var.project_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = false  # Security: disable public blob access

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# Container for incoming Power Automate uploads
resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Container for processed documents
resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Automatically store connection string in Key Vault
# Power Automate can reference this secret instead of using a stored credential
resource "azurerm_key_vault_secret" "storage_connection_string" {
  name         = "storage-connection-string"
  value        = azurerm_storage_account.main.primary_connection_string
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.deployer]
}
```

> 📘 **Official resource:** [azurerm_storage_account — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
> 📘 **Official resource:** [Azure Blob Storage connector for Power Automate](https://learn.microsoft.com/en-us/connectors/azureblob/)
> 📘 **Official resource:** [Azure Storage security best practices](https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations)

---

## 7. Scenario 3: Azure Function App as Custom Connector Backend {#scenario-3}

**Use case:** Custom connectors in Power Platform often need server-side logic that can't live in Power Automate itself — complex transformations, external system calls, or code-heavy integrations. An Azure Function App with a System-Assigned [Managed Identity](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview) is the cleanest pattern: no credentials stored anywhere.

```hcl
# App Service Plan (Consumption/Serverless)
resource "azurerm_service_plan" "functions" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Windows"
  sku_name            = "Y1"   # Consumption plan — pay-per-execution

  tags = var.tags
}

# Application Insights for monitoring and diagnostics
resource "azurerm_application_insights" "main" {
  name                = "appi-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"

  tags = var.tags
}

# Windows Function App
resource "azurerm_windows_function_app" "main" {
  name                = "func-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.functions.id

  site_config {
    application_stack {
      dotnet_version              = "v8.0"
      use_dotnet_isolated_runtime = true
    }
    cors {
      # Only allow Power Platform origins
      allowed_origins = [
        "https://make.powerautomate.com",
        "https://*.powerapps.com",
        "https://make.powerapps.com"
      ]
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "FUNCTIONS_WORKER_RUNTIME"       = "dotnet-isolated"
    # Reference Key Vault URI — secrets resolved at runtime via Managed Identity
    "KeyVaultUri"                    = azurerm_key_vault.main.vault_uri
  }

  # System-Assigned Managed Identity — no credentials needed
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Grant Function App Managed Identity read access to Key Vault
resource "azurerm_key_vault_access_policy" "function_app" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_function_app.main.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}
```

> 📘 **Official resource:** [Create a custom connector from an Azure Function — Microsoft Learn](https://learn.microsoft.com/en-us/connectors/custom-connectors/create-custom-connector-from-function)
> 📘 **Official resource:** [azurerm_windows_function_app — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app)
> 📘 **Official resource:** [Managed identities for Azure Functions](https://learn.microsoft.com/en-us/azure/app-service/overview-managed-identity)

---

## 8. Scenario 4: App Registration for Dataverse Authentication {#scenario-4}

**Use case:** Custom connectors and external services that need to call [Microsoft Dataverse](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview) require an App Registration in Microsoft Entra ID. Managing App Registrations through Terraform ensures consistent permissions across environments and keeps the full credential lifecycle in source control.

```hcl
# App Registration in Microsoft Entra ID (formerly Azure AD)
resource "azuread_application" "custom_connector" {
  display_name = "app-${var.project_name}-connector-${var.environment}"

  api {
    requested_access_token_version = 2
  }

  # Dataverse / Common Data Service API permissions
  # Resource App ID: 00000007-0000-0000-c000-000000000000 = Dataverse
  required_resource_access {
    resource_app_id = "00000007-0000-0000-c000-000000000000"

    resource_access {
      id   = "78ce3f0f-a1ce-49c2-8cde-64b5c0896db4" # user_impersonation scope
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "custom_connector" {
  client_id = azuread_application.custom_connector.client_id
}

# Client secret — rotated by updating end_date and running terraform apply
resource "azuread_application_password" "custom_connector" {
  application_id = azuread_application.custom_connector.id
  display_name   = "terraform-managed-${var.environment}"
  end_date       = "2026-12-31T00:00:00Z"
}

# Persist client credentials securely in Key Vault
resource "azurerm_key_vault_secret" "connector_client_id" {
  name         = "connector-client-id"
  value        = azuread_application.custom_connector.client_id
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.deployer]
}

resource "azurerm_key_vault_secret" "connector_client_secret" {
  name         = "connector-client-secret"
  value        = azuread_application_password.custom_connector.value
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.deployer]
}
```

> 📘 **Official resource:** [azuread_application — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application)
> 📘 **Official resource:** [Register an app to connect to Dataverse — Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/walkthrough-register-app-azure-active-directory)
> 📘 **Official resource:** [Use OAuth 2.0 with Microsoft Dataverse — Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/authenticate-oauth)

---

## 9. Scenario 5: Azure API Management for Secure Custom Connectors {#scenario-5}

**Use case:** For enterprise-grade Power Platform solutions, exposing your backend APIs directly to custom connectors creates security and governance challenges. [Azure API Management (APIM)](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts) sits between your APIs and Power Platform, providing throttling, authentication, request/response transformation, and detailed analytics.

```hcl
resource "azurerm_api_management" "main" {
  name                = "apim-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = "Power Platform Team"
  publisher_email     = "powerplatform@yourorg.com"

  # Developer_1 for non-prod; Standard_1 for production
  sku_name = var.environment == "prod" ? "Standard_1" : "Developer_1"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# API definition — imports OpenAPI spec from your Function App
resource "azurerm_api_management_api" "connector_api" {
  name                  = "connector-api"
  resource_group_name   = azurerm_resource_group.main.name
  api_management_name   = azurerm_api_management.main.name
  revision              = "1"
  display_name          = "Power Platform Connector API"
  path                  = "connector"
  protocols             = ["https"]
  subscription_required = true

  import {
    content_format = "openapi+json-link"
    content_value  = "https://${azurerm_windows_function_app.main.default_hostname}/api/openapi.json"
  }
}

# APIM subscription key for Power Platform custom connector authentication
resource "azurerm_api_management_subscription" "connector" {
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.main.name
  display_name        = "Power Platform Connector Subscription"
  api_id              = azurerm_api_management_api.connector_api.id
  state               = "active"
}

# Store the subscription key in Key Vault for use in custom connector definition
resource "azurerm_key_vault_secret" "apim_subscription_key" {
  name         = "apim-subscription-key"
  value        = azurerm_api_management_subscription.connector.primary_key
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.deployer]
}
```

> 📘 **Official resource:** [azurerm_api_management — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management)
> 📘 **Official resource:** [Use Azure API Management with Power Platform — Microsoft Learn](https://learn.microsoft.com/en-us/azure/api-management/export-api-power-platform)
> 📘 **Official resource:** [Create a custom connector from an API definition](https://learn.microsoft.com/en-us/connectors/custom-connectors/define-openapi-definition)

---

## 10. Outputs Configuration

Expose key values for downstream pipeline stages and Power Platform configuration:

```hcl
# outputs.tf
output "key_vault_uri" {
  description = "Key Vault URI — use in Power Platform environment variables"
  value       = azurerm_key_vault.main.vault_uri
}

output "function_app_hostname" {
  description = "Function App hostname — base URL for custom connector definition"
  value       = azurerm_windows_function_app.main.default_hostname
}

output "apim_gateway_url" {
  description = "APIM Gateway URL — custom connector host URL"
  value       = azurerm_api_management.main.gateway_url
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.main.name
}

output "connector_client_id" {
  description = "App Registration client ID for Dataverse"
  value       = azuread_application.custom_connector.client_id
  sensitive   = true
}

output "apim_subscription_key" {
  description = "APIM subscription key for custom connector"
  value       = azurerm_api_management_subscription.connector.primary_key
  sensitive   = true
}
```

---

## 11. CI/CD Integration: GitHub Actions {#github-actions}

This workflow handles Terraform plan and apply for any environment with [OIDC (Workload Identity Federation)](https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation) authentication — no long-lived secrets stored in GitHub.

### Setting Up OIDC for GitHub Actions

Configure OIDC authentication between GitHub Actions and Azure using a service principal with federated credentials. This eliminates the need for storing long-lived secrets in GitHub.

**Key Setup Steps:**

1. **Create service principal** with federated credentials for GitHub repo
2. **Grant Azure roles**: `Contributor` (subscription level) and `Storage Blob Data Contributor` (state storage)
3. **Grant Azure AD role**: `Cloud Application Administrator` (directory level) for App Registration management
4. **Configure GitHub secrets**: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `CONNECTOR_API_KEY`
5. **Create GitHub Environments**: `dev`, `test`, `prod` with optional protection rules

> 📘 **Complete OIDC Setup Guide:** For detailed step-by-step instructions including exact Azure CLI commands and troubleshooting, see [docs/pre-checklist.md](pre-checklist.md) — Section 2 (Service Principal Setup) and Section 3 (Azure AD Permissions).

### Complete GitHub Actions Workflow

The workflow supports three modes via manual trigger: **plan-only** (review changes), **plan-and-apply** (deploy), and **destroy** (tear down infrastructure). It uses backend configuration files for cleaner organization.

```yaml
# .github/workflows/terraform-deploy.yml
name: Terraform — Deploy Azure Infrastructure

on:
  push:
    branches: [main]
    paths: ['terraform/**']
  pull_request:
    branches: [main]
    paths: ['terraform/**']
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'dev'
        type: choice
        options: [dev, test, prod]
      action:
        description: 'Terraform action'
        required: true
        default: 'plan-and-apply'
        type: choice
        options:
          - plan-only
          - plan-and-apply
          - destroy

permissions:
  id-token: write       # Required for OIDC
  contents: read
  pull-requests: write  # Post plan to PR

env:
  TF_VERSION: '1.7.5'
  WORKING_DIR: './terraform'

jobs:
  # ── Plan ─────────────────────────────────────────────────────────────────────
  terraform-plan:
    name: Plan — ${{ github.event.inputs.environment || 'dev' }}
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'dev' }}
    outputs:
      plan_exitcode: ${{ steps.plan.outputs.exitcode }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login via OIDC
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
          terraform_wrapper: false

      - name: Terraform Init
        working-directory: ${{ env.WORKING_DIR }}
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: "true"
          ARM_USE_CLI: "false"
        run: |
          terraform init \
            -backend-config="environments/backend-${{ github.event.inputs.environment || 'dev' }}.hcl"

      - name: Terraform Format Check
        working-directory: ${{ env.WORKING_DIR }}
        run: terraform fmt -check -recursive

      - name: Terraform Validate
        working-directory: ${{ env.WORKING_DIR }}
        run: terraform validate

      - name: Terraform Plan
        id: plan
        working-directory: ${{ env.WORKING_DIR }}
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: "true"
          ARM_USE_CLI: "false"
          TF_VAR_connector_api_key: ${{ secrets.CONNECTOR_API_KEY }}
        run: |
          terraform plan \
            -var-file="environments/${{ github.event.inputs.environment || 'dev' }}.tfvars" \
            -out=tfplan \
            -detailed-exitcode \
            -no-color 2>&1 | tee plan_output.txt
          echo "exitcode=${PIPESTATUS[0]}" >> $GITHUB_OUTPUT

      - name: Post Plan to PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('terraform/plan_output.txt', 'utf8');
            const truncated = plan.length > 60000
              ? plan.substring(0, 60000) + '\n...(truncated)'
              : plan;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🏗️ Terraform Plan — \`${{ github.event.inputs.environment || 'dev' }}\`\n\`\`\`hcl\n${truncated}\n\`\`\``
            });

      - name: Upload Terraform Plan
        uses: actions/upload-artifact@v4
        with:
          name: tfplan-${{ github.event.inputs.environment || 'dev' }}
          path: ${{ env.WORKING_DIR }}/tfplan
          retention-days: 5

  # ── Apply ─────────────────────────────────────────────────────────────────────
  terraform-apply:
    name: Apply — ${{ github.event.inputs.environment || 'dev' }}
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'dev' }}
    needs: terraform-plan
    if: |
      github.event_name != 'pull_request' &&
      (github.event.inputs.action == 'plan-and-apply' || 
       (github.event_name == 'push' && github.ref == 'refs/heads/main')) &&
      needs.terraform-plan.outputs.plan_exitcode == '2'

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login via OIDC
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
          terraform_wrapper: false

      - name: Download Plan Artifact
        uses: actions/download-artifact@v4
        with:
          name: tfplan-${{ github.event.inputs.environment || 'dev' }}
          path: ${{ env.WORKING_DIR }}

      - name: Terraform Init
        working-directory: ${{ env.WORKING_DIR }}
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: "true"
          ARM_USE_CLI: "false"
        run: |
          terraform init \
            -backend-config="environments/backend-${{ github.event.inputs.environment || 'dev' }}.hcl"

      - name: Terraform Apply
        working-directory: ${{ env.WORKING_DIR }}
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: "true"
          ARM_USE_CLI: "false"
        run: terraform apply -auto-approve tfplan

      - name: Export Terraform Outputs
        working-directory: ${{ env.WORKING_DIR }}
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: "true"
          ARM_USE_CLI: "false"
        run: |
          FUNC_HOSTNAME=$(terraform output -raw function_app_hostname 2>/dev/null || echo "")
          KV_URI=$(terraform output -raw key_vault_uri)
          echo "FUNCTION_APP_HOSTNAME=$FUNC_HOSTNAME" >> $GITHUB_ENV
          echo "KEY_VAULT_URI=$KV_URI" >> $GITHUB_ENV
          echo "### ✅ Terraform Apply Complete" >> $GITHUB_STEP_SUMMARY
          echo "| Output | Value |" >> $GITHUB_STEP_SUMMARY
          echo "|--------|-------|" >> $GITHUB_STEP_SUMMARY
          echo "| Key Vault URI | $KV_URI |" >> $GITHUB_STEP_SUMMARY
          echo "| Function App | $FUNC_HOSTNAME |" >> $GITHUB_STEP_SUMMARY

  # ── Destroy ───────────────────────────────────────────────────────────────────
  terraform-destroy:
    name: Destroy — ${{ github.event.inputs.environment || 'dev' }}
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'dev' }}
    needs: terraform-plan
    if: |
      github.event_name == 'workflow_dispatch' &&
      github.event.inputs.action == 'destroy'

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login via OIDC
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
          terraform_wrapper: false

      - name: Terraform Init
        working-directory: ${{ env.WORKING_DIR }}
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: "true"
          ARM_USE_CLI: "false"
        run: |
          terraform init \
            -backend-config="environments/backend-${{ github.event.inputs.environment || 'dev' }}.hcl"

      - name: Terraform Destroy
        working-directory: ${{ env.WORKING_DIR }}
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_USE_OIDC: "true"
          ARM_USE_CLI: "false"
          TF_VAR_connector_api_key: ${{ secrets.CONNECTOR_API_KEY }}
        run: |
          terraform destroy \
            -var-file="environments/${{ github.event.inputs.environment || 'dev' }}.tfvars" \
            -auto-approve

      - name: Destruction Summary
        run: |
          echo "### 🗑️ Terraform Destroy Complete" >> $GITHUB_STEP_SUMMARY
          echo "**Environment:** \`${{ github.event.inputs.environment }}\`" >> $GITHUB_STEP_SUMMARY
```

**Key Features:**

- **ARM Environment Variables**: Required for OIDC authentication in all Terraform operations (`ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_USE_OIDC`, `ARM_USE_CLI`)
- **Backend Configuration Files**: Uses `backend-{env}.hcl` files for cleaner, version-controlled backend config
- **Manual Trigger Options**: Three workflow modes (plan-only, plan-and-apply, destroy) via `workflow_dispatch`
- **Conditional Jobs**: Apply only runs when changes detected (exitcode 2), Destroy only runs when explicitly requested
- **Workflow Summaries**: Visual output summaries in GitHub Actions UI
- **Environment Protection**: Leverage GitHub Environments for approval gates on sensitive deployments

> 📘 **Official resource:** [Using OpenID Connect with Azure in GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure)
> 📘 **Official resource:** [hashicorp/setup-terraform GitHub Action](https://github.com/hashicorp/setup-terraform)
> 📘 **Repository resource:** [Complete setup checklist — docs/pre-checklist.md](pre-checklist.md)
> 📘 **Repository resource:** [Architecture documentation — docs/architecture.md](architecture.md)

---

## 12. CI/CD Integration: Azure DevOps Pipelines {#azure-devops}

For teams already using Azure DevOps for [Power Platform ALM](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tools), here's how to integrate Terraform into multi-stage pipelines with approval gates.

### Setup Checklist

1. Install the [Terraform extension for Azure DevOps](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks) from the Marketplace
2. Create an **Azure Resource Manager service connection** using [Workload Identity Federation](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops#create-an-azure-resource-manager-service-connection-using-workload-identity-federation)
3. Create **Variable Groups** in Library:
   - `terraform-common`: `TF_STATE_RG`, `TF_STATE_SA`, `TF_STATE_CONTAINER`
   - `terraform-dev`: `CONNECTOR_API_KEY`, environment-specific values
   - `terraform-prod`: Production-specific secrets, [linked to Azure Key Vault](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=classic#link-secrets-from-an-azure-key-vault)
4. Create **Azure DevOps Environments** with required approvers for `test` and `prod`

### Multi-Stage Azure DevOps Pipeline

```yaml
# azure-pipelines-terraform.yml
trigger:
  branches:
    include: [main]
  paths:
    include: ['terraform/**']

pr:
  branches:
    include: [main]
  paths:
    include: ['terraform/**']

parameters:
  - name: environment
    displayName: Target Environment
    type: string
    default: dev
    values: [dev, test, prod]

variables:
  - group: terraform-common
  - group: terraform-${{ parameters.environment }}
  - name: TF_VERSION
    value: '1.7.5'
  - name: WORKING_DIR
    value: '$(System.DefaultWorkingDirectory)/terraform'
  - name: ENVIRONMENT
    value: ${{ parameters.environment }}

stages:
  # ── Stage 1: Validate ─────────────────────────────────────────────
  - stage: Validate
    displayName: Validate Terraform
    jobs:
      - job: ValidateJob
        displayName: Terraform Validate
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: TerraformInstaller@1
            displayName: Install Terraform $(TF_VERSION)
            inputs:
              terraformVersion: $(TF_VERSION)

          - task: TerraformTaskV4@4
            displayName: Terraform Init
            inputs:
              provider: 'azurerm'
              command: 'init'
              workingDirectory: $(WORKING_DIR)
              backendServiceArm: 'AzureServiceConnection'
              backendAzureRmResourceGroupName: $(TF_STATE_RG)
              backendAzureRmStorageAccountName: $(TF_STATE_SA)
              backendAzureRmContainerName: $(TF_STATE_CONTAINER)
              backendAzureRmKey: '$(ENVIRONMENT).tfstate'

          - task: TerraformTaskV4@4
            displayName: Terraform Validate
            inputs:
              provider: 'azurerm'
              command: 'validate'
              workingDirectory: $(WORKING_DIR)

          - bash: terraform fmt -check -recursive
            displayName: Terraform Format Check
            workingDirectory: $(WORKING_DIR)

  # ── Stage 2: Plan ─────────────────────────────────────────────────
  - stage: Plan
    displayName: 'Plan: $(ENVIRONMENT)'
    dependsOn: Validate
    jobs:
      - job: PlanJob
        displayName: Terraform Plan
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: TerraformInstaller@1
            inputs:
              terraformVersion: $(TF_VERSION)

          - task: TerraformTaskV4@4
            displayName: Terraform Init
            inputs:
              provider: 'azurerm'
              command: 'init'
              workingDirectory: $(WORKING_DIR)
              backendServiceArm: 'AzureServiceConnection'
              backendAzureRmResourceGroupName: $(TF_STATE_RG)
              backendAzureRmStorageAccountName: $(TF_STATE_SA)
              backendAzureRmContainerName: $(TF_STATE_CONTAINER)
              backendAzureRmKey: '$(ENVIRONMENT).tfstate'

          - task: TerraformTaskV4@4
            displayName: Terraform Plan
            inputs:
              provider: 'azurerm'
              command: 'plan'
              workingDirectory: $(WORKING_DIR)
              commandOptions: >
                -var-file="environments/$(ENVIRONMENT).tfvars"
                -var="connector_api_key=$(CONNECTOR_API_KEY)"
                -out=$(Pipeline.Workspace)/tfplan
                -detailed-exitcode
              environmentServiceNameAzureRM: 'AzureServiceConnection'

          - task: PublishPipelineArtifact@1
            displayName: Publish Terraform Plan
            inputs:
              targetPath: '$(Pipeline.Workspace)/tfplan'
              artifact: 'tfplan-$(ENVIRONMENT)'

  # ── Stage 3: Apply ────────────────────────────────────────────────
  - stage: Apply
    displayName: 'Apply: $(ENVIRONMENT)'
    dependsOn: Plan
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: ApplyJob
        displayName: Apply Infrastructure
        pool:
          vmImage: 'ubuntu-latest'
        environment: $(ENVIRONMENT)   # 🔒 Requires manual approval for test/prod
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self

                - task: TerraformInstaller@1
                  inputs:
                    terraformVersion: $(TF_VERSION)

                - task: DownloadPipelineArtifact@2
                  displayName: Download Terraform Plan
                  inputs:
                    artifactName: 'tfplan-$(ENVIRONMENT)'
                    targetPath: '$(WORKING_DIR)'

                - task: TerraformTaskV4@4
                  displayName: Terraform Init
                  inputs:
                    provider: 'azurerm'
                    command: 'init'
                    workingDirectory: $(WORKING_DIR)
                    backendServiceArm: 'AzureServiceConnection'
                    backendAzureRmResourceGroupName: $(TF_STATE_RG)
                    backendAzureRmStorageAccountName: $(TF_STATE_SA)
                    backendAzureRmContainerName: $(TF_STATE_CONTAINER)
                    backendAzureRmKey: '$(ENVIRONMENT).tfstate'

                - task: TerraformTaskV4@4
                  displayName: Terraform Apply
                  inputs:
                    provider: 'azurerm'
                    command: 'apply'
                    workingDirectory: $(WORKING_DIR)
                    commandOptions: '-auto-approve tfplan'
                    environmentServiceNameAzureRM: 'AzureServiceConnection'

                - bash: |
                    cd $(WORKING_DIR)
                    FUNC_URL=$(terraform output -raw function_app_hostname)
                    KV_URI=$(terraform output -raw key_vault_uri)
                    APIM_URL=$(terraform output -raw apim_gateway_url)
                    echo "##vso[task.setvariable variable=FunctionAppUrl;isOutput=true]https://$FUNC_URL"
                    echo "##vso[task.setvariable variable=KeyVaultUri;isOutput=true]$KV_URI"
                    echo "##vso[task.setvariable variable=ApimGatewayUrl;isOutput=true]$APIM_URL"
                  displayName: Export Terraform Outputs
                  name: TerraformOutputs

  # ── Stage 4: Deploy Power Platform Solution ───────────────────────
  - stage: DeployPowerPlatform
    displayName: 'Deploy PP Solution: $(ENVIRONMENT)'
    dependsOn: Apply
    variables:
      FunctionAppUrl: $[ stageDependencies.Apply.ApplyJob.outputs['ApplyJob.TerraformOutputs.FunctionAppUrl'] ]
      KeyVaultUri: $[ stageDependencies.Apply.ApplyJob.outputs['ApplyJob.TerraformOutputs.KeyVaultUri'] ]
    jobs:
      - job: DeployJob
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: PowerPlatformToolInstaller@2
            displayName: Install Power Platform Tools
            inputs:
              DefaultVersion: true

          - task: PowerPlatformImportSolution@2
            displayName: Import Power Platform Solution
            inputs:
              authenticationType: 'PowerPlatformSPN'
              PowerPlatformSPN: 'PowerPlatformServiceConnection'
              Environment: $(PP_ENVIRONMENT_URL)
              SolutionInputFile: '$(Pipeline.Workspace)/MySolution.zip'
              AsyncOperation: true
              MaxAsyncWaitTime: 60
```

> 📘 **Official resource:** [Power Platform Build Tools for Azure DevOps](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tools)
> 📘 **Official resource:** [Terraform extension for Azure DevOps — Marketplace](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
> 📘 **Official resource:** [Azure DevOps Environments with approvals and checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)

---

## 13. Best Practices for Power Platform Teams {#best-practices}

**Use remote state with locking.** Always store your Terraform state in [Azure Blob Storage](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm) with state locking. This prevents two pipeline runs from corrupting state simultaneously — critical in multi-developer teams working across feature branches.

**Separate infrastructure and app deployment pipelines.** Your Terraform pipeline should run infrequently (when infrastructure changes). Your Power Platform solution deployment pipeline runs on every commit. Wire them together through pipeline artifacts or [Azure DevOps variable groups](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups).

**Use Managed Identities wherever possible.** Assign [System-Assigned Managed Identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview) to Function Apps and grant them Key Vault access. Your Power Automate flows can reference secrets by name without ever touching a plaintext credential.

**Tag every resource.** The `tags` pattern shown above makes cost management and auditing significantly easier. Add at minimum: `Environment`, `Project`, `ManagedBy = "Terraform"`, and `Owner`. Follow [Microsoft's tagging strategy recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging).

**Follow Azure naming conventions.** Use the [Cloud Adoption Framework naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) for all resources. The abbreviation prefixes used in this article (`rg-`, `kv-`, `func-`, `apim-`) are aligned with Microsoft's official abbreviation list.

**Pin provider versions.** Always use `~>` style version constraints (`~> 3.90`) rather than `>=`. The `azurerm` v3→v4 upgrade contained breaking changes that destroyed and recreated resources unexpectedly for teams that hadn't pinned versions.

**Use `terraform workspace` sparingly.** For Power Platform scenarios with distinct dev/test/prod environments, environment-specific `.tfvars` files combined with separate backend state keys are cleaner and more auditable than Terraform workspaces.

**Validate before every merge.** Run `terraform validate` and `terraform fmt -check` as PR gates. Consider adding [TFLint](https://github.com/terraform-linters/tflint) and [Checkov](https://www.checkov.io/) for security scanning of your Terraform code.

**Contributing to this repository.** This article and its companion infrastructure code are open source. If you find improvements, bugs, or have questions, contributions are welcome! Before submitting code changes, all contributors must sign a Contributor License Agreement (CLA) — see [CONTRIBUTING.md](../CONTRIBUTING.md) for details on the process, coding standards, and commit guidelines.

---

## 14. Frequently Asked Questions {#faq}

### ❓ Can Terraform manage Power Platform environments directly?

Not through the native AzureRM/AzureAD providers. However, there is a community-maintained [Power Platform Terraform provider](https://registry.terraform.io/providers/microsoft/power-platform/latest/docs) developed by Microsoft that supports managing Power Platform environments, Dataverse tables, and some maker settings. For most teams, the recommended pattern is to use Terraform for Azure infrastructure and the [Power Platform Build Tools](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tools) (Azure DevOps) or [Power Platform Actions](https://github.com/microsoft/powerplatform-actions) (GitHub) for solution deployment.

### ❓ How do I store Terraform secrets securely in pipelines?

Never put secrets in `.tfvars` files committed to source control. Instead, use:
- **GitHub Actions**: GitHub Environment secrets or [Azure Key Vault–referenced values via the Azure CLI](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=classic#link-secrets-from-an-azure-key-vault)
- **Azure DevOps**: Variable groups [linked directly to Azure Key Vault](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=classic#link-secrets-from-an-azure-key-vault)
- **Local development**: `ARM_CLIENT_SECRET` as a shell environment variable, never in files

Pass secrets to Terraform using `-var="secret=$(SECRET_VAR)"` in the plan/apply commands so they never touch the filesystem.

### ❓ What's the difference between Terraform workspaces and separate .tfvars files for environments?

[Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) share the same backend storage account and configuration, differentiating only by a workspace name prefix in the state key. Environment-specific `.tfvars` files with separate backend state keys (`dev.tfstate`, `prod.tfstate`) give you completely isolated state files and make it easier to apply environment-specific configuration differences. For Power Platform teams with distinct dev/test/prod pipelines, the `.tfvars` approach is generally easier to audit and debug.

### ❓ Should I use `azurerm` v3 or v4?

As of early 2025, `azurerm` v4 is stable and recommended for new projects. It requires explicit resource group handling changes and some property renames. If you're upgrading from v3, read the [official upgrade guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide) carefully — some resources (like `azurerm_api_management`) had breaking argument changes. For existing projects, stay on `~> 3.x` until you have time to test the migration thoroughly.

### ❓ How do I prevent Terraform from destroying production resources accidentally?

Several layers of protection: First, use `prevent_destroy = true` in the `lifecycle` block for critical resources like your Key Vault and Dataverse-connected storage accounts. Second, configure your `prod` Azure DevOps Environment or GitHub Environment to require manual approval before apply. Third, use [Azure resource locks](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources) (`azurerm_management_lock`) for truly critical resources, which block deletion even by pipeline service principals.

```hcl
resource "azurerm_key_vault" "main" {
  # ...
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_management_lock" "keyvault_lock" {
  name       = "kv-delete-lock"
  scope      = azurerm_key_vault.main.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform — do not remove without team approval"
}
```

### ❓ Can Terraform create the Azure Storage Account used for its own remote state?

Not directly with the same configuration — it's a chicken-and-egg problem. The recommended approach is to create the state storage account once with a short bootstrap script or manually, then use it as the backend for all subsequent Terraform runs. Microsoft provides a [bootstrap script example for this pattern](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage).

### ❓ How do I handle Terraform state when multiple Power Platform developers work in parallel?

Azure Blob Storage backend with [state locking](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#state-locking) handles parallel access automatically — only one Terraform operation can hold the state lock at a time. For feature branch development, consider using separate state keys per developer (`dev-zombik.tfstate`, `dev-teammate.tfstate`) or per feature, and merging infrastructure changes through pull requests just like application code.

### ❓ What Terraform resources do I need for a Dataverse virtual table connector to Azure SQL?

A Dataverse virtual table using Azure SQL as the data source requires: an `azurerm_mssql_server`, `azurerm_mssql_database`, an `azurerm_mssql_firewall_rule` allowing Azure services, and an `azuread_application` with appropriate SQL permissions. You'll then configure the [virtual connector](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/create-virtual-tables-using-connectors) through the Power Platform admin center, referencing the connection string from Key Vault.

### ❓ Is there a linting or security scanning tool for Terraform code?

Yes — the two most popular options are [TFLint](https://github.com/terraform-linters/tflint) (catches provider-specific errors and deprecated syntax) and [Checkov](https://www.checkov.io/) (security and compliance scanning for Terraform). Both integrate easily into GitHub Actions and Azure DevOps. Checkov in particular has excellent coverage for Azure security misconfigurations like public blob access, missing TLS enforcement, and soft-delete settings on Key Vaults.

---

## 15. Official References & Resources {#references}

### Terraform & HashiCorp
- [Terraform Documentation — HashiCorp](https://developer.hashicorp.com/terraform/docs)
- [AzureRM Provider — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AzureAD Provider — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
- [Power Platform Provider (Preview) — Terraform Registry](https://registry.terraform.io/providers/microsoft/power-platform/latest/docs)
- [Terraform Backend: Azure Blob Storage](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
- [AzureRM v4 Upgrade Guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide)

### Microsoft Power Platform
- [Power Platform ALM Overview — Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/alm/overview-alm)
- [Power Platform Build Tools for Azure DevOps](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tools)
- [GitHub Actions for Power Platform](https://github.com/microsoft/powerplatform-actions)
- [Custom Connectors Overview — Microsoft Learn](https://learn.microsoft.com/en-us/connectors/custom-connectors/)
- [Environment Variables in Power Platform](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/environmentvariables)
- [Key Vault Secrets as Environment Variables](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/environmentvariables-azure-key-vault-secrets)

### Azure Services
- [Azure Key Vault Overview](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
- [Azure Blob Storage Introduction](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)
- [Azure Functions Overview](https://learn.microsoft.com/en-us/azure/azure-functions/functions-overview)
- [Azure API Management Overview](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts)
- [Managed Identities for Azure Resources](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview)
- [Azure Resource Naming Conventions (CAF)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Resource Tagging Strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)

### Microsoft Dataverse & Entra ID
- [Microsoft Dataverse Web API Overview](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview)
- [Register an App for Dataverse](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/walkthrough-register-app-azure-active-directory)
- [OAuth 2.0 with Dataverse](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/authenticate-oauth)
- [App Objects and Service Principals — Entra ID](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals)

### CI/CD & DevOps
- [Store Terraform State in Azure Storage — Microsoft Learn](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)
- [Authenticate Terraform to Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure)
- [OIDC for GitHub Actions with Azure](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Workload Identity Federation — Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops#create-an-azure-resource-manager-service-connection-using-workload-identity-federation)
- [Azure DevOps Environments with Approvals](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops)
- [Terraform Task extension — Azure DevOps Marketplace](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)

### Security & Compliance
- [Azure Storage Security Best Practices](https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations)
- [Azure Key Vault Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [TFLint — Terraform Linter](https://github.com/terraform-linters/tflint)
- [Checkov — Infrastructure Security Scanner](https://www.checkov.io/)

---

## About This Repository

This article is part of the **pp-terraform** open-source project — production-ready Terraform infrastructure for Power Platform solutions.

**📦 GitHub Repository:** [aidevme/pp-terraform](https://github.com/aidevme/pp-terraform)

**📚 Additional Documentation:**
- [Pre-Deployment Checklist](pre-checklist.md) — Complete setup guide including service principal, OIDC, and GitHub configuration
- [Architecture Documentation](architecture.md) — Infrastructure architecture, module dependencies, Mermaid diagrams, and CI/CD flows
- [Runbook](runbook.md) — Operational procedures for maintenance and troubleshooting
- [Contributing Guide](../CONTRIBUTING.md) — Contribution guidelines, coding standards, and CLA information

**🚀 Repository Features:**
- ✅ Production-tested Terraform modules (Key Vault, Storage, Function App, APIM, App Registration)
- ✅ GitHub Actions workflow with OIDC authentication, manual triggers, and destroy capability
- ✅ Environment-specific configurations (dev/test/prod) with separate state management
- ✅ Comprehensive documentation and issue templates
- ✅ MIT License — free to use and adapt for your organization

**🤝 Contributing:**
Contributions welcome! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines. All contributors must sign a CLA before code contributions can be merged.

---

*Published on [aidevme.com](https://aidevme.com) | Written by Zsolt Zombik | Power Platform & Azure Architecture*

*Found this useful? ⭐ Star the [GitHub repository](https://github.com/aidevme/pp-terraform) and share it with your Power Platform team. Questions or improvements? Open an issue or submit a PR!*