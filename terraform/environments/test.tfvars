# ─── Test Environment Variables ───────────────────────────────────────────────

environment  = "test"
location     = "westeurope"
project_name = "myproj"

deploy_apim             = false
deploy_function_app     = true
deploy_app_registration = true

keyvault_sku              = "standard"
keyvault_soft_delete_days = 7
keyvault_purge_protection = false

storage_replication_type    = "LRS"
storage_blob_retention_days = 14

function_dotnet_version = "v8.0"
function_allowed_origins = [
  "https://make.powerautomate.com",
  "https://make.powerapps.com"
]

apim_publisher_name  = "Power Platform Team"
apim_publisher_email = "powerplatform@yourorg.com"

app_registration_secret_end_date = "2026-12-31T00:00:00Z"

tags = {
  Environment = "Test"
  Project     = "MyProject"
  ManagedBy   = "Terraform"
  Owner       = "PowerPlatformTeam"
  CostCenter  = "IT-Dev"
}
