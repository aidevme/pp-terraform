output "gateway_url" {
  value = azurerm_api_management.this.gateway_url
}

output "apim_name" {
  value = azurerm_api_management.this.name
}

output "principal_id" {
  value = azurerm_api_management.this.identity[0].principal_id
}
