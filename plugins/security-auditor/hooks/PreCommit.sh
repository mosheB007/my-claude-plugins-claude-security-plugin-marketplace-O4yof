#!/bin/bash
# PreCommit Security Hook
# Runs automatically before each git commit

set -euo pipefail

echo "🔒 Running pre-commit security checks..."
echo ""

# Verify we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "⚠️  Not a git repository, skipping hook"
    exit 0
fi

# Get staged files
STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
    echo "ℹ️  No files staged for commit"
    echo "✅ Nothing to check"
    exit 0
fi

echo "📋 Checking staged files..."
echo ""

# Initialize counters
SECRETS_FOUND=0
DANGEROUS_PATTERNS_FOUND=0

# Check 1: Quick secret scan on staged files
echo "🔍 Scanning for hardcoded secrets..."
SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]{8,}['\"]"
    "api_key\s*=\s*['\"][^'\"]{8,}['\"]"
    "secret\s*=\s*['\"][^'\"]{8,}['\"]"
    "token\s*=\s*['\"][^'\"]{8,}['\"]"
    "AKIA[0-9A-Z]{16}"  # AWS Access Key
)

for pattern in "${SECRET_PATTERNS[@]}"; do
    # Only check Python and JavaScript files
    for file in $STAGED_FILES; do
        if [[ "$file" =~ \.(py|js|ts|jsx|tsx|json|yaml|yml|env)$ ]]; then
            if git diff --cached "$file" | grep -E -i "$pattern" >/dev/null 2>&1; then
                echo "   🚨 Potential secret in: $file"
                ((SECRETS_FOUND++))
            fi
        fi
    done
done

if [ $SECRETS_FOUND -gt 0 ]; then
    echo ""
    echo "❌ COMMIT BLOCKED: Hardcoded secrets detected!"
    echo ""
    echo "   Found $SECRETS_FOUND potential secret(s) in staged files"
    echo ""
    echo "   Required actions:"
    echo "   1. Remove all hardcoded secrets from your code"
    echo "   2. Use environment variables instead"
    echo "   3. Add sensitive files to .gitignore"
    echo "   4. Consider using a secret management service"
    echo ""
    echo "   To skip this check (NOT recommended):"
    echo "   git commit --no-verify"
    echo ""
    exit 1
fi

echo "   ✅ No secrets detected"
echo ""

# Check 2: Dangerous functions in staged files
echo "🔍 Checking for dangerous code patterns..."
DANGEROUS_PATTERNS=(
    "eval\("
    "exec\("
    "__import__\("
    "pickle\.loads"
    "os\.system"
    "subprocess\.call.*shell=True"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    for file in $STAGED_FILES; do
        if [[ "$file" =~ \.(py|js|ts)$ ]]; then
            if git diff --cached "$file" | grep -E "$pattern" >/dev/null 2>&1; then
                echo "   ⚠️  Dangerous pattern in $file: $pattern"
                ((DANGEROUS_PATTERNS_FOUND++))
            fi
        fi
    done
done

if [ $DANGEROUS_PATTERNS_FOUND -gt 0 ]; then
    echo ""
    echo "⚠️  WARNING: Found $DANGEROUS_PATTERNS_FOUND dangerous pattern(s)"
    echo ""
    echo "   These patterns are security risks:"
    echo "   - eval() / exec() allow code injection"
    echo "   - pickle.loads() allows arbitrary code execution"
    echo "   - os.system() is vulnerable to command injection"
    echo ""
    echo "   Please review and use safer alternatives"
    echo ""
    echo "   Allowing commit, but please review carefully!"
    echo ""
fi

# Check 3: Verify sensitive files are in .gitignore
echo "🔍 Checking .gitignore coverage..."
SENSITIVE_PATTERNS=(".env" "*.pem" "*.key" "secrets.json" "credentials.json")
GITIGNORE_WARNINGS=0

if [ -f ".gitignore" ]; then
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if ! grep -q "$pattern" .gitignore; then
            echo "   ℹ️  Consider adding to .gitignore: $pattern"
            ((GITIGNORE_WARNINGS++))
        fi
    done

    if [ $GITIGNORE_WARNINGS -eq 0 ]; then
        echo "   ✅ .gitignore looks good"
    fi
else
    echo "   ⚠️  No .gitignore file found"
    echo "   Consider creating one to protect sensitive files"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Pre-commit security checks completed"
echo ""

if [ $DANGEROUS_PATTERNS_FOUND -gt 0 ]; then
    echo "⚠️  ${DANGEROUS_PATTERNS_FOUND} warning(s) - review recommended"
    echo ""
fi

exit 0
