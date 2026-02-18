# Operational Runbook

## First-Time Setup

### 1. Bootstrap State Storage
```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```
Copy the output values into `terraform/environments/backend-*.hcl`.

### 2. Configure Pipeline Secrets

**GitHub Actions** — add these as repository/environment secrets:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | OIDC App Registration client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |
| `TF_STATE_RG` | Resource group for state storage |
| `TF_STATE_SA` | Storage account name for state |
| `TF_STATE_CONTAINER` | Container name (tfstate) |
| `CONNECTOR_API_KEY` | External API key for custom connector |

**Azure DevOps** — create two variable groups in Library:
- `terraform-common`: TF_STATE_RG, TF_STATE_SA, TF_STATE_CONTAINER
- `terraform-dev` / `terraform-test` / `terraform-prod`: CONNECTOR_API_KEY

### 3. First Deploy (Local)
```bash
cd terraform
terraform init -backend-config=environments/backend-dev.hcl
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

---

## Day-to-Day Operations

### Deploy a specific environment via pipeline
**GitHub Actions:**
- Go to Actions → Terraform Deploy → Run workflow → select environment

**Azure DevOps:**
- Run pipeline → set `environment` parameter

### Rotate a Key Vault secret
1. Update the secret value in your pipeline variable group
2. Run `terraform apply` — Terraform will update the Key Vault secret automatically

### Rotate the App Registration client secret
1. Update `app_registration_secret_end_date` in the relevant `.tfvars` file
2. Run `terraform apply` — a new secret is created and stored in Key Vault
3. Update any Power Platform connections referencing the old secret

### Destroy non-production to save costs
```bash
chmod +x scripts/destroy-nonprod.sh
./scripts/destroy-nonprod.sh dev
# or
./scripts/destroy-nonprod.sh test
```

### Check Terraform state
```bash
cd terraform
terraform init -backend-config=environments/backend-dev.hcl
terraform state list
terraform state show module.keyvault.azurerm_key_vault.this
```

---

## Troubleshooting

### "Backend configuration changed"
Run `terraform init -reconfigure -backend-config=environments/backend-{env}.hcl`

### "State is locked"
Another pipeline run is in progress, or a previous run crashed.
```bash
terraform force-unlock <lock-id>
```
Find the lock ID in the error message.

### Key Vault soft-delete conflict
If you destroyed and recreated an environment and get a "soft-deleted vault" error:
```bash
az keyvault recover --name kv-{project}-{env}
```
Or, if you want to purge it:
```bash
az keyvault purge --name kv-{project}-{env} --location westeurope
```

### Function App CORS issues with Power Platform
Ensure `make.powerapps.com` and `make.powerautomate.com` are in `function_allowed_origins` in your `.tfvars` file and re-apply.
