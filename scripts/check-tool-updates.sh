#!/bin/bash
set -uo pipefail

# Check if any tools need updates
# Requires: OUTPUT_FILE, CURRENT_FILE, LATEST_FILE environment variables

if [ -z "${OUTPUT_FILE:-}" ] || [ -z "${CURRENT_FILE:-}" ] || [ -z "${LATEST_FILE:-}" ]; then
    echo "Error: OUTPUT_FILE, CURRENT_FILE, and LATEST_FILE environment variables are required" >&2
    exit 1
fi

# Initialize empty YAML object for updates
echo "{}" > "${OUTPUT_FILE}"

updates_needed=false

# Get tool names from current versions
yq 'keys[]' "${CURRENT_FILE}" | while read -r tool_name; do
    # Get latest version for this tool
    latest_version=$(yq ".$tool_name" "${LATEST_FILE}" 2>/dev/null)
    
    # Skip if latest version is empty
    if [ -z "$latest_version" ]; then
        continue
    fi
    
    # Check each dockerfile for this tool
    tool_needs_update=false
    dockerfiles_to_update=""
    
    # Get the number of dockerfiles for this tool
    dockerfile_count=$(yq ".$tool_name.dockerfiles | length" "${CURRENT_FILE}" 2>/dev/null || echo "0")
    
    # Check each dockerfile
    for i in $(seq 0 $((dockerfile_count - 1))); do
        current_version=$(yq ".$tool_name.dockerfiles[$i].version" "${CURRENT_FILE}" 2>/dev/null)
        dockerfile_path=$(yq ".$tool_name.dockerfiles[$i].path" "${CURRENT_FILE}" 2>/dev/null)
        
        # Skip if current version is empty
        if [ -z "$current_version" ]; then
            continue
        fi
        
        # Compare versions
        if [ "$current_version" != "$latest_version" ]; then
            if [ "$tool_needs_update" = false ]; then
                # Create tool entry on first update needed
                yq eval ".$tool_name = {\"latest\": \"$latest_version\", \"dockerfiles\": []}" -i "${OUTPUT_FILE}"
                tool_needs_update=true
                echo "  $tool_name: $latest_version"
            fi
            
            # Add dockerfile entry with current and latest versions
            yq eval ".$tool_name.dockerfiles += [{\"path\": \"$dockerfile_path\", \"current\": \"$current_version\", \"latest\": \"$latest_version\"}]" -i "${OUTPUT_FILE}"
            dockerfiles_to_update="$dockerfiles_to_update $dockerfile_path"
            updates_needed=true
        fi
    done
    
    # Print summary for this tool if updates needed
    if [ "$tool_needs_update" = true ]; then
        echo "    Dockerfiles: $dockerfiles_to_update"
    fi
done

# Check if any updates were found
if ! $updates_needed; then
    echo "  No updates needed - all tools are up to date!"
fi

echo ""
echo "Updates written to: ${OUTPUT_FILE}" >&2
echo "Run 'task update-tool-versions OUTPUT_FILE=${OUTPUT_FILE}' to apply updates." >&2