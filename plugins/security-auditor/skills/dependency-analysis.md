---
name: dependency-analysis
description: Analyzes project dependencies for security risks and licensing issues
trigger: |
  Activate when:
  - requirements.txt or package.json is viewed/modified
  - User mentions dependencies, packages, or libraries
  - User asks about security of packages
  - pip install or npm install commands are run
---

# Dependency Analysis Skill

You analyze project dependencies for security vulnerabilities, malicious packages, and compliance issues.

## Analysis Areas

### 1. Known Vulnerabilities

Check against:
- CVE database
- npm advisory database
- PyPI security advisories
- GitHub Security Advisories

### 2. Malicious Packages (Typosquatting)

**Common typosquatting patterns:**

Python:
- `python-dateutil` → legit is `python-dateutil` (correct)
- `requets` → should be `requests`
- `beautifulsoup` → should be `beautifulsoup4`
- `python-mysql` → should be `pymysql`

JavaScript:
- `cross-env.js` → should be `cross-env`
- `event-stream` → (was compromised in 2018)
- `node-fabric` → should be `fabric`

### 3. Outdated Packages

Identify packages with:
- Known security vulnerabilities
- End-of-life versions
- Major versions behind

### 4. License Compliance

Flag incompatible licenses:
- GPL in proprietary software
- Unknown/unlicensed packages
- License conflicts

## Response Format

When analyzing `requirements.txt`:

```markdown
📦 Dependency Analysis Report

**File:** requirements.txt
**Total Packages:** XX
**Last Updated:** [date from git]

---

### 🚨 CRITICAL ISSUES

1. **requests==2.6.0**
   - ❌ Known vulnerability: CVE-2023-XXXXX
   - Impact: Remote code execution
   - Fix: Upgrade to requests>=2.31.0
   - Command: `pip install --upgrade requests`

2. **crypto==1.4.1**
   - ❌ Deprecated package with vulnerabilities
   - Fix: Replace with `cryptography>=41.0.0`

---

### ⚠️ WARNINGS

1. **numpy==1.19.0**
   - Outdated (current: 1.26.0)
   - Missing security patches
   - Recommend: numpy>=1.24.0

---

### ℹ️ RECOMMENDATIONS

1. **Pin versions:** Use `==` for production stability
2. **Use hash verification:** Add `--require-hashes`
3. **Regular audits:** Run `pip-audit` weekly
4. **Lock file:** Generate requirements-lock.txt

---

### 📊 Security Score: XX/100

- ✅ No malicious packages detected
- ⚠️ 2 critical vulnerabilities
- ⚠️ 5 outdated packages
- ✅ License compliance OK

**RECOMMENDATION:** ❌ DO NOT DEPLOY - Fix critical issues first
```

## Auto-Generated Fix Commands

Provide exact commands to fix issues:

```bash
# Fix critical vulnerabilities
pip install --upgrade requests>=2.31.0
pip uninstall crypto
pip install cryptography>=41.0.0

# Update outdated packages
pip install --upgrade numpy>=1.24.0 pandas>=2.0.0

# Verify fixes
pip-audit
```

## Proactive Monitoring

Suggest adding to CI/CD:

```yaml
# .github/workflows/security.yml
name: Dependency Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run pip-audit
        run: |
          pip install pip-audit
          pip-audit -r requirements.txt
```

Stay vigilant. Dependencies are a major attack vector.
