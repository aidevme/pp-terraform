# ─── Dev Environment Variables ────────────────────────────────────────────────
# ⚠️  Do NOT add secrets here. Secrets are injected by the pipeline.

environment  = "dev"
location     = "westeurope"
project_name = "myproj"

# Feature flags — APIM is expensive; disable for dev
deploy_apim             = false
deploy_function_app     = true
deploy_app_registration = true

# Key Vault
keyvault_sku              = "standard"
keyvault_soft_delete_days = 7
keyvault_purge_protection = false

# Storage
storage_replication_type    = "LRS"
storage_blob_retention_days = 7

# Function App
function_dotnet_version = "v8.0"
function_allowed_origins = [
  "https://make.powerautomate.com",
  "https://make.powerapps.com"
]

# APIM (not deployed in dev, but variables required by validation)
apim_publisher_name  = "Power Platform Team"
apim_publisher_email = "powerplatform@yourorg.com"

# App Registration
app_registration_secret_end_date = "2026-12-31T00:00:00Z"

tags = {
  Environment = "Development"
  Project     = "MyProject"
  ManagedBy   = "Terraform"
  Owner       = "PowerPlatformTeam"
  CostCenter  = "IT-Dev"
}
