variable "project_name"          { type = string }
variable "environment"           { type = string }
variable "location"              { type = string }
variable "resource_group_name"   { type = string }
variable "storage_account_name"  { type = string }
variable "storage_account_key"   { type = string; sensitive = true }
variable "key_vault_id"          { type = string }
variable "key_vault_uri"         { type = string }
variable "tenant_id"             { type = string }
variable "dotnet_version"        { type = string; default = "v8.0" }
variable "allowed_origins"       { type = list(string); default = [] }
variable "tags"                  { type = map(string); default = {} }
