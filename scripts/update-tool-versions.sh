#!/bin/bash
set -uo pipefail

# Update tool versions based on updates file
# Requires: UPDATES_FILE environment variable

if [ -z "${UPDATES_FILE:-}" ]; then
    echo "Error: UPDATES_FILE environment variable is required" >&2
    exit 1
fi

# Check if updates file exists and has content
if [ ! -f "${UPDATES_FILE}" ]; then
    echo "Error: Updates file ${UPDATES_FILE} not found!"
    exit 1
fi

# Check if there are any updates to apply
update_count=$(yq 'keys | length' "${UPDATES_FILE}" 2>/dev/null || echo "0")
if [ "$update_count" = "0" ]; then
    echo "No updates to apply - all tools are up to date!"
    exit 0
fi

echo "Found $update_count tool(s) to update"
echo ""

# Process each tool that needs updates
yq 'keys[]' "${UPDATES_FILE}" | while read -r tool_name; do
    latest_version=$(yq ".$tool_name.latest" "${UPDATES_FILE}")
    echo "Updating $tool_name to version $latest_version..."
    
    # Get the number of dockerfiles for this tool
    dockerfile_count=$(yq ".$tool_name.dockerfiles | length" "${UPDATES_FILE}" 2>/dev/null || echo "0")
    
    # Update each dockerfile
    for i in $(seq 0 $((dockerfile_count - 1))); do
        dockerfile_path=$(yq ".$tool_name.dockerfiles[$i].path" "${UPDATES_FILE}")
        current_version=$(yq ".$tool_name.dockerfiles[$i].current" "${UPDATES_FILE}")
        
        echo "  Updating $dockerfile_path: $current_version -> $latest_version"
        
        # Perform the actual update
        sed -i "s/ARG ${tool_name}_VERSION=.*/ARG ${tool_name}_VERSION=$latest_version/" "$dockerfile_path"
    done
    
    echo ""
done

echo "✓ Tool versions updated successfully!"