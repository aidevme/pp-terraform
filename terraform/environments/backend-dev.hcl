# Backend configuration for the DEV environment.
# Usage: terraform init -backend-config=environments/backend-dev.hcl
#
# The storage account and resource group must exist before running terraform init.
# Run scripts/bootstrap.sh to create them if needed.

resource_group_name  = "rg-terraform-state"
storage_account_name = "sttfstate59306909"
container_name       = "tfstate"
key                  = "dev.tfstate"
