# ─── Production Environment Variables ────────────────────────────────────────

environment  = "prod"
location     = "westeurope"
project_name = "myproj"

deploy_apim             = true
deploy_function_app     = true
deploy_app_registration = true

keyvault_sku              = "standard"
keyvault_soft_delete_days = 90
keyvault_purge_protection = true # Always true in production

storage_replication_type    = "ZRS" # Zone-redundant for production
storage_blob_retention_days = 30

function_dotnet_version = "v8.0"
function_allowed_origins = [
  "https://make.powerautomate.com",
  "https://make.powerapps.com"
]

apim_publisher_name  = "Power Platform Team"
apim_publisher_email = "powerplatform@yourorg.com"

app_registration_secret_end_date = "2026-12-31T00:00:00Z"

tags = {
  Environment = "Production"
  Project     = "MyProject"
  ManagedBy   = "Terraform"
  Owner       = "PowerPlatformTeam"
  CostCenter  = "IT-Prod"
}
