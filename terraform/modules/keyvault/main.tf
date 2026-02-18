resource "azurerm_key_vault" "this" {
  name                        = "kv-${var.project_name}-${var.environment}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  enable_rbac_authorization   = false

  tags = var.tags
}

# Grant the deploying service principal full secret management
resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.deployer_object_id

  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Purge", "Backup", "Restore"]
  key_permissions         = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
}
