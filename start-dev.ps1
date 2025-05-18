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

# Try to load AWS credentials from .aws/credentials file
$awsProfile = "default"
$awsCredFile = "$env:USERPROFILE\.aws\credentials"
$awsAccessKey = $null
$awsSecretKey = $null
$awsSessionToken = $null

if (Test-Path $awsCredFile) {
    Write-Host "Checking AWS credentials in $awsCredFile..."
    $lines = Get-Content $awsCredFile
    $inProfile = $false
    foreach ($line in $lines) {
        if ($line -match "^\[$awsProfile\]") {
            $inProfile = $true
        } elseif ($inProfile -and $line -match "^\[.*\]$") {
            $inProfile = $false
        } elseif ($inProfile) {
            if ($line -match "aws_access_key_id\s*=\s*(.+)") {
                $awsAccessKey = $matches[1]
            } elseif ($line -match "aws_secret_access_key\s*=\s*(.+)") {
                $awsSecretKey = $matches[1]
            } elseif ($line -match "aws_session_token\s*=\s*(.+)") {
                $awsSessionToken = $matches[1]
            }
        }
    }
}

# Fallback to environment variables if not all credentials are found
function Confirm-EnvVar($varName, $currentValue) {
    if ($currentValue) {
        $use = Read-Host "$varName is set to: $currentValue. Use this value? (y/n)"
        if ($use -match '^(y|Y)') { return $currentValue }
    }
    return (Read-Host "Enter $varName")
}

$AWS_ACCESS_KEY_ID = if ($awsAccessKey) { Confirm-EnvVar "AWS_ACCESS_KEY_ID" $awsAccessKey } else { Confirm-EnvVar "AWS_ACCESS_KEY_ID" $env:AWS_ACCESS_KEY_ID }
$AWS_SECRET_ACCESS_KEY = if ($awsSecretKey) { Confirm-EnvVar "AWS_SECRET_ACCESS_KEY" $awsSecretKey } else { Confirm-EnvVar "AWS_SECRET_ACCESS_KEY" $env:AWS_SECRET_ACCESS_KEY }
$AWS_SESSION_TOKEN = if ($awsSessionToken) { Confirm-EnvVar "AWS_SESSION_TOKEN" $awsSessionToken } else { Confirm-EnvVar "AWS_SESSION_TOKEN" $env:AWS_SESSION_TOKEN }

$env:AWS_ACCESS_KEY_ID = $AWS_ACCESS_KEY_ID
$env:AWS_SECRET_ACCESS_KEY = $AWS_SECRET_ACCESS_KEY
$env:AWS_SESSION_TOKEN = $AWS_SESSION_TOKEN

Write-Host "AWS credentials exported."

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
