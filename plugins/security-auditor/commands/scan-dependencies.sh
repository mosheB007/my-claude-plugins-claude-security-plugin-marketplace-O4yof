#!/bin/bash
# Dependency Security Scanner
# Scans all project dependencies for vulnerabilities and malicious packages

set -euo pipefail

SEVERITY="${1:-critical}"

# Verify required dependencies
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "🔍 Checking scanner dependencies..."
SCANNER_READY=true

if [ -f "requirements.txt" ] && ! command_exists pip; then
    echo "⚠️  Python project detected but pip not found"
    echo "   Install: sudo apt-get install python3-pip"
    SCANNER_READY=false
fi

if [ -f "package.json" ] && ! command_exists npm; then
    echo "⚠️  Node.js project detected but npm not found"
    echo "   Install: sudo apt-get install npm"
    SCANNER_READY=false
fi

if [ "$SCANNER_READY" = false ]; then
    echo ""
    echo "❌ Scanner cannot proceed without required tools"
    echo "   Install missing tools and try again"
    exit 1
fi
echo ""

echo "📦 Dependency Security Scanner"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Severity Filter: ${SEVERITY}"
echo ""

# Check Python dependencies
if [ -f "requirements.txt" ]; then
    echo "🐍 Scanning Python dependencies..."

    # Create temporary file with package names
    pip list --format=freeze > /tmp/pip-packages.txt

    # Known malicious packages (examples - update regularly)
    MALICIOUS_PATTERNS=(
        "python3-dateutil"  # Typosquatting dateutil
        "jeIlyfish"         # Typosquatting jellyfish
        "python-mysql"      # Typosquatting pymysql
        "requets"           # Typosquatting requests
    )

    echo "   Checking for known malicious packages..."
    for pattern in "${MALICIOUS_PATTERNS[@]}"; do
        if grep -i "$pattern" /tmp/pip-packages.txt; then
            echo "   🚨 MALICIOUS PACKAGE DETECTED: $pattern"
        fi
    done

    # Check for packages with suspicious versions
    echo "   Checking package versions..."
    if grep -E "==0\.0\.|==9\.9\.9" /tmp/pip-packages.txt; then
        echo "   ⚠️  Suspicious version numbers detected"
    fi

    echo "   ✅ Python dependency scan complete"
    echo ""
fi

# Check Node.js dependencies
if [ -f "package.json" ]; then
    echo "📦 Scanning Node.js dependencies..."

    if command -v npm >/dev/null 2>&1; then
        # Run npm audit
        npm audit --audit-level="$SEVERITY" 2>&1 | grep -v "^$" || echo "   ✅ No vulnerabilities found"
    fi

    # Check for suspicious package names
    echo "   Checking for typosquatting..."
    SUSPICIOUS_NPM=(
        "cross-env.js"
        "d3.js"
        "fabric-js"
        "ffmepg"
        "gruntcli"
        "http-proxy.js"
        "mariadb"
        "mongose"
        "mssql-node"
        "mssql.js"
        "mysqljs"
        "node-fabric"
        "node-opencv"
        "node-opensl"
        "node-openssl"
        "node-sqlite"
        "node-tkinter"
        "nodecaffe"
        "nodefabric"
        "nodeffmpeg"
        "nodemailer-js"
        "nodemailer.js"
        "openssl.js"
        "proxy.js"
        "shadowsock"
        "smb"
        "sqlite.js"
        "sqliter"
        "sqlserver"
        "tkinter"
    )

    if [ -f "package-lock.json" ]; then
        for pkg in "${SUSPICIOUS_NPM[@]}"; do
            if grep -q "\"$pkg\"" package-lock.json; then
                echo "   🚨 SUSPICIOUS PACKAGE: $pkg (possible typosquatting)"
            fi
        done
    fi

    echo "   ✅ Node.js dependency scan complete"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Dependency scan completed successfully"
