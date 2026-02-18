output "hostname"              { value = azurerm_windows_function_app.this.default_hostname }
output "name"                  { value = azurerm_windows_function_app.this.name }
output "principal_id"          { value = azurerm_windows_function_app.this.identity[0].principal_id }
output "app_insights_key"      { value = azurerm_application_insights.this.instrumentation_key
  sensitive = true }
