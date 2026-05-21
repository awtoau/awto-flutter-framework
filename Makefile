.PHONY: help setup clean test analyze format build run docs

# Default target
help:
	@echo "awto-flutter-framework - Available commands:"
	@echo ""
	@echo "Setup & Dependencies:"
	@echo "  make setup          - Install dependencies for all apps"
	@echo "  make clean          - Clean all builds and caches"
	@echo ""
	@echo "Testing:"
	@echo "  make test           - Run all tests"
	@echo "  make test-cli       - Run CLI app tests"
	@echo "  make test-gui       - Run GUI app tests"
	@echo "  make test-error     - Run error handling tests"
	@echo ""
	@echo "Code Quality:"
	@echo "  make analyze        - Run code analysis"
	@echo "  make format         - Auto-format code"
	@echo "  make format-check   - Check code formatting (no changes)"
	@echo ""
	@echo "Building:"
	@echo "  make build-cli      - Build CLI executable"
	@echo "  make build-gui-apk  - Build GUI APK (Android)"
	@echo "  make build-gui-ios  - Build GUI IPA (iOS)"
	@echo "  make build-gui-web  - Build GUI web app"
	@echo ""
	@echo "Running:"
	@echo "  make run-cli        - Run CLI app"
	@echo "  make run-gui        - Run GUI app"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs           - Show available docs"
	@echo ""

# Setup targets
setup:
	cd apps/cli && dart pub get && cd ..
	cd apps/gui && flutter pub get && cd ..
	@echo "✓ Dependencies installed"

setup-cli:
	cd apps/cli && dart pub get && cd ..

setup-gui:
	cd apps/gui && flutter pub get && cd ..

clean:
	cd apps/cli && dart pub cache clean && cd ..
	cd apps/gui && flutter clean && cd ..
	rm -rf tmp/*
	@echo "✓ Cleaned build artifacts and cache"

# Testing targets
test: test-cli test-gui test-error
	@echo "✓ All tests passed"

test-cli:
	@echo "Testing CLI app..."
	cd apps/cli && dart test

test-gui:
	@echo "Testing GUI app..."
	cd apps/gui && flutter test

test-error:
	@echo "Testing error handling..."
	cd apps/cli && dart test test/error_handling_test.dart

test-watch:
	cd apps/cli && dart test --watch

test-coverage:
	cd apps/cli && dart test --coverage=coverage && cd ..
	@echo "Coverage report generated in apps/cli/coverage/"

# Code quality targets
analyze: analyze-cli analyze-gui
	@echo "✓ Code analysis complete"

analyze-cli:
	@echo "Analyzing CLI app..."
	cd apps/cli && dart analyze && cd ..

analyze-gui:
	@echo "Analyzing GUI app..."
	cd apps/gui && flutter analyze && cd ..

format: format-cli format-gui
	@echo "✓ Code formatted"

format-cli:
	dart format -i apps/cli/lib apps/cli/test

format-gui:
	dart format -i apps/gui/lib apps/gui/test

format-check:
	@echo "Checking code formatting..."
	dart format --set-exit-if-changed apps/cli/lib apps/cli/test apps/gui/lib apps/gui/test
	@echo "✓ Code formatting is correct"

# Build targets
build-cli:
	@echo "Building CLI executable..."
	cd apps/cli && dart compile exe lib/main.dart -o ../build/awto_cli_demo && cd ..
	@echo "✓ Built: build/awto_cli_demo"

build-gui-apk:
	@echo "Building GUI APK..."
	cd apps/gui && flutter build apk --release && cd ..
	@echo "✓ Built: apps/gui/build/app/outputs/flutter-apk/app-release.apk"

build-gui-ios:
	@echo "Building GUI IPA..."
	cd apps/gui && flutter build ios --release && cd ..
	@echo "✓ Built: apps/gui/build/ios/iphoneos/Runner.app"

build-gui-web:
	@echo "Building GUI web..."
	cd apps/gui && flutter build web --release && cd ..
	@echo "✓ Built: apps/gui/build/web/"

# Run targets
run-cli:
	cd apps/cli && dart run && cd ..

run-gui:
	cd apps/gui && flutter run && cd ..

run-gui-chrome:
	cd apps/gui && flutter run -d chrome && cd ..

# Documentation targets
docs:
	@echo "Available documentation:"
	@echo ""
	@echo "Getting Started:"
	@echo "  - docs/QUICKSTART.md          Quick setup guide (5 minutes)"
	@echo ""
	@echo "Development:"
	@echo "  - ARCHITECTURE.md             Project structure & patterns"
	@echo "  - CONTRIBUTING.md             Development workflow"
	@echo "  - CODE_CONVENTIONS.md         Naming & code style"
	@echo "  - STANDARDS.md                State management guidelines"
	@echo ""
	@echo "Building & Deployment:"
	@echo "  - docs/BUILD.md               Local build instructions"
	@echo "  - docs/DEPLOYMENT.md          Deployment & CI/CD guide"
	@echo ""
	@echo "Support:"
	@echo "  - docs/TROUBLESHOOTING.md     Common issues & solutions"
	@echo "  - README.md                   Project overview"
	@echo ""
	@echo "Decisions:"
	@echo "  - docs/adr/README.md          Architecture Decision Records"
	@echo ""

open-docs:
	@echo "Opening documentation..."
	open README.md
	open ARCHITECTURE.md
	open CONTRIBUTING.md
	open CODE_CONVENTIONS.md

# CI/CD targets
ci: analyze test format-check
	@echo "✓ CI checks passed"

# Utility targets
version:
	@echo "Flutter version:"
	@flutter --version
	@echo ""
	@echo "Dart version:"
	@dart --version

status:
	@echo "Git status:"
	@git status --short
	@echo ""
	@echo "Recent commits:"
	@git log --oneline -5

.SILENT: help docs version
