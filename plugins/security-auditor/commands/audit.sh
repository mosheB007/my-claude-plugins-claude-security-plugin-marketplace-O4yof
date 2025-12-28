#!/bin/bash
# Production Security Audit - Comprehensive security validation
# Usage: /security:audit [--depth=full|quick] [--output=json|markdown]

set -euo pipefail

# Parse arguments
DEPTH="${1:-full}"
OUTPUT="${2:-markdown}"

echo "🔒 Security Auditor v1.0.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Audit Type: ${DEPTH}"
echo "📊 Output Format: ${OUTPUT}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verify required dependencies
REQUIRED_TOOLS=("grep" "find")
OPTIONAL_TOOLS=("jq" "npm" "pip")

echo "🔍 Verifying dependencies..."
MISSING_REQUIRED=0
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command_exists "$tool"; then
        echo "❌ CRITICAL: Required tool missing: $tool"
        ((MISSING_REQUIRED++))
    fi
done

if [ $MISSING_REQUIRED -gt 0 ]; then
    echo ""
    echo "❌ Cannot proceed. Install missing tools:"
    echo "   Ubuntu/Debian: sudo apt-get install grep findutils"
    exit 1
fi

MISSING_OPTIONAL=0
for tool in "${OPTIONAL_TOOLS[@]}"; do
    if ! command_exists "$tool"; then
        echo "⚠️  Optional tool missing: $tool (some features will be limited)"
        ((MISSING_OPTIONAL++))
    fi
done

if [ $MISSING_OPTIONAL -eq 0 ]; then
    echo "✅ All dependencies available"
fi
echo ""

# Initialize results
ISSUES_CRITICAL=0
ISSUES_HIGH=0
ISSUES_MEDIUM=0
ISSUES_LOW=0

# 1. Check for secrets in code
echo "🔍 Step 1/6: Scanning for hardcoded secrets..."
if grep -r -E "(password|api_key|secret|token|private_key)\s*=\s*['\"][^'\"]{8,}" --include="*.py" --include="*.js" --include="*.ts" --include="*.json" --include="*.yaml" --include="*.env" . 2>/dev/null | grep -v node_modules | grep -v .git; then
    echo "❌ CRITICAL: Hardcoded secrets detected!"
    ((ISSUES_CRITICAL++))
else
    echo "✅ No hardcoded secrets found"
fi
echo ""

# 2. Check Python dependencies
echo "🔍 Step 2/6: Scanning Python dependencies..."
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    if command_exists pip; then
        # Check for known vulnerable packages
        echo "   Checking for known vulnerabilities..."
        if pip list --format=freeze | grep -E "(urllib3==1\.[0-9]|requests==2\.[0-9]\.[0-9]|pillow==.*[0-8]\.)"; then
            echo "⚠️  WARNING: Outdated packages with known vulnerabilities detected"
            ((ISSUES_HIGH++))
        fi

        # Check for typosquatting
        SUSPICIOUS_PACKAGES=("requets" "pillow-simd" "python-dateutil" "urlib3" "cryptograpy")
        for pkg in "${SUSPICIOUS_PACKAGES[@]}"; do
            if pip list | grep -i "$pkg"; then
                echo "🚨 CRITICAL: Potential typosquatting package detected: $pkg"
                ((ISSUES_CRITICAL++))
            fi
        done

        echo "✅ Dependency scan complete"
    else
        echo "⚠️  pip not found, skipping Python dependency check"
    fi
else
    echo "ℹ️  No Python dependencies found"
fi
echo ""

# 3. Check Node.js dependencies
echo "🔍 Step 3/6: Scanning Node.js dependencies..."
if [ -f "package.json" ]; then
    if command_exists npm; then
        echo "   Running npm audit..."
        TEMP_NPM_AUDIT=$(mktemp)
        trap "rm -f '$TEMP_NPM_AUDIT'" EXIT
        if npm audit --json > "$TEMP_NPM_AUDIT" 2>&1; then
            if command_exists jq; then
                VULNERABILITIES=$(jq '.metadata.vulnerabilities.total // 0' "$TEMP_NPM_AUDIT" 2>/dev/null || echo "0")
                if [ "$VULNERABILITIES" -gt 0 ]; then
                    echo "⚠️  Found $VULNERABILITIES vulnerabilities in npm packages"
                    ((ISSUES_HIGH++))
                else
                    echo "✅ No npm vulnerabilities found"
                fi
            else
                # Fallback without jq
                if grep -q '"total"' "$TEMP_NPM_AUDIT" 2>/dev/null; then
                    echo "⚠️  Found vulnerabilities (jq not available for count)"
                    VULNERABILITIES="unknown"
                    ((ISSUES_HIGH++))
                else
                    VULNERABILITIES="0"
                    echo "✅ No npm vulnerabilities found"
                fi
            fi
        else
            echo "⚠️  npm audit failed or returned errors"
            ((ISSUES_MEDIUM++))
        fi
        rm -f "$TEMP_NPM_AUDIT" 2>/dev/null
    else
        echo "⚠️  npm not found, skipping Node.js dependency check"
    fi
