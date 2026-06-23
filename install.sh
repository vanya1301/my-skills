#!/bin/bash
set -e

# Shared skills directory - the single source of truth for all agents
DEFAULT_SHARED_SKILLS_DIR="$HOME/.config/ai-skills"

# Agent configuration - mapping of agent names to their config methods
# Each agent can use either:
# - "symlink": Create symlink from agent location to shared directory
# - "config": Generate config file pointing to shared directory
# - "direct": Install directly to the agent's native location

default_framework="shared"

# Parse arguments
frameworks=""
install_all="false"
use_shared="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --framework|-f)
            frameworks="$2"
            shift 2
            ;;
        --all|-a)
            install_all="true"
            shift
            ;;
        --shared|--global|-g)
            use_shared="true"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --framework <name>, -f <name>  Install to specific agent (default: installs to shared location)"
            echo "                                 Available: opencode"
            echo "  --all, -a                      Install to all detected agents"
            echo "  --shared, --global, -g         Install to shared directory (~/.config/ai-skills)"
            echo "  --help, -h                     Show this help"
            echo ""
            echo "Installation Methods:"
            echo "  1. Shared directory (default): Creates ONE global skills directory"
            echo "     Location: ~/.config/ai-skills/"
            echo "     OpenCode gets symlinked to this location"
            echo ""
            echo "Environment variables:"
            echo "  SHARED_SKILLS_DIR=<path>       Override shared skills directory"
            echo "  OPENCODE_SKILLS_DIR=<path>     Override OpenCode install location"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check for shared dir override
SHARED_SKILLS_DIR="${SHARED_SKILLS_DIR:-$DEFAULT_SHARED_SKILLS_DIR}"

# Use framework from env var if set
if [[ -n "$AGENT_FRAMEWORK" ]]; then
    frameworks="$AGENT_FRAMEWORK"
fi

# Default to shared installation
if [[ "$use_shared" == "true" ]] || [[ -z "$frameworks" && "$install_all" == "false" ]]; then
    use_shared="true"
fi

REPO="vanya1301/my-skills"

# Download and verify once
echo "Downloading skills archive..."
curl -L "https://github.com/$REPO/releases/latest/download/skills.tar.gz" -o /tmp/skills.tar.gz

echo "Verifying checksum..."
curl -L "https://github.com/$REPO/releases/latest/download/skills.tar.gz.sha256" -o /tmp/skills.tar.gz.sha256
cd /tmp && sha256sum -c skills.tar.gz.sha256

# Determine installation targets
targets=""  # will contain "dir:path" pairs

if [[ "$use_shared" == "true" ]]; then
    targets="shared:${SHARED_SKILLS_DIR}"
    echo "Will install to shared directory: ${SHARED_SKILLS_DIR}"
fi

if [[ -n "$frameworks" ]]; then
    for fw in $frameworks; do
        case "$fw" in
            "opencode")
                opencode_dir="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills/personal}"
                targets="$targets opencode:${opencode_dir}"
                ;;
            *)
                echo "⚠ Unknown framework: $fw (skipping)"
                ;;
        esac
    done
fi

if [[ "$install_all" == "true" ]]; then
    # Detect OpenCode
    if [[ -d "$HOME/.config/opencode" ]]; then
        opencode_dir="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills/personal}"
        targets="$targets opencode:${opencode_dir}"
    fi
    
    # Only use shared if it's not already in targets
    if [[ "$use_shared" != "true" ]]; then
        targets="shared:${SHARED_SKILLS_DIR} $targets"
    fi
fi

# Install to all targets
for target_spec in $targets; do
    agent="$(echo "$target_spec" | cut -d: -f1)"
    target_dir="$(echo "$target_spec" | cut -d: -f2-)"
    
    echo "Installing to ${agent}: ${target_dir}"
    mkdir -p "$target_dir"
    
    # Extract
    tar -xzf /tmp/skills.tar.gz -C "$target_dir" --strip-components=1
    
    echo "✓ Skills installed to ${agent}"
done

# Create symlinks from agent locations to shared directory if needed
if [[ "$use_shared" == "true" ]]; then
    opencode_native="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills/personal}"
    opencode_parent="$(dirname "${opencode_native}")"
    
    if [[ -d "$opencode_parent" && ! -L "$opencode_native" ]]; then
        echo ""
        echo "Configuring OpenCode to use shared skills directory..."
        
        # Backup existing directory if it exists
        if [[ -d "$opencode_native" && -n "$(find "$opencode_native" -type f)" ]]; then
            backup_dir="${opencode_native}.backup.$(date +%Y%m%d-%H%M%S)"
            mv "$opencode_native" "$backup_dir"
            echo "Backed up existing skills to: $backup_dir"
        elif [[ -d "$opencode_native" ]]; then
            rmdir "$opencode_native"
        fi
        
        # Create symlink
        ln -s "$SHARED_SKILLS_DIR" "$opencode_native"
        echo "✓ Created symlink: $opencode_native → $SHARED_SKILLS_DIR"
    fi
fi

echo ""
echo "Installation complete!"
echo "Shared skills directory: ${SHARED_SKILLS_DIR}"
echo "Available skills:"
ls -1 "${SHARED_SKILLS_DIR}" 2>/dev/null | sed 's/^/  - /' || echo "  (no skills found yet)"