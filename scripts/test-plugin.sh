#!/bin/bash
# Comprehensive Plugin Testing Script

set -e

# Check for required test dependencies
if ! command -v jq >/dev/null 2>&1; then
    echo "❌ jq is required for testing but not installed"
    echo "   Install with: brew install jq (macOS) or apt install jq (Ubuntu)"
    echo "   On Windows: choco install jq (Chocolatey) or scoop install jq (Scoop)"
    exit 1
fi

echo "🧪 Security Auditor Plugin - Comprehensive Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo "Testing: $test_name"
    if eval "$test_command" > /dev/null 2>&1; then
        echo "   ✅ PASS"
        ((TESTS_PASSED++))
    else
        echo "   ❌ FAIL"
        ((TESTS_FAILED++))
    fi
}

# Test 1: JSON Validation
echo "📋 Section 1: Configuration Validation"
echo ""

run_test "marketplace.json is valid JSON" \
    "jq empty .claude-plugin/marketplace.json"

run_test "plugin.json is valid JSON" \
    "jq empty plugins/security-auditor/.claude-plugin/plugin.json"

run_test "marketplace.json has required fields" \
    "jq -e '.name and .version and .description and .author and .plugins' .claude-plugin/marketplace.json"

run_test "plugin.json has required fields" \
    "jq -e '.name and .version and .commands and .agents and .skills' plugins/security-auditor/.claude-plugin/plugin.json"

echo ""

# Test 2: File Structure
echo "📁 Section 2: File Structure Validation"
echo ""

run_test "Commands directory exists" \
    "[ -d 'plugins/security-auditor/commands' ]"

run_test "Agents directory exists" \
    "[ -d 'plugins/security-auditor/agents' ]"

run_test "Skills directory exists" \
    "[ -d 'plugins/security-auditor/skills' ]"

run_test "Hooks directory exists" \
    "[ -d 'plugins/security-auditor/hooks' ]"

run_test "Templates directory exists" \
    "[ -d 'templates' ]"

echo ""

# Test 3: Script Permissions
echo "🔐 Section 3: Script Permissions"
echo ""

SCRIPTS=(
    "plugins/security-auditor/commands/audit.sh"
    "plugins/security-auditor/commands/scan-dependencies.sh"
    "plugins/security-auditor/commands/check-secrets.sh"
    "plugins/security-auditor/commands/generate-report.sh"
    "plugins/security-auditor/hooks/PreCommit.sh"
    "plugins/security-auditor/hooks/SessionStart.sh"
)

for script in "${SCRIPTS[@]}"; do
    run_test "$(basename "$script") is executable" \
        "[ -x '$script' ]"
done

echo ""

# Test 4: Script Syntax
echo "🔍 Section 4: Bash Syntax Validation"
echo ""

for script in "${SCRIPTS[@]}"; do
    run_test "$(basename "$script") has valid bash syntax" \
        "bash -n '$script'"
done

echo ""

# Test 5: Agent Frontmatter
echo "🤖 Section 5: Agent Configuration"
echo ""

AGENTS=(
    "plugins/security-auditor/agents/security-expert.md"
    "plugins/security-auditor/agents/compliance-checker.md"
)

for agent in "${AGENTS[@]}"; do
    run_test "$(basename "$agent") has frontmatter" \
        "grep -q '^---' '$agent'"

    run_test "$(basename "$agent") has name field" \
        "grep -q 'name:' '$agent'"

    run_test "$(basename "$agent") has model field" \
        "grep -q 'model:' '$agent'"
done

echo ""

# Test 6: Skill Configuration
echo "⚡ Section 6: Skills Configuration"
echo ""

SKILLS=(
    "plugins/security-auditor/skills/vulnerability-detection.md"
    "plugins/security-auditor/skills/dependency-analysis.md"
    "plugins/security-auditor/skills/code-scanning.md"
)

for skill in "${SKILLS[@]}"; do
    run_test "$(basename "$skill") has frontmatter" \
        "grep -q '^---' '$skill'"

    run_test "$(basename "$skill") has trigger conditions" \
        "grep -q 'trigger:' '$skill'"
done

echo ""

# Test 7: Documentation
echo "📚 Section 7: Documentation"
echo ""

run_test "README.md exists" \
    "[ -f 'README.md' ]"

run_test "README.md has installation instructions" \
    "grep -q 'Installation' README.md"

run_test "README.md has usage examples" \
    "grep -q 'Usage' README.md"

run_test "LICENSE file exists" \
    "[ -f 'LICENSE' ]"

run_test ".gitignore exists" \
    "[ -f '.gitignore' ]"

echo ""

# Test 8: Script Dependencies
echo "🔧 Section 8: Script Dependencies Check"
echo ""

# Check if scripts properly check for dependencies
run_test "audit.sh checks for dependencies" \
    "grep -q 'command_exists' plugins/security-auditor/commands/audit.sh"

run_test "scan-dependencies.sh checks for tools" \
    "grep -q 'command_exists' plugins/security-auditor/commands/scan-dependencies.sh"

echo ""

# Test 9: Error Handling
echo "⚠️ Section 9: Error Handling"
echo ""

run_test "Scripts use set -e or set -euo pipefail" \
    "grep -q 'set -e' plugins/security-auditor/commands/audit.sh"

run_test "PreCommit.sh has error handling" \
    "grep -q 'set -euo pipefail' plugins/security-auditor/hooks/PreCommit.sh"

echo ""

# Final Report
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 TEST RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Tests Passed: $TESTS_PASSED"
echo "❌ Tests Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED!"
    echo ""
    echo "✅ Plugin is ready for:"
    echo "   - Production deployment"
    echo "   - Team distribution"
    echo "   - Marketplace publication"
    echo ""
    exit 0
else
    echo "⚠️  SOME TESTS FAILED"
    echo ""
    echo "Please fix the failing tests before deployment"
    echo ""
    exit 1
fi
