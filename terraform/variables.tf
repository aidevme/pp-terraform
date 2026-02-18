# ─── Core ─────────────────────────────────────────────────────────────────────

variable "environment" {
  description = "Deployment environment. Must be one of: dev, test, prod."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "Short project name used in resource naming. Max 8 lowercase alphanumeric characters."
  type        = string
  validation {
    condition     = length(var.project_name) <= 8 && can(regex("^[a-z0-9]+$", var.project_name))
    error_message = "project_name must be max 8 lowercase alphanumeric characters."
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

# ─── Feature Flags ────────────────────────────────────────────────────────────

variable "deploy_apim" {
  description = "Whether to deploy Azure API Management. Disable for dev to reduce cost."
  type        = bool
  default     = false
}

variable "deploy_function_app" {
  description = "Whether to deploy Azure Function App."
  type        = bool
  default     = true
}

variable "deploy_app_registration" {
  description = "Whether to create the Entra ID App Registration for Dataverse."
  type        = bool
  default     = true
}

# ─── Key Vault ────────────────────────────────────────────────────────────────

variable "keyvault_sku" {
  description = "Key Vault SKU. standard or premium."
  type        = string
  default     = "standard"
}

variable "keyvault_soft_delete_days" {
  description = "Soft delete retention days for Key Vault (7–90)."
  type        = number
  default     = 7
}

variable "keyvault_purge_protection" {
  description = "Enable purge protection on Key Vault. Recommended true for production."
  type        = bool
  default     = false
}

# ─── Storage ──────────────────────────────────────────────────────────────────

variable "storage_replication_type" {
  description = "Storage account replication. LRS, GRS, ZRS, GZRS."
  type        = string
  default     = "LRS"
}

variable "storage_blob_retention_days" {
  description = "Blob soft delete retention in days."
  type        = number
  default     = 30
}

# ─── Function App ─────────────────────────────────────────────────────────────

variable "function_dotnet_version" {
  description = ".NET version for the Function App runtime."
  type        = string
  default     = "v8.0"
}

variable "function_allowed_origins" {
  description = "CORS allowed origins for the Function App."
  type        = list(string)
  default = [
    "https://make.powerautomate.com",
    "https://make.powerapps.com",
    "https://*.powerapps.com"
  ]
}

# ─── APIM ─────────────────────────────────────────────────────────────────────

variable "apim_publisher_name" {
  description = "Publisher name for API Management."
  type        = string
  default     = "Power Platform Team"
}

variable "apim_publisher_email" {
  description = "Publisher email for API Management."
  type        = string
}

# ─── App Registration ─────────────────────────────────────────────────────────

variable "app_registration_secret_end_date" {
  description = "Expiry date for the App Registration client secret (ISO 8601)."
  type        = string
  default     = "2026-12-31T00:00:00Z"
}

# ─── Secrets (injected from pipeline — never in .tfvars files) ────────────────

variable "connector_api_key" {
  description = "External API key for the custom connector. Injected from pipeline secret."
  type        = string
  sensitive   = true
  default     = ""
}
