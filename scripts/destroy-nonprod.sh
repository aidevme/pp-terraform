#!/usr/bin/env bash
# destroy-nonprod.sh
# Destroys dev or test infrastructure to save costs (e.g. run on Friday evening).
# NEVER targets prod — production is protected by an explicit guard.
# Usage: ./scripts/destroy-nonprod.sh dev
#        ./scripts/destroy-nonprod.sh test

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
  echo "❌ Usage: $0 <environment>  (dev or test)"
  exit 1
fi

if [[ "$ENVIRONMENT" == "prod" ]]; then
  echo "❌ This script will never destroy production. Exiting."
  exit 1
fi

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "test" ]]; then
  echo "❌ Environment must be 'dev' or 'test'. Got: $ENVIRONMENT"
  exit 1
fi

echo "⚠️  About to DESTROY all $ENVIRONMENT infrastructure."
read -rp "   Type the environment name to confirm: " CONFIRM

if [[ "$CONFIRM" != "$ENVIRONMENT" ]]; then
  echo "❌ Confirmation did not match. Aborting."
  exit 1
fi

echo "🔥 Destroying $ENVIRONMENT environment..."

cd terraform

terraform init -backend-config="environments/backend-${ENVIRONMENT}.hcl" -reconfigure

terraform destroy \
  -var-file="environments/${ENVIRONMENT}.tfvars" \
  -auto-approve

echo "✅ $ENVIRONMENT infrastructure destroyed."
echo "   Recreate anytime with: terraform apply -var-file=environments/${ENVIRONMENT}.tfvars"
