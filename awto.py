#!/usr/bin/env python3
"""
awto-flutter-framework control script.
Single entry point for all project operations: testing, checking deps, running apps, etc.
"""

import subprocess
import sys
import os
from pathlib import Path
from datetime import datetime
import argparse
import shutil

REPO_ROOT = Path(__file__).parent
CLI_DIR = REPO_ROOT / "apps" / "cli"
GUI_DIR = REPO_ROOT / "apps" / "gui"
LOG_DIR = REPO_ROOT / "tmp"
LOG_FILE = LOG_DIR / "awto.log"


def log_message(msg: str, level: str = "INFO"):
    """Log message to console and file."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] [{level}] {msg}"
    print(log_entry)

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    with open(LOG_FILE, "a") as f:
        f.write(log_entry + "\n")


def run_command(cmd: list, cwd: Path, label: str = "") -> bool:
    """Run a command and return success status."""
    cmd_str = " ".join(cmd)
    log_message(f"$ {cmd_str} (in {cwd.name})", "RUN")

    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=False,
            timeout=300,
        )
        return result.returncode == 0
    except subprocess.TimeoutExpired:
        log_message(f"TIMEOUT: {label} (300s exceeded)", "ERROR")
        return False
    except Exception as e:
        log_message(f"ERROR: {label} - {e}", "ERROR")
        return False


# ============================================================================
# DEPENDENCY CHECKING
# ============================================================================


def cmd_check_deps(args):
    """Check dependencies for the project."""
    print("Checking dependencies for awto-flutter-framework")
    print("=" * 60)

    checks = [
        ("dart", "Dart SDK"),
        ("flutter", "Flutter SDK"),
        ("python3", "Python 3"),
    ]

    all_ok = True
    for cmd, name in checks:
        path = shutil.which(cmd)
        if path:
            print(f"✓ {name}: {path}")
        else:
            print(f"✗ {name}: NOT FOUND")
            all_ok = False

    print("\nChecking versions:")
    print("-" * 60)

    # Dart version
    try:
        result = subprocess.run(["dart", "--version"], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            version = result.stderr.strip() or result.stdout.strip()
            print(f"✓ Dart version: {version}")
        else:
            print(f"✗ Dart: version check failed")
            all_ok = False
    except Exception as e:
        print(f"✗ Dart: {e}")
        all_ok = False

    # Flutter version
    try:
        result = subprocess.run(["flutter", "--version"], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            version = lines[0] if lines else result.stdout.strip()
            print(f"✓ Flutter version: {version}")
        else:
            print(f"✗ Flutter: version check failed")
            all_ok = False
    except Exception as e:
        print(f"✗ Flutter: {e}")
        all_ok = False

    print("\n" + "=" * 60)
    if all_ok:
        print("✓ All dependencies OK")
        return 0
    else:
        print("✗ Some dependencies missing")
        print("\nInstall from:")
        print("  https://dart.dev/get-dart")
        print("  https://flutter.dev/docs/get-started/install")
        return 1


# ============================================================================
# TESTING
# ============================================================================


def cmd_test(args):
    """Run tests for CLI and/or GUI apps."""
    if LOG_FILE.exists():
        LOG_FILE.unlink()

    log_message("Test run started", "START")
    log_message(f"Testing: {args.app}", "CONFIG")

    results = {}

    if args.app in ["cli", "all"]:
        print("\n" + "=" * 60)
        print("Testing CLI app")
        print("=" * 60)
        log_message("Testing CLI", "TEST")

        if run_command(["dart", "pub", "get"], CLI_DIR, "CLI pub get"):
            log_message("CLI dependencies OK", "OK")
        else:
            log_message("CLI dependencies FAILED", "ERROR")
            return 1

        if run_command(["dart", "test"], CLI_DIR, "CLI tests"):
            print("✓ CLI tests PASSED")
            log_message("CLI tests PASSED", "OK")
            results["cli"] = True
        else:
            print("✗ CLI tests FAILED")
            log_message("CLI tests FAILED", "ERROR")
            results["cli"] = False

    if args.app in ["gui", "all"]:
        print("\n" + "=" * 60)
        print("Testing GUI app")
        print("=" * 60)
        log_message("Testing GUI", "TEST")

        if run_command(["flutter", "pub", "get"], GUI_DIR, "GUI pub get"):
            log_message("GUI dependencies OK", "OK")
        else:
            log_message("GUI dependencies FAILED", "ERROR")
            return 1

        if run_command(["flutter", "test"], GUI_DIR, "GUI tests"):
            print("✓ GUI tests PASSED")
            log_message("GUI tests PASSED", "OK")
            results["gui"] = True
        else:
            print("✗ GUI tests FAILED")
            log_message("GUI tests FAILED", "ERROR")
            results["gui"] = False

    if args.analyze:
        print("\n" + "=" * 60)
        print("Code Analysis")
        print("=" * 60)
        log_message("Running analysis", "ANALYZE")

        analyze_ok = True
        if run_command(["dart", "analyze"], CLI_DIR, "CLI analyze"):
            print("✓ CLI analysis OK")
            log_message("CLI analysis OK", "OK")
        else:
            print("✗ CLI analysis FAILED")
            log_message("CLI analysis FAILED", "ERROR")
            analyze_ok = False

        if run_command(["flutter", "analyze"], GUI_DIR, "GUI analyze"):
            print("✓ GUI analysis OK")
            log_message("GUI analysis OK", "OK")
        else:
            print("✗ GUI analysis FAILED")
            log_message("GUI analysis FAILED", "ERROR")
            analyze_ok = False

        results["analyze"] = analyze_ok

    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)

    all_passed = all(results.values())
    for name, passed in results.items():
        status = "✓ PASS" if passed else "✗ FAIL"
        print(f"{name}: {status}")

    print(f"\nLog file: {LOG_FILE}")

    return 0 if all_passed else 1


# ============================================================================
# RUN / LAUNCH APPS
# ============================================================================


def cmd_run(args):
    """Run an app (CLI or GUI)."""
    if args.app == "cli":
        print("Launching CLI demo app...")
        return run_command(
            ["dart", "run", "bin/main.dart", args.command or "help"],
            CLI_DIR,
            "CLI run",
        )
    elif args.app == "gui":
        print("Launching GUI demo app (Linux desktop)...")
        return run_command(
            ["flutter", "run", "-d", "linux"],
            GUI_DIR,
            "GUI run",
        )
    else:
        print("Error: Specify --app cli or --app gui")
        return 1


# ============================================================================
# CLEAN
# ============================================================================


def cmd_clean(args):
    """Clean build artifacts and caches."""
    print("Cleaning build artifacts...")

    for app_dir in [CLI_DIR, GUI_DIR]:
        if (app_dir / "build").exists():
            print(f"Removing {app_dir / 'build'}")
            import shutil
            shutil.rmtree(app_dir / "build", ignore_errors=True)

        if (app_dir / ".dart_tool").exists():
            print(f"Removing {app_dir / '.dart_tool'}")
            import shutil
            shutil.rmtree(app_dir / ".dart_tool", ignore_errors=True)

    if (LOG_DIR / "*.log").exists():
        print(f"Cleaning logs in {LOG_DIR}")
        import glob
        for log in glob.glob(str(LOG_DIR / "*.log")):
            Path(log).unlink()

    print("✓ Clean complete")
    return 0


# ============================================================================
# MAIN
# ============================================================================


def main():
    parser = argparse.ArgumentParser(
        description="awto-flutter-framework control script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s check-deps                    # Check dependencies
  %(prog)s test --app cli                # Test CLI app only
  %(prog)s test --app all --analyze      # Test all and analyze
  %(prog)s run --app cli counter         # Run CLI counter command
  %(prog)s run --app gui                 # Run GUI app
  %(prog)s clean                         # Clean build artifacts
        """,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # check-deps command
    check_parser = subparsers.add_parser("check-deps", help="Check project dependencies")
    check_parser.set_defaults(func=cmd_check_deps)

    # test command
    test_parser = subparsers.add_parser("test", help="Run tests")
    test_parser.add_argument(
        "--app",
        choices=["cli", "gui", "all"],
        default="all",
        help="Which app to test (default: all)",
    )
    test_parser.add_argument(
        "--analyze",
        action="store_true",
        default=True,
        help="Run code analysis (default: true)",
    )
    test_parser.set_defaults(func=cmd_test)

    # run command
    run_parser = subparsers.add_parser("run", help="Run an app")
    run_parser.add_argument(
        "--app",
        choices=["cli", "gui"],
        required=True,
        help="Which app to run",
    )
    run_parser.add_argument(
        "command",
        nargs="?",
        help="CLI command to run (counter, todo, fetch, timer, ports)",
    )
    run_parser.set_defaults(func=cmd_run)

    # clean command
    clean_parser = subparsers.add_parser("clean", help="Clean build artifacts")
    clean_parser.set_defaults(func=cmd_clean)

    # Default to test if no command
    if len(sys.argv) == 1:
        parser.print_help()
        return 0

    args = parser.parse_args()

    if hasattr(args, "func"):
        return args.func(args)
    else:
        parser.print_help()
        return 0


if __name__ == "__main__":
    sys.exit(main())
