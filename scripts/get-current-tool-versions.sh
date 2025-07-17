#!/bin/bash
set -uo pipefail

# Get current tool versions in YAML format
# Requires: OUTPUT_FILE, DOCKERFILES, TOOLS_YAML environment variables

if [ -z "${OUTPUT_FILE:-}" ]; then
    echo "Error: OUTPUT_FILE environment variable is required" >&2
    exit 1
fi

if [ -z "${DOCKERFILES:-}" ]; then
    echo "Error: DOCKERFILES environment variable is required" >&2
    exit 1
fi

if [ -z "${TOOLS_YAML:-}" ]; then
    echo "Error: TOOLS_YAML environment variable is required" >&2
    exit 1
fi

# Initialize empty YAML object
echo "{}" > "${OUTPUT_FILE}"

# Use yq to properly parse YAML and extract tool names
yq '.[] | .name' "${TOOLS_YAML}" | while read -r tool_name; do
    # Create tool entry with dockerfiles array
    yq eval ".$tool_name = {\"dockerfiles\": []}" -i "${OUTPUT_FILE}"
    
    # Check each Dockerfile for this tool's version
    while IFS= read -r dockerfile; do
        [ -z "$dockerfile" ] && continue
        version=$(grep "ARG ${tool_name}_VERSION=" "$dockerfile" 2>/dev/null | head -1 | cut -d'=' -f2)
        if [ -n "$version" ]; then
            # Add dockerfile entry using yq
            yq eval ".$tool_name.dockerfiles += [{\"path\": \"$dockerfile\", \"version\": \"$version\"}]" -i "${OUTPUT_FILE}"
        fi
    done <<< "${DOCKERFILES}"
done

echo "Current versions written to: ${OUTPUT_FILE}" >&2