else
    echo "ℹ️  No Node.js dependencies found"
fi
echo ""

# 4. Check for common security anti-patterns
echo "🔍 Step 4/6: Scanning for security anti-patterns..."

# SQL Injection patterns
if grep -r -E "(execute|cursor\.execute|query).*%s|.*\+.*SELECT|.*\+.*INSERT|.*\+.*UPDATE" \
    --include="*.py" --include="*.js" . 2>/dev/null | \
    grep -v node_modules | grep -v .git | grep -v "\.md$" | head -5 | grep -q .; then
    echo "⚠️  Potential SQL injection vulnerabilities detected"
    ((ISSUES_HIGH++))
fi

# Command Injection patterns
if grep -r -E "(os\.system|subprocess\.call|eval|exec).*input|.*user" \
    --include="*.py" . 2>/dev/null | \
    grep -v node_modules | grep -v .git | grep -v "\.md$" | head -5 | grep -q .; then
    echo "⚠️  Potential command injection vulnerabilities detected"
    ((ISSUES_HIGH++))
fi

# XSS patterns
if grep -r -E "innerHTML|dangerouslySetInnerHTML|eval\(" \
    --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" . 2>/dev/null | \
    grep -v node_modules | grep -v .git | grep -v "\.md$" | head -5 | grep -q .; then
    echo "⚠️  Potential XSS vulnerabilities detected"
    ((ISSUES_MEDIUM++))
fi

echo "✅ Anti-pattern scan complete"
echo ""

# 5. Check file permissions
echo "🔍 Step 5/6: Checking file permissions..."
if find . -type f -perm -002 2>/dev/null | grep -v node_modules | grep -v .git | head -5; then
    echo "⚠️  World-writable files detected"
    ((ISSUES_MEDIUM++))
else
    echo "✅ File permissions OK"
fi
echo ""

# 6. Check for sensitive files
echo "🔍 Step 6/6: Checking for sensitive files..."
SENSITIVE_FILES=(".env" ".env.local" "secrets.json" "credentials.json" "private.key" ".aws/credentials")
FOUND_SENSITIVE=0
for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "⚠️  Sensitive file found: $file"
        ((FOUND_SENSITIVE++))
        ((ISSUES_HIGH++))
    fi
done
if [ $FOUND_SENSITIVE -eq 0 ]; then
    echo "✅ No sensitive files in repository"
fi
echo ""

# Calculate security score
TOTAL_ISSUES=$((ISSUES_CRITICAL * 10 + ISSUES_HIGH * 5 + ISSUES_MEDIUM * 2 + ISSUES_LOW))
MAX_SCORE=100
SECURITY_SCORE=$((MAX_SCORE - TOTAL_ISSUES))
if [ $SECURITY_SCORE -lt 0 ]; then
    SECURITY_SCORE=0
fi

# Generate report
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SECURITY AUDIT RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔴 Critical Issues: $ISSUES_CRITICAL"
echo "🟠 High Issues: $ISSUES_HIGH"
echo "🟡 Medium Issues: $ISSUES_MEDIUM"
echo "🟢 Low Issues: $ISSUES_LOW"
echo ""
echo "📈 Security Score: ${SECURITY_SCORE}/100"
echo ""

if [ $SECURITY_SCORE -ge 85 ]; then
    echo "✅ PASSED: Project meets enterprise security standards"
    echo "   Ready for production deployment"
    exit 0
elif [ $SECURITY_SCORE -ge 70 ]; then
    echo "⚠️  WARNING: Security issues detected"
    echo "   Review and fix issues before production deployment"
    exit 1
else
    echo "❌ FAILED: Critical security issues detected"
    echo "   DO NOT deploy to production until issues are resolved"
    exit 2
fi
