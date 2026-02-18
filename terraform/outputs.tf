# ─── Resource Group ───────────────────────────────────────────────────────────

output "resource_group_name" {
  description = "Name of the provisioned resource group."
  value       = azurerm_resource_group.main.name
}

# ─── Key Vault ────────────────────────────────────────────────────────────────

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault — use as environment variable in Power Platform."
  value       = module.keyvault.key_vault_uri
}

# ─── Storage ──────────────────────────────────────────────────────────────────

output "storage_account_name" {
  description = "Name of the Storage Account."
  value       = module.storage.storage_account_name
}

output "storage_uploads_container" {
  description = "Name of the uploads blob container."
  value       = module.storage.uploads_container_name
}

output "storage_processed_container" {
  description = "Name of the processed blob container."
  value       = module.storage.processed_container_name
}

# ─── Function App ─────────────────────────────────────────────────────────────

output "function_app_hostname" {
  description = "Function App hostname — base URL for custom connector definition."
  value       = var.deploy_function_app ? module.function_app[0].hostname : null
}

output "function_app_name" {
  description = "Function App resource name."
  value       = var.deploy_function_app ? module.function_app[0].name : null
}

# ─── APIM ─────────────────────────────────────────────────────────────────────

output "apim_gateway_url" {
  description = "APIM Gateway URL — use as host URL in custom connector definition."
  value       = var.deploy_apim ? module.apim[0].gateway_url : null
}

# ─── App Registration ─────────────────────────────────────────────────────────

output "app_registration_client_id" {
  description = "App Registration (Entra ID) client ID for Dataverse authentication."
  value       = var.deploy_app_registration ? module.app_registration[0].client_id : null
  sensitive   = true
}
