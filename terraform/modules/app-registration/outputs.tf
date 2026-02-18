output "client_id"       { value = azuread_application.this.client_id; sensitive = true }
output "object_id"       { value = azuread_application.this.object_id }
output "application_id"  { value = azuread_application.this.id }
