# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace providing enterprise-grade security plugins. The main plugin is **security-auditor**, which performs comprehensive security validation for pre-production deployment.

## Commands

### Testing
```bash
# Run comprehensive test suite (validates JSON, file structure, permissions, syntax, agents, skills)
bash scripts/test-plugin.sh

# Verify script permissions
bash scripts/verify-permissions.sh
```

### Fix Permissions (required before testing)
```bash
chmod +x scripts/*.sh
chmod +x plugins/security-auditor/commands/*.sh
chmod +x plugins/security-auditor/hooks/*.sh
```

### Validate JSON Configurations
```bash
jq empty .claude-plugin/marketplace.json
jq empty plugins/security-auditor/.claude-plugin/plugin.json
```

## Architecture

### Plugin System Structure

```
.claude-plugin/marketplace.json    # Marketplace registry (lists available plugins)
plugins/
  security-auditor/
    .claude-plugin/plugin.json     # Plugin manifest (commands, agents, skills, hooks)
    commands/*.sh                  # Executable bash scripts for slash commands
    agents/*.md                    # Agent prompts with YAML frontmatter
    skills/*.md                    # Skill prompts with trigger conditions in frontmatter
    hooks/*.sh                     # Lifecycle hooks (SessionStart, PreCommit)
```

### Key Configuration Files

- **marketplace.json**: Defines marketplace metadata and lists plugins with their source paths
- **plugin.json**: Defines plugin's commands, agents, skills, hooks, and settings

### Agents and Skills Requirements

Agents (`agents/*.md`) must have YAML frontmatter containing:
- `name:` - Agent identifier
- `model:` - AI model to use

Skills (`skills/*.md`) must have YAML frontmatter containing:
- `trigger:` - Conditions for auto-activation

### Bash Script Standards

All bash scripts must:
- Start with `#!/bin/bash`
- Use `set -euo pipefail` (or at minimum `set -e`) for error handling
- Include a `command_exists()` function for dependency checking
- Be executable (`chmod +x`)

## CI/CD

GitHub Actions workflow (`.github/workflows/validate-plugin.yml`) runs:
1. JSON validation and field checks
2. Version consistency between marketplace.json and plugin.json
3. Script permission and syntax validation
4. Agent and skill frontmatter validation
5. Comprehensive test suite
6. Security self-scan

## Requirements

Required: `jq`, `grep`, `git`
Optional: `npm`, `pip` (for enhanced dependency scanning)
