#!/usr/bin/env bash
# bootstrap.sh
# Creates the Azure Storage Account used for Terraform remote state.
# Run this ONCE before your first terraform init.
# Usage: ./scripts/bootstrap.sh
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Contributor rights on the target subscription

set -euo pipefail

# ─── Configuration — edit these values ───────────────────────────────────────
LOCATION="westeurope"
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="sttfstate$(openssl rand -hex 4)"   # Unique suffix auto-generated
CONTAINER="tfstate"
# ─────────────────────────────────────────────────────────────────────────────

echo "🔧 Bootstrapping Terraform remote state..."
echo "   Location:        $LOCATION"
echo "   Resource Group:  $RESOURCE_GROUP"
echo "   Storage Account: $STORAGE_ACCOUNT"
echo ""

# Create resource group
echo "📦 Creating resource group..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags ManagedBy=Terraform Purpose=TerraformState \
  --output none

# Create storage account
echo "💾 Creating storage account..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --output none

# Create blob container
echo "🗂️  Creating tfstate container..."
az storage container create \
  --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output none

# Enable versioning on the container (protects state file history)
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true \
  --output none

echo ""
echo "✅ Bootstrap complete! Update your backend .hcl files with:"
echo ""
echo "   resource_group_name  = \"$RESOURCE_GROUP\""
echo "   storage_account_name = \"$STORAGE_ACCOUNT\""
echo "   container_name       = \"$CONTAINER\""
echo ""
echo "   Also set these as pipeline secrets:"
echo "   TF_STATE_RG  = $RESOURCE_GROUP"
echo "   TF_STATE_SA  = $STORAGE_ACCOUNT"
echo "   TF_STATE_CONTAINER = $CONTAINER"
