resource "azuread_application" "this" {
  display_name = "app-${var.project_name}-connector-${var.environment}"

  api {
    requested_access_token_version = 2
  }

  # Dataverse user_impersonation permission
  required_resource_access {
    resource_app_id = "00000007-0000-0000-c000-000000000000" # Dataverse

    resource_access {
      id   = "78ce3f0f-a1ce-49c2-8cde-64b5c0896db4" # user_impersonation
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
  display_name   = "terraform-managed-${var.environment}"
  end_date       = var.secret_end_date
}

# Persist credentials securely in Key Vault
resource "azurerm_key_vault_secret" "client_id" {
  name         = "connector-client-id"
  value        = azuread_application.this.client_id
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "client_secret" {
  name         = "connector-client-secret"
  value        = azuread_application_password.this.value
  key_vault_id = var.key_vault_id
}
