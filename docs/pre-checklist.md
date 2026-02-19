# Pre-Deployment Checklist

Complete this checklist before running the GitHub Actions workflow to ensure successful infrastructure deployment.

---

## 1. Azure Subscription Prerequisites

- [ ] Active Azure subscription with **Contributor** role
- [ ] Access to Microsoft Entra ID (Azure AD) with permission to:
  - Create service principals
  - Assign directory roles
- [ ] Azure CLI installed and authenticated: `az login`
- [ ] Verify current subscription: `az account show`

---

## 2. Service Principal Setup (OIDC Authentication)

### Create App Registration for GitHub Actions

```powershell
# Create the app registration
az ad app create --display-name "GitHub-Actions-OIDC-Terraform"

# Get the Application (client) ID
$APP_ID = az ad app list --display-name "GitHub-Actions-OIDC-Terraform" --query "[0].appId" -o tsv

# Create service principal
az ad sp create --id $APP_ID

# Get the service principal Object ID
$SP_OBJECT_ID = az ad sp show --id $APP_ID --query "id" -o tsv

# Get your subscription and tenant IDs
$SUBSCRIPTION_ID = az account show --query "id" -o tsv
$TENANT_ID = az account show --query "tenantId" -o tsv

# Assign Contributor role to the subscription
az role assignment create `
  --role "Contributor" `
  --assignee $APP_ID `
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### Configure Federated Credentials for GitHub

```powershell
# For main branch
az ad app federated-credential create --id $APP_ID --parameters @- <<EOF
{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:aidevme/pp-terraform:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

# For pull requests
az ad app federated-credential create --id $APP_ID --parameters @- <<EOF
{
  "name": "github-pr",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:aidevme/pp-terraform:pull_request",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF
```

### Grant Azure AD Permissions

```powershell
# Assign Cloud Application Administrator role (required for App Registration module)
az rest --method POST --uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments" `
  --headers "Content-Type=application/json" `
  --body "{
    \"@odata.type\":\"#microsoft.graph.unifiedRoleAssignment\",
    \"roleDefinitionId\":\"158c047a-c907-4556-b7ef-446551a6b5f7\",
    \"principalId\":\"$SP_OBJECT_ID\",
    \"directoryScopeId\":\"/\"
  }"

# Verify role assignment
az rest --method GET `
  --uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$filter=principalId eq '$SP_OBJECT_ID'" `
  --query "value[].{RoleId:roleDefinitionId,PrincipalId:principalId}" --output table
```

**Save these values for GitHub Secrets:**
```
AZURE_CLIENT_ID:       [your $APP_ID]
AZURE_TENANT_ID:       [your $TENANT_ID]
AZURE_SUBSCRIPTION_ID: [your $SUBSCRIPTION_ID]
```

---

## 3. Azure Storage for Terraform State

### Run Bootstrap Script

```bash
# From repository root
./scripts/bootstrap.sh
```

**This creates:**
- Resource Group: `rg-terraform-state`
- Storage Account: `sttfstate[unique-suffix]`
- Containers: `dev-tfstate`, `test-tfstate`, `prod-tfstate`

**Update backend config files** with the storage account name:
- `terraform/environments/backend-dev.hcl`
- `terraform/environments/backend-test.hcl`
- `terraform/environments/backend-prod.hcl`

**Grant Service Principal access:**
```powershell
az role assignment create `
  --role "Storage Blob Data Contributor" `
  --assignee $APP_ID `
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-terraform-state"
```

---

## 4. GitHub Repository Configuration

### GitHub Secrets (Repository Level)

Navigate to: **Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Value | Description |
|------------|-------|-------------|
| `AZURE_CLIENT_ID` | `[App ID from step 2]` | Service Principal Application ID |
| `AZURE_TENANT_ID` | `[Tenant ID from step 2]` | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | `[Subscription ID from step 2]` | Target Azure Subscription |
| `CONNECTOR_API_KEY` | `[your-secure-key]` | Optional: Custom connector API key |

### GitHub Environments (Optional but Recommended)

Create environments: **Settings → Environments → New environment**

**For each environment (`dev`, `test`, `prod`):**
1. Add environment-specific secrets (if needed)
2. Configure protection rules:
   - **prod**: Enable "Required reviewers" (1-6 reviewers)
   - **test/dev**: No approval required

---

## 5. Permissions Checklist

### Service Principal Azure Roles
- [x] `Contributor` on target subscription
- [x] `Storage Blob Data Contributor` on Terraform state storage
- [x] `Cloud Application Administrator` in Azure AD (directory role)

### Your User Account
- [x] `Owner` or `User Access Administrator` (to assign roles)
- [x] `Global Administrator` or `Privileged Role Administrator` (to assign directory roles)

### Verify Permissions
```powershell
# Check Azure role assignments
az role assignment list --assignee $APP_ID --output table

# Check Azure AD role assignments
az rest --method GET `
  --uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$filter=principalId eq '$SP_OBJECT_ID'" `
  --query "value[].roleDefinitionId"
```

---

## 6. Repository Setup

- [ ] Fork/clone repository
- [ ] Update `owner` and `repo` references in workflow files (if forked)
- [ ] Review and customize `.tfvars` files:
  - `terraform/environments/dev.tfvars`
  - `terraform/environments/test.tfvars`
  - `terraform/environments/prod.tfvars`
- [ ] Update `project_name` variable (must be globally unique for storage/function names)

---

## 7. Local Testing (Optional)

Before pushing to GitHub, test locally:

```bash
cd terraform

# Set environment variables for OIDC (or use Azure CLI)
export ARM_CLIENT_ID="$APP_ID"
export ARM_TENANT_ID="$TENANT_ID"
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export ARM_USE_CLI="true"

# Initialize
terraform init -backend-config=environments/backend-dev.hcl

# Validate
terraform validate

# Format check
terraform fmt -check -recursive

# Plan
terraform plan -var-file=environments/dev.tfvars

# Apply (if plan looks good)
terraform apply -var-file=environments/dev.tfvars
```

---

## 8. Workflow Triggers

The GitHub Actions workflow runs on:

1. **Push to `main`** with changes in `terraform/**`
2. **Pull Request to `main`** with changes in `terraform/**`
3. **Manual dispatch** via Actions tab → "Run workflow"

---

## 9. First Run Checklist

Before triggering the first workflow run:

- [ ] All GitHub secrets configured
- [ ] Service principal has all required permissions
- [ ] Backend storage account created and configured
- [ ] Terraform format check passes locally: `terraform fmt -check -recursive`
- [ ] Environment-specific `.tfvars` files reviewed
- [ ] Protection rules configured for production environment

---

## 10. Troubleshooting

### Common Issues

| Error | Solution |
|-------|----------|
| `Authorization_RequestDenied` | Grant `Cloud Application Administrator` role to service principal |
| `Storage account not found` | Run bootstrap script and update backend config files |
| `Insufficient permissions` | Verify service principal has `Contributor` role on subscription |
| `workspace_id cannot be removed` | Lifecycle block added in function-app module (already fixed) |
| `Format check failed` | Run `terraform fmt -recursive` to auto-format |

### Debug Commands

```powershell
# Verify Azure login
az account show

# List service principals
az ad sp list --display-name "GitHub-Actions-OIDC-Terraform" --output table

# Check federated credentials
az ad app federated-credential list --id $APP_ID

# Test Terraform locally with verbose logging
export TF_LOG=DEBUG
terraform plan
```

---

## Resources

- [Azure OIDC with GitHub Actions](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)

---

**✅ Once all items are checked, you're ready to run the workflow!**