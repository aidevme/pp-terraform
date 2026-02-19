resource "azurerm_storage_account" "this" {
  name                            = "st${var.project_name}${var.environment}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = var.replication_type
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = var.blob_retention_days
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "archive" {
  name                  = "archive"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Persist connection string in Key Vault
resource "azurerm_key_vault_secret" "connection_string" {
  name         = "storage-connection-string"
  value        = azurerm_storage_account.this.primary_connection_string
  key_vault_id = var.key_vault_id

  tags = var.tags
}
