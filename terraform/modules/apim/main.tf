resource "azurerm_api_management" "this" {
  name                = "apim-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.environment == "prod" ? "Standard_1" : "Developer_1"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_api_management_api" "connector" {
  name                  = "pp-connector-api"
  resource_group_name   = var.resource_group_name
  api_management_name   = azurerm_api_management.this.name
  revision              = "1"
  display_name          = "Power Platform Connector API"
  path                  = "connector"
  protocols             = ["https"]
  subscription_required = true

  # Only import OpenAPI spec when Function App hostname is provided
  dynamic "import" {
    for_each = var.function_app_hostname != "" ? [1] : []
    content {
      content_format = "openapi+json-link"
      content_value  = "https://${var.function_app_hostname}/api/openapi.json"
    }
  }
}

resource "azurerm_api_management_subscription" "connector" {
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name
  display_name        = "Power Platform Connector Subscription"
  api_id              = azurerm_api_management_api.connector.id
  state               = "active"
}

# Store APIM subscription key in Key Vault
resource "azurerm_key_vault_secret" "apim_subscription_key" {
  name         = "apim-subscription-key"
  value        = azurerm_api_management_subscription.connector.primary_key
  key_vault_id = var.key_vault_id

  tags = var.tags
}
