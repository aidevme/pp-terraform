resource "azurerm_service_plan" "this" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "Y1" # Consumption plan

  tags = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = var.tags

  lifecycle {
    ignore_changes = [workspace_id]
  }
}

resource "azurerm_windows_function_app" "this" {
  name                = "func-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key
  service_plan_id            = azurerm_service_plan.this.id

  site_config {
    application_stack {
      dotnet_version              = var.dotnet_version
      use_dotnet_isolated_runtime = true
    }
    cors {
      allowed_origins     = var.allowed_origins
      support_credentials = false
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.this.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this.connection_string
    "FUNCTIONS_WORKER_RUNTIME"              = "dotnet-isolated"
    "KeyVaultUri"                           = var.key_vault_uri
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Grant Function App Managed Identity read-only access to Key Vault
resource "azurerm_key_vault_access_policy" "function_app" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_windows_function_app.this.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}
