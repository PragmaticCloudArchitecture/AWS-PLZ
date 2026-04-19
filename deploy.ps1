#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("init", "validate", "plan", "apply", "destroy")]
    [string]$Operation,

    [Parameter(Mandatory = $true)]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$Region,

    [Parameter(Mandatory = $false)]
    [string]$Tfvars
)

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Confirm-Action {
    param([string]$Prompt)

    $response = Read-Host "$Prompt (type 'yes' to continue)"
    return $response -eq "yes"
}

try {
    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        throw "Terraform is not installed or not available in PATH."
    }

    if ($Tfvars -and -not (Test-Path -LiteralPath $Tfvars -PathType Leaf)) {
        throw "tfvars file does not exist: $Tfvars"
    }

    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $planDir = Join-Path $scriptDir "plans/$Environment"
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $planFile = Join-Path $planDir "$Operation-$Region-$timestamp.tfplan"

    $terraformArgs = @()
    if ($Tfvars) {
        $terraformArgs += "-var-file=$Tfvars"
    }

    Write-Info "Starting Terraform operation: $Operation"
    Write-Info "Environment: $Environment"
    Write-Info "Region: $Region"
    if ($Tfvars) {
        Write-Info "tfvars file: $Tfvars"
    }

    switch ($Operation) {
        "init" {
            Write-Info "Running terraform init..."
            & terraform init
        }
        "validate" {
            Write-Info "Running terraform validate..."
            & terraform validate
        }
        "plan" {
            New-Item -ItemType Directory -Force -Path $planDir | Out-Null
            Write-Info "Running terraform plan and writing output to: $planFile"
            & terraform plan "-var=region=$Region" @terraformArgs "-out=$planFile"
            Write-Success "Terraform plan completed."
        }
        "apply" {
            if (-not (Confirm-Action "You are about to APPLY infrastructure for environment '$Environment' in region '$Region'.")) {
                throw "Apply cancelled by user."
            }

            New-Item -ItemType Directory -Force -Path $planDir | Out-Null
            Write-Info "Creating apply plan at: $planFile"
            & terraform plan "-var=region=$Region" @terraformArgs "-out=$planFile"
            Write-Info "Applying plan: $planFile"
            & terraform apply $planFile
            Write-Success "Terraform apply completed."
        }
        "destroy" {
            if (-not (Confirm-Action "You are about to DESTROY infrastructure for environment '$Environment' in region '$Region'.")) {
                throw "Destroy cancelled by user."
            }

            New-Item -ItemType Directory -Force -Path $planDir | Out-Null
            Write-Info "Creating destroy plan at: $planFile"
            & terraform plan -destroy "-var=region=$Region" @terraformArgs "-out=$planFile"
            Write-Info "Applying destroy plan: $planFile"
            & terraform apply $planFile
            Write-Success "Terraform destroy completed."
        }
    }

    Write-Success "Operation '$Operation' finished successfully."
}
catch {
    Write-Fail $_.Exception.Message
    exit 1
}
