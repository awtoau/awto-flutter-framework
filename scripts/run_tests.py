#!/usr/bin/env python3
"""
Test runner for awto-flutter-framework demo apps.
Runs tests for CLI and/or GUI apps and reports results.
"""

import subprocess
import sys
import os
from pathlib import Path
from datetime import datetime
import argparse

REPO_ROOT = Path(__file__).parent.parent
CLI_DIR = REPO_ROOT / "apps" / "cli"
GUI_DIR = REPO_ROOT / "apps" / "gui"
LOG_DIR = REPO_ROOT / "tmp"
LOG_FILE = LOG_DIR / "test-results.log"


def log_message(msg: str, level: str = "INFO"):
    """Log message to console and file."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] [{level}] {msg}"
    print(log_entry)

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    with open(LOG_FILE, "a") as f:
        f.write(log_entry + "\n")


def run_command(cmd: list, cwd: Path, app_name: str) -> bool:
    """Run a command and return success status."""
    log_message(f"Running: {' '.join(cmd)} in {cwd}", "RUN")

    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=300,
        )

        if result.stdout:
            log_message(f"[{app_name} OUT] {result.stdout}", "OUTPUT")
        if result.stderr:
            log_message(f"[{app_name} ERR] {result.stderr}", "OUTPUT")

        success = result.returncode == 0
        status = "PASS" if success else "FAIL"
        log_message(f"{app_name}: {status} (exit code: {result.returncode})", status)
        return success

    except subprocess.TimeoutExpired:
        log_message(f"{app_name}: TIMEOUT (300s exceeded)", "FAIL")
        return False
    except Exception as e:
        log_message(f"{app_name}: ERROR - {e}", "ERROR")
        return False


def test_cli() -> bool:
    """Test CLI app."""
    log_message("=" * 60, "INFO")
    log_message("Testing CLI app", "INFO")
    log_message("=" * 60, "INFO")

    # Get dependencies
    if not run_command(["dart", "pub", "get"], CLI_DIR, "CLI pub get"):
        return False

    # Run tests
    return run_command(["dart", "test"], CLI_DIR, "CLI tests")


def test_gui() -> bool:
    """Test GUI app."""
    log_message("=" * 60, "INFO")
    log_message("Testing GUI app", "INFO")
    log_message("=" * 60, "INFO")

    # Get dependencies
    if not run_command(["flutter", "pub", "get"], GUI_DIR, "GUI pub get"):
        return False

    # Run tests
    return run_command(["flutter", "test"], GUI_DIR, "GUI tests")


def analyze() -> bool:
    """Run code analysis."""
    log_message("=" * 60, "INFO")
    log_message("Running code analysis", "INFO")
    log_message("=" * 60, "INFO")

    success = True

    # Analyze CLI
    if not run_command(["dart", "analyze"], CLI_DIR, "CLI analyze"):
        success = False

    # Analyze GUI
    if not run_command(["flutter", "analyze"], GUI_DIR, "GUI analyze"):
        success = False

    return success


def main():
    parser = argparse.ArgumentParser(
        description="Run tests for awto-flutter-framework apps"
    )
    parser.add_argument(
        "--app",
        choices=["cli", "gui", "all"],
        default="all",
        help="Which app to test (default: all)",
    )
    parser.add_argument(
        "--coverage",
        action="store_true",
        help="Enable coverage reporting (not yet implemented)",
    )
    parser.add_argument(
        "--analyze",
        action="store_true",
        default=True,
        help="Run code analysis (default: true)",
    )

    args = parser.parse_args()

    # Clear log file
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    if LOG_FILE.exists():
        LOG_FILE.unlink()

    log_message(f"Test runner started at {datetime.now()}", "START")
    log_message(f"Testing: {args.app}", "CONFIG")

    results = {}

    if args.app in ["cli", "all"]:
        results["cli"] = test_cli()

    if args.app in ["gui", "all"]:
        results["gui"] = test_gui()

    if args.analyze:
        results["analyze"] = analyze()

    # Summary
    log_message("=" * 60, "INFO")
    log_message("TEST SUMMARY", "SUMMARY")
    log_message("=" * 60, "INFO")

    for name, passed in results.items():
        status = "✓ PASS" if passed else "✗ FAIL"
        log_message(f"{name}: {status}", "SUMMARY")

    all_passed = all(results.values())
    log_message(f"Overall: {'✓ ALL PASSED' if all_passed else '✗ FAILURES'}", "SUMMARY")
    log_message(f"Log file: {LOG_FILE}", "INFO")

    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())
