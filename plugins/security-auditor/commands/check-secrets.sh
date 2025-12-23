#!/bin/bash
# Secret Detection Tool
# Scans for hardcoded secrets, API keys, passwords, and tokens

set -euo pipefail

INCLUDE_HISTORY="${1:-false}"

# Verify grep is available
if ! command -v grep >/dev/null 2>&1; then
    echo "❌ CRITICAL: grep not found"
    echo "   Install: sudo apt-get install grep"
    exit 1
fi

if [ "$INCLUDE_HISTORY" = "true" ] && ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "⚠️  Git history scan requested but not a git repository"
    INCLUDE_HISTORY="false"
fi

echo "🔐 Secret Detection Scanner"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SECRETS_FOUND=0

# Patterns to search for
declare -A PATTERNS=(
    ["AWS Access Key"]="AKIA[0-9A-Z]{16}"
    ["AWS Secret Key"]="aws(.{0,20})?['\"][0-9a-zA-Z/+]{40}['\"]"
    ["GitHub Token"]="gh[ps]_[a-zA-Z0-9]{36}"
    ["Generic API Key"]="api[_-]?key['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_\-]{20,}['\"]"
    ["Password"]="password['\"]?\s*[:=]\s*['\"][^'\"]{4,}['\"]"
    ["Private Key"]="-----BEGIN (RSA |EC )?PRIVATE KEY-----"
    ["Database URL"]="(postgres|mysql|mongodb)://[^'\"\s]+"
    ["JWT Token"]="eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}"
)

echo "🔍 Scanning current files..."

for name in "${!PATTERNS[@]}"; do
    pattern="${PATTERNS[$name]}"
    echo "   Checking for: $name"

    # Search in current files
    if grep -r -E -i "$pattern" \
        --include="*.py" \
        --include="*.js" \
        --include="*.ts" \
        --include="*.jsx" \
        --include="*.tsx" \
        --include="*.json" \
        --include="*.yaml" \
        --include="*.yml" \
        --include="*.env" \
        --include="*.config" \
        --exclude-dir=node_modules \
        --exclude-dir=.git \
        --exclude-dir=venv \
        --exclude-dir=__pycache__ \
        . 2>/dev/null | head -3 | grep -q .; then
        echo "   🚨 FOUND: $name"
        ((SECRETS_FOUND++))
    fi
done

# Check for .env files
echo ""
echo "🔍 Checking for .env files..."
if find . -name ".env*" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | grep .; then
    echo "⚠️  .env files found - ensure they are in .gitignore"
    ((SECRETS_FOUND++))
fi

# Check if secrets are in .gitignore
echo ""
echo "🔍 Validating .gitignore..."
if [ -f ".gitignore" ]; then
    REQUIRED_ENTRIES=(".env" ".env.local" "*.pem" "*.key" "secrets.json" "credentials.json")
    for entry in "${REQUIRED_ENTRIES[@]}"; do
        if ! grep -q "$entry" .gitignore; then
            echo "⚠️  Missing in .gitignore: $entry"
            ((SECRETS_FOUND++))
        fi
    done
else
    echo "❌ No .gitignore file found!"
    ((SECRETS_FOUND++))
fi

# Check Git history if requested
if [ "$INCLUDE_HISTORY" = "true" ]; then
    echo ""
    echo "🔍 Scanning Git history (this may take a while)..."

    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Search through all commits
        for name in "${!PATTERNS[@]}"; do
            pattern="${PATTERNS[$name]}"
            if git log -p | grep -E -i "$pattern" | head -5; then
                echo "   🚨 FOUND in history: $name"
                ((SECRETS_FOUND++))
            fi
        done
    else
        echo "ℹ️  Not a Git repository, skipping history scan"
    fi
fi

# Report
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $SECRETS_FOUND -eq 0 ]; then
    echo "✅ No secrets detected!"
    echo "   Project is safe for production"
    exit 0
else
    echo "❌ CRITICAL: Secrets detected!"
    echo "   Found $SECRETS_FOUND potential secret(s)"
    echo ""
    echo "⚠️  IMMEDIATE ACTIONS REQUIRED:"
    echo "   1. Remove all hardcoded secrets from code"
    echo "   2. Rotate all exposed credentials"
    echo "   3. Use environment variables or secret management"
    echo "   4. Add sensitive files to .gitignore"
    echo "   5. Clean Git history if secrets were committed"
    exit 1
fi
