#!/bin/bash
set -e

# Build and Deploy Script for awto-flutter-framework
# Outputs clean, parseable text suitable for CI/CD and AI processing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_ROOT/tmp/build-deploy-$(date +%s).log"

# Ensure log directory exists
mkdir -p "$PROJECT_ROOT/tmp"

# Colors for output (can be disabled with NO_COLOR=1)
if [ -z "$NO_COLOR" ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  GREEN=''
  RED=''
  YELLOW=''
  NC=''
fi

# Logging functions for clean output
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_section() {
  echo "" | tee -a "$LOG_FILE"
  echo "=== $1 ===" | tee -a "$LOG_FILE"
}

log_success() {
  echo "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
  echo "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

# Pre-flight checks
log_section "Pre-flight Checks"
log "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
  log_error "Flutter not found in PATH"
  exit 1
fi
log_success "Flutter found: $(flutter --version | head -n 1)"

log "Checking pub dependencies..."
flutter pub get >> "$LOG_FILE" 2>&1
log_success "Dependencies resolved"

# Build
log_section "Building Flutter App"
BUILD_START=$(date +%s)
log "Starting build..."
flutter build apk --release >> "$LOG_FILE" 2>&1
BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))
log_success "Build completed in ${BUILD_TIME}s"

# Deploy (placeholder)
log_section "Deployment"
log "Deployment logic to be implemented"
log_success "Deployment ready"

# Summary
log_section "Summary"
log "Status: SUCCESS"
log "Build time: ${BUILD_TIME}s"
log "Log file: $LOG_FILE"

exit 0
