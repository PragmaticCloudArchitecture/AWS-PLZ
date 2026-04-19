#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() {
  printf '[INFO] %s\n' "$1"
}

log_success() {
  printf '[SUCCESS] %s\n' "$1"
}

log_error() {
  printf '[ERROR] %s\n' "$1" >&2
}

usage() {
  cat <<EOF
Usage: ./deploy.sh <operation> -e <environment> -r <region> [-t <tfvars-file>]

Operations:
  init | validate | plan | apply | destroy

Options:
  -e, --environment   Environment name (dev, test, prod, sandbox, etc.) [required]
  -r, --region        AWS region (us-east-1, eu-west-1, etc.) [required]
  -t, --tfvars        Path to Terraform tfvars file [optional]
  -h, --help          Show this help message
EOF
}

confirm() {
  local prompt="$1"
  read -r -p "$prompt (type 'yes' to continue): " response
  [[ "$response" == "yes" ]]
}

require_terraform() {
  if ! command -v terraform >/dev/null 2>&1; then
    log_error "Terraform is not installed or not available in PATH."
    exit 1
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

OPERATION="${1:-}"
if [[ -z "$OPERATION" ]]; then
  usage
  exit 1
fi
shift || true

ENVIRONMENT=""
REGION=""
TFVARS_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--environment)
      ENVIRONMENT="${2:-}"
      shift 2
      ;;
    -r|--region)
      REGION="${2:-}"
      shift 2
      ;;
    -t|--tfvars)
      TFVARS_FILE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ENVIRONMENT" || -z "$REGION" ]]; then
  log_error "Both environment and region are required."
  usage
  exit 1
fi

if [[ -n "$TFVARS_FILE" && ! -f "$TFVARS_FILE" ]]; then
  log_error "tfvars file does not exist: $TFVARS_FILE"
  exit 1
fi

if [[ ! "$OPERATION" =~ ^(init|validate|plan|apply|destroy)$ ]]; then
  log_error "Unsupported operation: $OPERATION"
  usage
  exit 1
fi

trap 'log_error "Command failed at line $LINENO."; exit 1' ERR

require_terraform

PLAN_DIR="$SCRIPT_DIR/plans/$ENVIRONMENT"
PLAN_FILE="$PLAN_DIR/${OPERATION}-${REGION}-$(date +%Y%m%d%H%M%S).tfplan"
TFVARS_ARG=()

if [[ -n "$TFVARS_FILE" ]]; then
  TFVARS_ARG=(-var-file="$TFVARS_FILE")
fi

log_info "Starting Terraform operation: $OPERATION"
log_info "Environment: $ENVIRONMENT"
log_info "Region: $REGION"
[[ -n "$TFVARS_FILE" ]] && log_info "tfvars file: $TFVARS_FILE"

case "$OPERATION" in
  init)
    log_info "Running terraform init..."
    terraform init
    ;;
  validate)
    log_info "Running terraform validate..."
    terraform validate
    ;;
  plan)
    mkdir -p "$PLAN_DIR"
    log_info "Running terraform plan and writing output to: $PLAN_FILE"
    terraform plan -var="region=$REGION" "${TFVARS_ARG[@]}" -out="$PLAN_FILE"
    log_success "Terraform plan completed."
    ;;
  apply)
    if ! confirm "You are about to APPLY infrastructure for environment '$ENVIRONMENT' in region '$REGION'."; then
      log_error "Apply cancelled by user."
      exit 1
    fi

    mkdir -p "$PLAN_DIR"
    log_info "Creating apply plan at: $PLAN_FILE"
    terraform plan -var="region=$REGION" "${TFVARS_ARG[@]}" -out="$PLAN_FILE"
    log_info "Applying plan: $PLAN_FILE"
    terraform apply "$PLAN_FILE"
    log_success "Terraform apply completed."
    ;;
  destroy)
    if ! confirm "You are about to DESTROY infrastructure for environment '$ENVIRONMENT' in region '$REGION'."; then
      log_error "Destroy cancelled by user."
      exit 1
    fi

    mkdir -p "$PLAN_DIR"
    log_info "Creating destroy plan at: $PLAN_FILE"
    terraform plan -destroy -var="region=$REGION" "${TFVARS_ARG[@]}" -out="$PLAN_FILE"
    log_info "Applying destroy plan: $PLAN_FILE"
    terraform apply "$PLAN_FILE"
    log_success "Terraform destroy completed."
    ;;
esac

log_success "Operation '$OPERATION' finished successfully."
