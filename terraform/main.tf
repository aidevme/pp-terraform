# ─── Data Sources ─────────────────────────────────────────────────────────────

data "azurerm_client_config" "current" {}

# ─── Resource Group ───────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# ─── Module: Key Vault ────────────────────────────────────────────────────────

module "keyvault" {
  source = "./modules/keyvault"

  project_name              = var.project_name
  environment               = var.environment
  location                  = var.location
  resource_group_name       = azurerm_resource_group.main.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  deployer_object_id        = data.azurerm_client_config.current.object_id
  sku                       = var.keyvault_sku
  soft_delete_retention_days = var.keyvault_soft_delete_days
  purge_protection_enabled  = var.keyvault_purge_protection
  tags                      = var.tags
}

# ─── Module: Storage ──────────────────────────────────────────────────────────

module "storage" {
  source = "./modules/storage"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  replication_type    = var.storage_replication_type
  blob_retention_days = var.storage_blob_retention_days
  key_vault_id        = module.keyvault.key_vault_id
  tags                = var.tags

  depends_on = [module.keyvault]
}

# ─── Module: Function App ─────────────────────────────────────────────────────

module "function_app" {
  source = "./modules/function-app"
  count  = var.deploy_function_app ? 1 : 0

  project_name         = var.project_name
  environment          = var.environment
  location             = var.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_name = module.storage.storage_account_name
  storage_account_key  = module.storage.storage_account_primary_key
  key_vault_id         = module.keyvault.key_vault_id
  key_vault_uri        = module.keyvault.key_vault_uri
  dotnet_version       = var.function_dotnet_version
  allowed_origins      = var.function_allowed_origins
  tenant_id            = data.azurerm_client_config.current.tenant_id
  tags                 = var.tags

  depends_on = [module.keyvault]
}

# ─── Module: App Registration ─────────────────────────────────────────────────

module "app_registration" {
  source = "./modules/app-registration"
  count  = var.deploy_app_registration ? 1 : 0

  project_name    = var.project_name
  environment     = var.environment
  secret_end_date = var.app_registration_secret_end_date
  key_vault_id    = module.keyvault.key_vault_id

  depends_on = [module.keyvault]
}

# ─── Module: API Management ───────────────────────────────────────────────────

module "apim" {
  source = "./modules/apim"
  count  = var.deploy_apim ? 1 : 0

  project_name          = var.project_name
  environment           = var.environment
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  publisher_name        = var.apim_publisher_name
  publisher_email       = var.apim_publisher_email
  function_app_hostname = var.deploy_function_app ? module.function_app[0].hostname : ""
  key_vault_id          = module.keyvault.key_vault_id
  tags                  = var.tags

  depends_on = [module.keyvault]
}

# ─── Store connector API key in Key Vault (if provided) ───────────────────────

resource "azurerm_key_vault_secret" "connector_api_key" {
  count        = var.connector_api_key != "" ? 1 : 0
  name         = "custom-connector-api-key"
  value        = var.connector_api_key
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault]

  tags = var.tags
}
