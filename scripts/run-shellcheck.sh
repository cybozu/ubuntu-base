#!/bin/bash
set -uo pipefail

# Check shell scripts in the scripts directory with shellcheck

echo "Checking shell scripts in scripts/ directory..."
find scripts/ -name "*.sh" -type f | while read -r script; do
    echo "Checking $script..."
    shellcheck -s bash "$script"
done
echo "✓ All shell scripts checked successfully!"
