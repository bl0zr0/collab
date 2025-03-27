#!/bin/bash

set -e
set -u

echo "Starting Dev Environment Setup..."

# Q1: Get PBI Number with validation
while true; do
  read -p "What is the PBI number? (7 or 8 digits): " PBI_NUMBER
  if [[ "$PBI_NUMBER" =~ ^[0-9]{7,8}$ ]]; then
    break
  else
    echo "Invalid PBI number. It must be 7 or 8 digits."
  fi
done

# Q2: Get change type (with select menu)
echo "What is the change type?"
PS3="Select a number (1-4): "
select CHANGE_TYPE in feature improvement bugfix hotfix; do
    if [[ -n "$CHANGE_TYPE" ]]; then
        echo "You selected: $CHANGE_TYPE"
        break
    else
        echo "Invalid selection. Try again."
    fi
done

# Function to confirm use of existing env var
confirm_use() {
  local var_name="$1"
  local var_value="${!var_name}"
  read -p "$var_name is already set to: $var_value. Use this value? (y/n): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Using existing $var_name"
  else
    read -p "Enter new value for $var_name: " new_value
    export "$var_name"="$new_value"
  fi
}

# Q3–Q5: AWS Credentials
if [[ -n "${AWS_ACCESS_KEY_ID:-}" ]]; then
  confirm_use AWS_ACCESS_KEY_ID
else
  read -p "Enter AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
  export AWS_ACCESS_KEY_ID
fi

if [[ -n "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  confirm_use AWS_SECRET_ACCESS_KEY
else
  read -p "Enter AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
  export AWS_SECRET_ACCESS_KEY
fi

if [[ -n "${AWS_SESSION_TOKEN:-}" ]]; then
  confirm_use AWS_SESSION_TOKEN
else
  read -p "Enter AWS_SESSION_TOKEN: " AWS_SESSION_TOKEN
  export AWS_SESSION_TOKEN
fi

# Git operations
echo "Fetching latest branches..."
git fetch

echo "Checking out 'develop' branch..."
git checkout develop

NEW_BRANCH="${CHANGE_TYPE}/${PBI_NUMBER}"
echo "Creating new branch: $NEW_BRANCH"
git checkout -b "$NEW_BRANCH"

# Export AWS credentials for Terraform
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

echo "AWS credentials exported."

# Create temp folder
TEMP_DIR=$(mktemp -d)
echo "Created temporary folder: $TEMP_DIR"

# Pull Terraform state and save to temp folder
echo "Pulling Terraform state..."
terraform state pull > "$TEMP_DIR/terraform.tfstate"

# Create new Terraform workspace
echo "Creating new Terraform workspace: $PBI_NUMBER"
terraform workspace new "$PBI_NUMBER"

# Push state into new workspace
echo "Pushing state file to workspace..."
terraform state push "$TEMP_DIR/terraform.tfstate"

# Create a .start-dev marker file
touch .start-dev
echo ".start-dev file created."

echo "Done! You are now in branch '$NEW_BRANCH' and workspace '$PBI_NUMBER'."

