#!/bin/bash
set -e

# Build and Deploy Script for awto-flutter-framework
# Outputs clean, parseable text suitable for CI/CD and AI processing
#
# Usage:
#   ./scripts/build-deploy.sh [OPTIONS]
#
# Options:
#   --help              Show this help message
#   --app APP           CLI or GUI (default: both)
#   --type TYPE         debug or release (default: release)
#   --json              Output in JSON format
#   --no-color          Disable colored output
#   --no-logs           Disable file logging
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_ROOT/tmp"
LOG_FILE="$LOG_DIR/build-deploy-$(date +%s).log"
OUTPUT_JSON=0
NO_COLOR="${NO_COLOR:-0}"
ENABLE_LOGS=1
BUILD_APP="both"
BUILD_TYPE="release"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --app)
      BUILD_APP="$2"
      shift 2
      ;;
    --type)
      BUILD_TYPE="$2"
      shift 2
      ;;
    --json)
      OUTPUT_JSON=1
      NO_COLOR=1
      shift
      ;;
    --no-color)
      NO_COLOR=1
      shift
      ;;
    --no-logs)
      ENABLE_LOGS=0
      shift
      ;;
    --help)
      head -20 "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Color codes (only if colors enabled)
if [ "$NO_COLOR" = "0" ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  GREEN=''
  RED=''
  YELLOW=''
  BLUE=''
  NC=''
fi

# Logging functions
log() {
  local timestamp level msg
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  level="$1"
  shift
  msg="$*"

  if [ "$OUTPUT_JSON" = "0" ]; then
    echo "[${timestamp}] [${level}] ${msg}"
  fi

  if [ "$ENABLE_LOGS" = "1" ]; then
    echo "[${timestamp}] [${level}] ${msg}" >> "$LOG_FILE"
  fi
}

log_success() {
  local msg="$*"
  echo "${GREEN}✓${NC} ${msg}"
  log "SUCCESS" "$msg"
}

log_error() {
  local msg="$*"
  echo "${RED}✗${NC} ${msg}"
  log "ERROR" "$msg"
}

log_section() {
  local msg="$*"
  if [ "$OUTPUT_JSON" = "0" ]; then
    echo ""
    echo "${BLUE}=== ${msg} ===${NC}"
    echo ""
  fi
  log "SECTION" "$msg"
}

# JSON output builder
declare -A json_data
json_add() {
  local key="$1"
  local value="$2"
  json_data["$key"]="$value"
}

output_json() {
  echo "{"
  local first=1
  for key in "${!json_data[@]}"; do
    if [ "$first" = "0" ]; then
      echo ","
    fi
    printf '  "%s": "%s"' "$key" "${json_data[$key]}"
    first=0
  done
  echo ""
  echo "}"
}

# Pre-flight checks
preflight_checks() {
  log_section "Pre-flight Checks"

  # Check Flutter
  if ! command -v flutter &>/dev/null; then
    log_error "Flutter not found in PATH"
    json_add "status" "failed"
    json_add "error" "Flutter not found in PATH"
    return 1
  fi
  local flutter_version
  flutter_version=$(flutter --version | head -n 1)
  log_success "Flutter found: $flutter_version"
  json_add "flutter_version" "$flutter_version"

  # Check Dart
  if ! command -v dart &>/dev/null; then
    log_error "Dart not found in PATH"
    json_add "status" "failed"
    json_add "error" "Dart not found in PATH"
    return 1
  fi
  local dart_version
  dart_version=$(dart --version 2>&1 | head -n 1)
  log_success "Dart found: $dart_version"
  json_add "dart_version" "$dart_version"

  # Check CLI app dependencies
  if [ "$BUILD_APP" = "cli" ] || [ "$BUILD_APP" = "both" ]; then
    log "INFO" "Checking CLI dependencies..."
    if ! (cd "$PROJECT_ROOT/apps/cli" && dart pub get >/dev/null 2>&1); then
      log_error "Failed to get CLI dependencies"
      json_add "status" "failed"
      json_add "error" "CLI dependency resolution failed"
      return 1
    fi
    log_success "CLI dependencies resolved"
  fi

  # Check GUI app dependencies
  if [ "$BUILD_APP" = "gui" ] || [ "$BUILD_APP" = "both" ]; then
    log "INFO" "Checking GUI dependencies..."
    if ! (cd "$PROJECT_ROOT/apps/gui" && flutter pub get >/dev/null 2>&1); then
      log_error "Failed to get GUI dependencies"
      json_add "status" "failed"
      json_add "error" "GUI dependency resolution failed"
      return 1
    fi
    log_success "GUI dependencies resolved"
  fi

  return 0
}

# Code analysis
run_analysis() {
  log_section "Code Analysis"

  if [ "$BUILD_APP" = "cli" ] || [ "$BUILD_APP" = "both" ]; then
    log "INFO" "Analyzing CLI code..."
    if ! (cd "$PROJECT_ROOT/apps/cli" && dart analyze >/dev/null 2>&1); then
      log_error "CLI code analysis failed"
      json_add "status" "failed"
      json_add "error" "CLI analysis failed"
      return 1
    fi
    log_success "CLI analysis passed"
  fi

  if [ "$BUILD_APP" = "gui" ] || [ "$BUILD_APP" = "both" ]; then
    log "INFO" "Analyzing GUI code..."
    if ! (cd "$PROJECT_ROOT/apps/gui" && flutter analyze >/dev/null 2>&1); then
      log_error "GUI code analysis failed"
      json_add "status" "failed"
      json_add "error" "GUI analysis failed"
      return 1
    fi
    log_success "GUI analysis passed"
  fi

  return 0
}

# Run tests
run_tests() {
  log_section "Running Tests"

  if [ "$BUILD_APP" = "cli" ] || [ "$BUILD_APP" = "both" ]; then
    log "INFO" "Testing CLI app..."
    if ! (cd "$PROJECT_ROOT/apps/cli" && dart test >/dev/null 2>&1); then
      log_error "CLI tests failed"
      json_add "status" "failed"
      json_add "error" "CLI tests failed"
      return 1
    fi
    log_success "CLI tests passed"
  fi

  if [ "$BUILD_APP" = "gui" ] || [ "$BUILD_APP" = "both" ]; then
    log "INFO" "Testing GUI app..."
    if ! (cd "$PROJECT_ROOT/apps/gui" && flutter test >/dev/null 2>&1); then
      log_error "GUI tests failed"
      json_add "status" "failed"
      json_add "error" "GUI tests failed"
      return 1
    fi
    log_success "GUI tests passed"
  fi

  return 0
}

# Build applications
build_apps() {
  log_section "Building"

  local build_start
  build_start=$(date +%s)

  if [ "$BUILD_APP" = "cli" ] || [ "$BUILD_APP" = "both" ]; then
    log "INFO" "Building CLI app ($BUILD_TYPE)..."
    local cli_start
    cli_start=$(date +%s)

    if [ "$BUILD_TYPE" = "release" ]; then
      if ! (cd "$PROJECT_ROOT/apps/cli" && dart compile exe lib/main.dart -o build/awto_cli_demo 2>/dev/null); then
        log_error "CLI build failed"
        json_add "status" "failed"
        json_add "error" "CLI build failed"
        return 1
      fi
    fi

    local cli_end
    cli_end=$(date +%s)
    local cli_time=$((cli_end - cli_start))
    log_success "CLI built in ${cli_time}s"
    json_add "cli_build_time_seconds" "$cli_time"
  fi

  if [ "$BUILD_APP" = "gui" ] || [ "$BUILD_APP" = "both" ]; then
    log "INFO" "Building GUI app ($BUILD_TYPE)..."
    local gui_start
    gui_start=$(date +%s)

    case "$BUILD_TYPE" in
      release)
        if ! (cd "$PROJECT_ROOT/apps/gui" && flutter build apk --release >/dev/null 2>&1); then
          log_error "GUI APK build failed"
          json_add "status" "failed"
          json_add "error" "GUI APK build failed"
          return 1
        fi
        ;;
      debug)
        if ! (cd "$PROJECT_ROOT/apps/gui" && flutter build apk >/dev/null 2>&1); then
          log_error "GUI debug build failed"
          json_add "status" "failed"
          json_add "error" "GUI debug build failed"
          return 1
        fi
        ;;
    esac

    local gui_end
    gui_end=$(date +%s)
    local gui_time=$((gui_end - gui_start))
    log_success "GUI built in ${gui_time}s"
    json_add "gui_build_time_seconds" "$gui_time"
  fi

  local build_end
  build_end=$(date +%s)
  local total_time=$((build_end - build_start))
  log "INFO" "Total build time: ${total_time}s"
  json_add "total_build_time_seconds" "$total_time"

  return 0
}

