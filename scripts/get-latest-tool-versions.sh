#!/bin/bash
set -euo pipefail

# Get latest available tool versions in YAML format
# Requires: OUTPUT_FILE, TOOLS_YAML environment variables

if [ -z "${OUTPUT_FILE:-}" ]; then
    echo "Error: OUTPUT_FILE environment variable is required" >&2
    exit 1
fi

if [ -z "${TOOLS_YAML:-}" ]; then
    echo "Error: TOOLS_YAML environment variable is required" >&2
    exit 1
fi

# Initialize empty YAML object
echo "{}" > "${OUTPUT_FILE}"

# Use yq to properly parse YAML and extract tool information
yq '.[] | .name' "${TOOLS_YAML}" | while read -r tool_name; do
    tool_type=$(yq ".[] | select(.name == \"$tool_name\") | .version.type" "${TOOLS_YAML}")
    tool_repo=$(yq ".[] | select(.name == \"$tool_name\") | .version.repo // \"\"" "${TOOLS_YAML}" 2>/dev/null || echo "")
    tool_expr=$(yq ".[] | select(.name == \"$tool_name\") | .version.expr // \"\"" "${TOOLS_YAML}" 2>/dev/null || echo "")
    # Get latest version based on type
    case "$tool_type" in
        github)
            if [ -n "$tool_repo" ]; then
                version=$(gh release view --repo "$tool_repo" --json tagName --jq '.tagName' 2>/dev/null | sed 's/v//' || echo "")
                if [ -z "$version" ]; then
                    echo "Error: Failed to get latest version for $tool_name" >&2
                    exit 1
                fi
            else
                echo "Error: No repo specified for $tool_name" >&2
                exit 1
            fi
            ;;
        custom)
            if [ -n "$tool_expr" ]; then
                version=$(eval "$tool_expr" 2>/dev/null || echo "")
                if [ -z "$version" ]; then
                    echo "Error: Failed to evaluate expression for $tool_name" >&2
                    exit 1
                fi
            else
                echo "Error: No expression specified for $tool_name" >&2
                exit 1
            fi
            ;;
        *)
            echo "Error: Unknown type $tool_type for $tool_name" >&2
            exit 1
            ;;
    esac
    
    # Set tool name to version directly
    yq eval ".$tool_name = \"$version\"" -i "${OUTPUT_FILE}"
done

echo "Latest versions written to: ${OUTPUT_FILE}" >&2
