# start-dev.ps1

# Exit on error
$ErrorActionPreference = "Stop"

Write-Host "Starting Dev Environment Setup..."

# Prompt for PBI number
while ($true) {
    $PBI_NUMBER = Read-Host "What is the PBI number? (7 or 8 digits)"
    if ($PBI_NUMBER -match '^[0-9]{7,8}$') { break }
    Write-Host "Invalid PBI number. It must be 7 or 8 digits."
}

# Prompt for change type
$changeTypes = @("feature", "improvement", "bugfix", "hotfix")
for ($i = 0; $i -lt $changeTypes.Count; $i++) {
    Write-Host "$($i + 1)) $($changeTypes[$i])"
}

while ($true) {
    $choice = Read-Host "Select a number (1-4) for change type"
    if ($choice -match '^[1-4]$') {
        $CHANGE_TYPE = $changeTypes[$choice - 1]
        break
    }
    Write-Host "Invalid selection."
}

# Check AWS SSO credentials from default profile (assumes AWS SSO login has been run)
try {
    $awsCreds = aws sts get-caller-identity --output json | ConvertFrom-Json
    if ($awsCreds) {
        Write-Host "Using active AWS SSO credentials (via 'aws sso login')"
    }
} catch {
    Write-Host "No active AWS SSO session found. Please run 'aws sso login' and try again."
    exit 1
}

# Git commands
Write-Host "Running git fetch and switching to develop..."
git fetch
git checkout develop

$branchName = "$CHANGE_TYPE/$PBI_NUMBER"
Write-Host "Creating new branch: $branchName"
git checkout -b $branchName

# Create temp folder
$tempDir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName())
Write-Host "Created temporary folder: $($tempDir.FullName)"

# Terraform operations
Write-Host "Running terraform state pull..."
terraform state pull > "$($tempDir.FullName)\terraform.tfstate"

Write-Host "Creating terraform workspace: $PBI_NUMBER"
terraform workspace new $PBI_NUMBER

Write-Host "Pushing state to workspace..."
terraform state push "$($tempDir.FullName)\terraform.tfstate"

# Create marker file
New-Item -ItemType File -Name ".start-dev" | Out-Null
Write-Host ".start-dev file created."

Write-Host "Done! You are now in branch '$branchName' and workspace '$PBI_NUMBER'."