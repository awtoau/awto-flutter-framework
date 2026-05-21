#!/usr/bin/env python3
"""
Check dependencies for awto-flutter-framework testing.
Verifies Flutter, Dart SDK, and other required tools are installed.
"""

import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent


def check_command(cmd: str, name: str) -> bool:
    """Check if a command exists in PATH."""
    try:
        result = subprocess.run(
            ["which", cmd],
            capture_output=True,
            timeout=5,
        )
        if result.returncode == 0:
            path = result.stdout.decode().strip()
            print(f"✓ {name}: {path}")
            return True
        else:
            print(f"✗ {name}: NOT FOUND")
            return False
    except Exception as e:
        print(f"✗ {name}: ERROR - {e}")
        return False


def check_dart_version() -> bool:
    """Check Dart version."""
    try:
        result = subprocess.run(
            ["dart", "--version"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            version = result.stderr.strip() or result.stdout.strip()
            print(f"✓ Dart version: {version}")
            return True
        else:
            print(f"✗ Dart: version check failed")
            return False
    except Exception as e:
        print(f"✗ Dart: ERROR - {e}")
        return False


def check_flutter_version() -> bool:
    """Check Flutter version."""
    try:
        result = subprocess.run(
            ["flutter", "--version"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            version = lines[0] if lines else result.stdout.strip()
            print(f"✓ Flutter version: {version}")
            return True
        else:
            print(f"✗ Flutter: version check failed")
            return False
    except Exception as e:
        print(f"✗ Flutter: ERROR - {e}")
        return False


def check_linux_support() -> bool:
    """Check if Linux desktop is enabled in Flutter."""
    try:
        result = subprocess.run(
            ["flutter", "devices"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if "linux" in result.stdout.lower():
            print(f"✓ Linux desktop support: enabled")
            return True
        else:
            print(f"⚠ Linux desktop support: may not be enabled")
            return True  # Don't fail on this
    except Exception as e:
        print(f"⚠ Linux desktop check: {e}")
        return True  # Don't fail on this


def main():
    print("Checking dependencies for awto-flutter-framework")
    print("=" * 60)

    checks = [
        ("dart", "Dart SDK"),
        ("flutter", "Flutter SDK"),
        ("python3", "Python 3"),
    ]

    all_ok = True
    for cmd, name in checks:
        if not check_command(cmd, name):
            all_ok = False

    print("\nChecking versions:")
    print("-" * 60)

    if not check_dart_version():
        all_ok = False

    if not check_flutter_version():
        all_ok = False

    print("\nChecking platform support:")
    print("-" * 60)

    check_linux_support()

    print("\n" + "=" * 60)
    if all_ok:
        print("✓ All dependencies OK")
        return 0
    else:
        print("✗ Some dependencies are missing")
        print("\nTo install:")
        print("  - Dart: https://dart.dev/get-dart")
        print("  - Flutter: https://flutter.dev/docs/get-started/install")
        return 1


if __name__ == "__main__":
    sys.exit(main())