# Summary
print_summary() {
  log_section "Summary"

  if [ "$OUTPUT_JSON" = "1" ]; then
    output_json
  else
    echo "Status: ${GREEN}SUCCESS${NC}"
    echo "Build Type: $BUILD_TYPE"
    echo "App(s): $BUILD_APP"
    if [ "$ENABLE_LOGS" = "1" ]; then
      echo "Log file: $LOG_FILE"
    fi
    echo ""
    echo "Timestamps:"
    echo "  Started: $(date -d @"${json_data[start_time]}" '+%Y-%m-%d %H:%M:%S')"
    echo "  Finished: $(date '+%Y-%m-%d %H:%M:%S')"
  fi
}

# Main execution
main() {
  local start_time
  start_time=$(date +%s)
  json_add "start_time" "$start_time"
  json_add "timestamp" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  json_add "app" "$BUILD_APP"
  json_add "build_type" "$BUILD_TYPE"

  if ! preflight_checks; then
    if [ "$OUTPUT_JSON" = "1" ]; then
      output_json
    fi
    exit 1
  fi

  if ! run_analysis; then
    if [ "$OUTPUT_JSON" = "1" ]; then
      output_json
    fi
    exit 1
  fi

  if ! run_tests; then
    if [ "$OUTPUT_JSON" = "1" ]; then
      output_json
    fi
    exit 1
  fi

  if ! build_apps; then
    if [ "$OUTPUT_JSON" = "1" ]; then
      output_json
    fi
    exit 1
  fi

  json_add "status" "success"
  print_summary

  exit 0
}

# Run main
main
