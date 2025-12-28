#!/bin/bash
# Comprehensive Plugin Testing Script - Windows/Linux Compatible

set -e

echo "🧪 Security Auditor Plugin - Comprehensive Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Check if jq is available (try both jq and jq.exe)
JQ_AVAILABLE=false
if command -v jq >/dev/null 2>&1; then
    JQ_AVAILABLE=true
    JQ_CMD="jq"
    echo "✅ jq is available"
elif command -v jq.exe >/dev/null 2>&1; then
    JQ_AVAILABLE=true
    JQ_CMD="jq.exe"
    echo "✅ jq.exe is available"
else
    echo "⚠️  jq not found - JSON tests will be skipped"
fi
echo ""

# Test function with better error handling
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing: $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo "PASS"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 1: JSON Validation
echo "📋 Section 1: Configuration Validation"
echo ""

if [ "$JQ_AVAILABLE" = true ]; then
    # Test marketplace.json
    if run_test "marketplace.json is valid JSON" \
        "$JQ_CMD empty .claude-plugin/marketplace.json 2>/dev/null"; then
        :
    else
        echo "   Error details:"
        $JQ_CMD empty .claude-plugin/marketplace.json 2>&1 | head -3
    fi

    # Test plugin.json
    if run_test "plugin.json is valid JSON" \
        "$JQ_CMD empty plugins/security-auditor/.claude-plugin/plugin.json 2>/dev/null"; then
        :
    else
        echo "   Error details:"
        $JQ_CMD empty plugins/security-auditor/.claude-plugin/plugin.json 2>&1 | head -3
    fi

    run_test "marketplace.json has required fields" \
        "$JQ_CMD -e '.name and .version and .description and .owner and .plugins' .claude-plugin/marketplace.json >/dev/null 2>&1"

    run_test "plugin.json has required fields" \
        "$JQ_CMD -e '.name and .version and .commands and .agents and .skills' plugins/security-auditor/.claude-plugin/plugin.json >/dev/null 2>&1"
else
    echo "⏭️  Skipping JSON validation (jq not available)"
    echo "   GitHub Actions will validate JSON files"
fi

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
    if [ -f "$script" ]; then
        run_test "$(basename "$script") is executable" \
            "[ -x '$script' ]"
    else
        echo "Testing: $(basename "$script") is executable... FAIL (file not found)"
        ((TESTS_FAILED++))
    fi
done

echo ""

# Test 4: Script Syntax
echo "🔍 Section 4: Bash Syntax Validation"
echo ""

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        run_test "$(basename "$script") has valid syntax" \
            "bash -n '$script'"
    fi
done

echo ""

# Test 5: Agent Configuration
echo "🤖 Section 5: Agent Configuration"
echo ""

AGENTS=(
    "plugins/security-auditor/agents/security-expert.md"
    "plugins/security-auditor/agents/compliance-checker.md"
)

for agent in "${AGENTS[@]}"; do
    if [ -f "$agent" ]; then
        run_test "$(basename "$agent") has frontmatter" \
            "grep -q '^---' '$agent'"

        run_test "$(basename "$agent") has name field" \
            "grep -q 'name:' '$agent'"

        run_test "$(basename "$agent") has model field" \
            "grep -q 'model:' '$agent'"
    fi
done

echo ""

# Test 6: Skills Configuration
echo "⚡ Section 6: Skills Configuration"
echo ""

SKILLS=(
    "plugins/security-auditor/skills/vulnerability-detection.md"
    "plugins/security-auditor/skills/dependency-analysis.md"
    "plugins/security-auditor/skills/code-scanning.md"
)

for skill in "${SKILLS[@]}"; do
    if [ -f "$skill" ]; then
        run_test "$(basename "$skill") has frontmatter" \
            "grep -q '^---' '$skill'"

        run_test "$(basename "$skill") has trigger" \
            "grep -q 'trigger:' '$skill'"
    fi
done

echo ""

# Test 7: Documentation
echo "📚 Section 7: Documentation"
echo ""

run_test "README.md exists" \
    "[ -f 'README.md' ]"

run_test "README.md has installation section" \
    "grep -iq 'installation' README.md"

run_test "README.md has usage section" \
    "grep -iq 'usage' README.md"

run_test "LICENSE file exists" \
    "[ -f 'LICENSE' ]"

run_test ".gitignore exists" \
    "[ -f '.gitignore' ]"

echo ""

# Final Report
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 TEST RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Tests Passed: $TESTS_PASSED"
echo "❌ Tests Failed: $TESTS_FAILED"
echo ""

if [ "$JQ_AVAILABLE" = false ]; then
    echo "ℹ️  Note: JSON validation was skipped (jq not available)"
    echo "   GitHub Actions will perform full validation"
    echo ""
fi

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED!"
    echo ""
    echo "Plugin is ready for deployment!"
    exit 0
else
    echo "⚠️  Some tests failed. Please review and fix."
    exit 1
fi
