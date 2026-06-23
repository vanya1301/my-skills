# Personal Skills

Collection of custom OpenCode skills.

## Installation

### One-line install (Recommended)

Install skills to a **shared global directory** that all agent frameworks can use:

```bash
curl -fsSL https://github.com/vanya1301/my-skills/releases/latest/download/install.sh | bash
```

**What this does:**
- Creates a shared skills directory: `~/.config/ai-skills/`
- Installs all skills there
- Links OpenCode's skills directory to this shared location
- Any future agent framework can be configured to read from this single location

### Installation Options

```bash
# Install to shared directory (default)
curl -fsSL https://github.com/vanya1301/my-skills/releases/latest/download/install.sh | bash

# Override shared directory location
SHARED_SKILLS_DIR="$(pwd)/shared-skills" bash <(curl -fsSL https://github.com/vanya1301/my-skills/releases/latest/download/install.sh)

# Install to specific agent only
bash <(curl -fsSL https://github.com/vanya1301/my-skills/releases/latest/download/install.sh) -f opencode

# Install to all detected agents
bash <(curl -fsSL https://github.com/vanya1301/my-skills/releases/latest/download/install.sh) --all

# View help
bash <(curl -fsSL https://github.com/vanya1301/my-skills/releases/latest/download/install.sh) --help
```

### Environment Variables

```bash
SHARED_SKILLS_DIR="/path/to/skills"    # Override shared directory
OPENCODE_SKILLS_DIR="/custom/path"     # Override OpenCode location
AGENT_FRAMEWORK="opencode"              # Set default agent framework
```

## Skills

- **lazy-senior** - Makes Claude code like a lazy senior engineer (pragmatic, minimal, ship-it mentality)

## How It Works

This repository uses a **shared skills directory approach**:

1. **Centralized storage**: All skills live in one place (`~/.config/ai-skills/`)
2. **Agent compatibility**: OpenCode is automatically configured to use the shared location
3. **Future-proof**: New agent frameworks can be easily configured to use the same shared directory

Benefits:
- One source of truth for all skills
- No duplication across different agent frameworks
- Easy backup and sync of all skills
- Simplifies cross-agent skill management

## Adding Support for New Agent Frameworks

The installer supports an extensible plugin architecture. To add a new agent framework:

1. Edit `install.sh` to add the framework's skills directory logic
2. The framework can either:
   - Use the shared directory directly
   - Create a symlink to the shared directory
   - Use its own native location

Example for a new agent "myagent":
```bash
case "$fw" in
  "myagent")
    echo "$HOME/.config/myagent/skills"
    ;;
esac
```