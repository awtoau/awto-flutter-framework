# Build and Deploy Script

Complete guide for using the `scripts/build-deploy.sh` script.

## Overview

The build-deploy script is a single entry point for:
- Checking dependencies
- Running code analysis
- Running tests
- Building applications
- Generating clean, machine-readable output

Designed for:
- ✅ CI/CD pipelines
- ✅ AI-driven automation
- ✅ Automated build systems
- ✅ Downstream processing (JSON output)

## Quick Start

```bash
# Build everything (analysis + tests + build)
./scripts/build-deploy.sh

# Build only GUI app
./scripts/build-deploy.sh --app gui

# Build only CLI app
./scripts/build-deploy.sh --app cli

# Debug build (instead of release)
./scripts/build-deploy.sh --type debug

# JSON output for machine parsing
./scripts/build-deploy.sh --json
```

## Options

```bash
./scripts/build-deploy.sh [OPTIONS]

Options:
  --app APP           CLI or GUI (default: both)
  --type TYPE         debug or release (default: release)
  --json              Output in JSON format (machine-readable)
  --no-color          Disable colored output
  --no-logs           Disable file logging
  --help              Show help message
```

## Output Formats

### Plain Text Output (Default)

```
[2026-05-21 10:30:45] [SECTION] Pre-flight Checks

✓ Flutter found: Flutter 3.10.0
✓ Dart found: Dart SDK version: 3.10.0
✓ CLI dependencies resolved
✓ GUI dependencies resolved

=== Code Analysis ===

✓ CLI analysis passed
✓ GUI analysis passed

=== Running Tests ===

✓ CLI tests passed
✓ GUI tests passed

=== Building ===

✓ CLI built in 25s
✓ GUI built in 180s
Total build time: 205s

=== Summary ===

Status: SUCCESS
Build Type: release
App(s): both
Log file: ./tmp/build-deploy-1716276645.log
```

### JSON Output (--json flag)

```json
{
  "timestamp": "2026-05-21T10:30:45Z",
  "app": "both",
  "build_type": "release",
  "flutter_version": "Flutter 3.10.0",
  "dart_version": "Dart SDK version: 3.10.0",
  "cli_build_time_seconds": "25",
  "gui_build_time_seconds": "180",
  "total_build_time_seconds": "205",
  "status": "success"
}
```

## Exit Codes

- `0` — Success
- `1` — Failure (check logs or output for details)

## Logging

All output is logged to `./tmp/build-deploy-TIMESTAMP.log` by default.

To disable logging:
```bash
./scripts/build-deploy.sh --no-logs
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Build and Deploy
  run: ./scripts/build-deploy.sh --json | tee build-output.json

- name: Parse Results
  run: |
    STATUS=$(jq -r '.status' build-output.json)
    BUILD_TIME=$(jq -r '.total_build_time_seconds' build-output.json)
    if [ "$STATUS" = "success" ]; then
      echo "Build successful in ${BUILD_TIME}s"
    else
      echo "Build failed"
      exit 1
    fi
```

### GitLab CI

```yaml
build:
  script:
    - ./scripts/build-deploy.sh --json > build-output.json
  artifacts:
    reports:
      custom: build-output.json
```

### Local CI Integration

```bash
#!/bin/bash
set -e

# Run build/deploy with JSON output
OUTPUT=$(./scripts/build-deploy.sh --json --app cli --type release)

# Parse JSON
STATUS=$(echo "$OUTPUT" | jq -r '.status')
BUILD_TIME=$(echo "$OUTPUT" | jq -r '.cli_build_time_seconds')

if [ "$STATUS" != "success" ]; then
  echo "Build failed!"
  exit 1
fi

echo "Build successful in ${BUILD_TIME}s"
```

## Parsing Output

### With jq

```bash
# Extract status
./scripts/build-deploy.sh --json | jq '.status'

# Extract build time
./scripts/build-deploy.sh --json | jq '.total_build_time_seconds'

# Extract all timing info
./scripts/build-deploy.sh --json | jq '{cli_time: .cli_build_time_seconds, gui_time: .gui_build_time_seconds}'
```

### With grep/awk

```bash
# Extract specific fields from plain text
./scripts/build-deploy.sh --no-color | grep "Status:"

# Parse timing
./scripts/build-deploy.sh --no-color | grep "Total build time"
```

### With Python

```python
import json
import subprocess

result = subprocess.run(
    ['./scripts/build-deploy.sh', '--json'],
    capture_output=True,
    text=True
)

data = json.loads(result.stdout)
print(f"Build status: {data['status']}")
print(f"Build time: {data['total_build_time_seconds']}s")
```

## Troubleshooting

### Script Not Found

```bash
chmod +x scripts/build-deploy.sh
```

### Permission Denied

```bash
chmod +x scripts/build-deploy.sh
./scripts/build-deploy.sh
```

### Flutter Not Found

```bash
# Ensure Flutter is in PATH
export PATH="$PATH:~/flutter/bin"

# Or use full path
~/flutter/bin/flutter --version
```

### Build Fails

Check the log file:
```bash
tail -f tmp/build-deploy-*.log
```

Or run with verbose output:
```bash
./scripts/build-deploy.sh --app cli --type release
```

## Advanced Usage

### Conditional Build Based on Output

```bash
#!/bin/bash
OUTPUT=$(./scripts/build-deploy.sh --json --app gui)
STATUS=$(echo "$OUTPUT" | jq -r '.status')

if [ "$STATUS" = "success" ]; then
  # Deploy
  echo "Deploying..."
else
  # Alert
  echo "Build failed, not deploying"
  exit 1
fi
```

### Batch Testing Multiple Configurations

```bash
#!/bin/bash
for app in cli gui; do
  for type in debug release; do
    echo "Building $app ($type)..."
    ./scripts/build-deploy.sh --app "$app" --type "$type" --json | jq '.status'
  done
done
```

### Monitor Build Times

```bash
#!/bin/bash
while true; do
  OUTPUT=$(./scripts/build-deploy.sh --json)
  TIME=$(echo "$OUTPUT" | jq -r '.total_build_time_seconds')
  echo "$(date): Build took ${TIME}s"
  sleep 3600  # Hourly builds
done
```

## Environment Variables

```bash
# Disable colors globally
NO_COLOR=1 ./scripts/build-deploy.sh

# Or use flag
./scripts/build-deploy.sh --no-color
```

## Integration with Makefile

```makefile
build-deploy:
	./scripts/build-deploy.sh

build-deploy-json:
	./scripts/build-deploy.sh --json

build-deploy-watch:
	while true; do \
	  ./scripts/build-deploy.sh; \
	  sleep 300; \
	done
```

## Output Validation

Ensure output matches expected schema:

```bash
#!/bin/bash
OUTPUT=$(./scripts/build-deploy.sh --json)

# Validate required fields
for field in status timestamp app build_type total_build_time_seconds; do
  if ! echo "$OUTPUT" | jq -e ".$field" > /dev/null; then
    echo "Missing field: $field"
    exit 1
  fi
done

echo "Output validation passed"
```

## References

- [Build Documentation](BUILD.md)
- [Deployment Guide](DEPLOYMENT.md)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [jq Manual](https://stedolan.github.io/jq/)
