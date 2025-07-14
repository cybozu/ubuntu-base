# Tool version update automation for Docker images
# This Makefile provides automated version updates for various tools used in the Docker images.

.PHONY: update-tool-versions show-current-versions show-latest-versions help

# Tool definitions: TOOL_NAME:TYPE:SOURCE
# TYPE can be: github, awscli
# SOURCE: for github -> org/repo, for awscli -> (ignored)
TOOL_CONFIGS := \
	GRPCURL:github:fullstorydev/grpcurl \
	CRANE:github:google/go-containerregistry \
	AWSCLI:awscli: \
	GH:github:cli/cli

# Extract tool names from configurations
TOOLS := $(foreach config,$(TOOL_CONFIGS),$(word 1,$(subst :, ,$(config))))

# All Dockerfiles in the repository
ALL_DOCKERFILES := $(shell find . -name "Dockerfile" -path "*/ubuntu-*/Dockerfile")

# Helper functions to extract tool configuration parts
define get_tool_type
$(word 2,$(subst :, ,$(filter $1:%,$(TOOL_CONFIGS))))
endef

define get_tool_source
$(word 3,$(subst :, ,$(filter $1:%,$(TOOL_CONFIGS))))
endef

# Get latest version from GitHub releases API
define get_github_latest_version
$(shell curl -s https://api.github.com/repos/$1/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
endef

# Get latest AWS CLI version from changelog
define get_awscli_latest_version
$(shell curl -s https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst | head -10 | grep -E '^[0-9]+\.[0-9]+\.[0-9]+' | head -1)
endef

# Version fetching dispatch function
define get_latest_version
$(if $(filter github,$(call get_tool_type,$1)),\
	$(call get_github_latest_version,$(call get_tool_source,$1)),\
$(if $(filter awscli,$(call get_tool_type,$1)),\
	$(call get_awscli_latest_version),\
	$(error Unknown tool type for $1: $(call get_tool_type,$1))\
)\
)
endef

# Get current version from Dockerfile
define get_current_version
$(shell grep 'ARG $1_VERSION=' $(ALL_DOCKERFILES) | head -1 | cut -d'=' -f2 2>/dev/null || echo 'N/A')
endef

# Update version in Dockerfiles
define update_version
@echo "Updating $1_VERSION in all Dockerfiles..."
@sed -i 's/ARG $1_VERSION=.*/ARG $1_VERSION=$2/' $(ALL_DOCKERFILES)
endef

# Help target
help:
	@echo "Available targets:"
	@echo "  update-tool-versions    - Update all tool versions to latest"
	@echo "  show-current-versions   - Show current versions in Dockerfiles"
	@echo "  show-latest-versions    - Show latest available versions"
	@echo "  help                    - Show this help message"
	@echo ""
	@echo "Supported tools: $(TOOLS)"
	@echo ""
	@echo "Tool configurations:"
	@$(foreach config,$(TOOL_CONFIGS),\
		printf "  %-12s %s\n" "$(word 1,$(subst :, ,$(config))):" "$(word 2,$(subst :, ,$(config))) -> $(word 3,$(subst :, ,$(config)))";)

# Show current versions
show-current-versions:
	@echo "Current versions in Dockerfiles:"
	@$(foreach tool,$(TOOLS),echo "  $(tool)_VERSION: $(call get_current_version,$(tool))";)

# Show latest versions (without updating)
show-latest-versions:
	@echo "Fetching latest versions..."
	@$(foreach tool,$(TOOLS),\
		echo "  $(tool)_VERSION: $(call get_latest_version,$(tool))";)

# Main update target
update-tool-versions:
	@echo "=== Tool Version Update ==="
	@echo ""
	@echo "Current versions:"
	@$(foreach tool,$(TOOLS),echo "  $(tool)_VERSION: $(call get_current_version,$(tool))";)
	@echo ""
	@echo "Fetching latest versions..."
	@$(foreach tool,$(TOOLS),\
		$(eval LATEST_$(tool) := $(call get_latest_version,$(tool))))
	@echo "Latest versions:"
	@$(foreach tool,$(TOOLS),echo "  $(tool)_VERSION: $(LATEST_$(tool))";)
	@echo ""
	@echo "Updating Dockerfiles..."
	@$(foreach tool,$(TOOLS),$(call update_version,$(tool),$(LATEST_$(tool))))
	@echo ""
	@echo "✓ Tool versions updated successfully!"
	@echo ""
	@echo "Updated versions:"
	@$(foreach tool,$(TOOLS),echo "  $(tool)_VERSION: $(call get_current_version,$(tool))";)