#!/bin/bash
# Script Permissions Verification

echo "🔐 Verifying Script Permissions..."
echo ""

SCRIPTS=(
    "plugins/security-auditor/commands/audit.sh"
    "plugins/security-auditor/commands/scan-dependencies.sh"
    "plugins/security-auditor/commands/check-secrets.sh"
    "plugins/security-auditor/commands/generate-report.sh"
    "plugins/security-auditor/hooks/PreCommit.sh"
    "plugins/security-auditor/hooks/SessionStart.sh"
)

ISSUES_FOUND=0

for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        echo "❌ File not found: $script"
        ((ISSUES_FOUND++))
        continue
    fi

    if [ ! -x "$script" ]; then
        echo "❌ Not executable: $script"
        echo "   Run: chmod +x $script"
        ((ISSUES_FOUND++))
    else
        echo "✅ $script"
    fi
done

echo ""

if [ $ISSUES_FOUND -eq 0 ]; then
    echo "✅ All scripts have correct permissions!"
    exit 0
else
    echo "❌ Found $ISSUES_FOUND issue(s)"
    echo ""
    echo "To fix all permissions at once, run:"
    echo "  chmod +x plugins/security-auditor/commands/*.sh"
    echo "  chmod +x plugins/security-auditor/hooks/*.sh"
    exit 1
fi
