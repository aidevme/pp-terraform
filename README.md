# terraform-power-platform

![Terraform for Power Platform](assets/pp-terraform-social-preview.png)

> Infrastructure as Code for Microsoft Power Platform — Azure resources provisioned and managed with Terraform, deployed via GitHub Actions and Azure DevOps pipelines.

## What This Repo Provisions

| Module | Azure Resource | Purpose |
|--------|---------------|---------|
| `keyvault` | Azure Key Vault | Secrets for custom connectors & flows |
| `storage` | Azure Storage Account + Containers | File handling for Power Automate |
| `function-app` | Azure Function App (Consumption) | Custom connector backend |
| `apim` | Azure API Management | Secure API gateway for Power Apps |
| `app-registration` | Microsoft Entra ID App Registration | Dataverse authentication |

## Quick Start

```bash
# 1. Bootstrap state storage (first time only)
./scripts/bootstrap.sh

# 2. Initialise Terraform for dev
cd terraform
terraform init -backend-config=environments/backend-dev.hcl

# 3. Plan
terraform plan -var-file=environments/dev.tfvars

# 4. Apply
terraform apply -var-file=environments/dev.tfvars
```

## Repository Structure

```
.
├── .github/
│   ├── ISSUE_TEMPLATE/         # Issue templates (bug, feature, docs, infra)
│   │   ├── bug_report.yml
│   │   ├── config.yml
│   │   ├── documentation.yml
│   │   ├── feature_request.yml
│   │   └── infrastructure_issue.yml
│   └── workflows/
│       └── terraform-deploy.yml # GitHub Actions CI/CD workflow
├── .azuredevops/
│   └── terraform-pipeline.yml  # Azure DevOps pipeline YAML
├── assets/
│   └── pp-terraform-social-preview.png
├── docs/
│   ├── architecture.md          # Architecture diagrams & decisions
│   ├── article.md               # Related article content
│   ├── pre-checklist.md         # Pre-deployment setup guide
│   ├── post-checklist.md        # Post-deployment validation
│   └── runbook.md               # Operations runbook
├── scripts/
│   ├── bootstrap.sh             # Initialize Terraform state storage
│   └── destroy-nonprod.sh       # Cleanup script for non-prod
├── terraform/
│   ├── main.tf                  # Root module — wires everything together
│   ├── providers.tf             # Provider & backend configuration
│   ├── variables.tf             # Input variable declarations
│   ├── outputs.tf               # Outputs exposed to pipelines
│   ├── environments/            # Per-environment configs
│   │   ├── backend-dev.hcl
│   │   ├── backend-test.hcl
│   │   ├── backend-prod.hcl
│   │   ├── dev.tfvars
│   │   ├── test.tfvars
│   │   └── prod.tfvars
│   └── modules/                 # Reusable child modules
│       ├── apim/                # API Management
│       ├── app-registration/    # Entra ID App Registration
│       ├── function-app/        # Azure Functions
│       ├── keyvault/            # Key Vault
│       └── storage/             # Storage Account
├── .gitignore
├── LICENSE
└── README.md
```

## Environments

| Environment | State Key | Branch | Approval Required |
|------------|-----------|--------|------------------|
| `dev` | `dev.tfstate` | `feature/*` | No |
| `test` | `test.tfstate` | `main` | No |
| `prod` | `prod.tfstate` | `main` | Yes — manual gate |

## Prerequisites

- Terraform CLI >= 1.5.0
- Azure CLI >= 2.50.0
- Azure subscription (Contributor role)
- GitHub or Azure DevOps account

## Documentation

- **[Architecture Overview](docs/architecture.md)** — Complete infrastructure architecture, CI/CD, security, and data flows
- **[Pre-Deployment Checklist](docs/pre-checklist.md)** — Setup guide for service principals, permissions, and GitHub configuration
- **[Post-Deployment Checklist](docs/post-checklist.md)** — Validation and testing steps after deployment
- **[Operations Runbook](docs/runbook.md)** — Day-2 operations and troubleshooting guide

## Related Article

Full walkthrough: [Terraform for Power Platform Developers — aidevme.com](https://aidevme.com/terraform-azure-power-platform-developers)

## Author

**Zsolt Zombik** — Senior Power Platform Expert  
[aidevme.com](https://aidevme.com) | [LinkedIn](https://www.linkedin.com/in/zsoltzombik/)
