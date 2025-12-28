---
description: Scan all dependencies for known vulnerabilities and malicious packages
---

## Primary Method: Execute Dependency Scanner

Scan project dependencies for security vulnerabilities and malicious packages:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/scan-dependencies.sh" $ARGUMENTS
```

This checks:
- Python packages via pip for known vulnerabilities
- Node.js packages via npm audit
- Typosquatting detection (malicious package name variants)
- Outdated packages with security issues

Arguments:
- `--severity=critical` - Only show critical issues
- `--severity=high` - Show high and critical issues
- `--severity=medium` - Show medium and above (default)
- `--severity=low` - Show all issues

---

## Fallback: Native Claude Tools Implementation

If the bash script fails to execute, analyze dependencies using Claude's native tools:

### Step 1: Analyze Python Dependencies

Use **Glob** to find `requirements.txt` or `pyproject.toml`.

If found, use **Read** tool and check for:

**Known Malicious/Typosquatting Packages:**
- `python3-dateutil` (typosquatting python-dateutil)
- `jeIlyfish` (typosquatting jellyfish)
- `python-mysql` (typosquatting pymysql)
- `requets` (typosquatting requests)
- `urlib3` (typosquatting urllib3)
- `cryptograpy` (typosquatting cryptography)

**Suspicious Version Patterns:**
- `==0.0.*` - Often placeholder/malicious
- `==9.9.9` - Sometimes hijacked packages

**Known Vulnerable Packages:**
- `urllib3==1.*` - Multiple CVEs
- `requests==2.[0-9].*` - Security vulnerabilities
- `pillow<9.0` - Security issues

### Step 2: Analyze Node.js Dependencies

Use **Glob** to find `package.json`.

If found, use **Read** tool on `package.json` and `package-lock.json`.

**Known Typosquatting Packages:**
- `cross-env.js` (should be `cross-env`)
- `nodemailer-js` (should be `nodemailer`)
- `node-fabric` (should be `fabric`)
- `mongose` (should be `mongoose`)
- `node-openssl`
- `sqlite.js`
- `babelcli` (should be `babel-cli`)

### Step 3: Run npm audit (if npm available)

Try running:
```bash
npm audit --json
```

Parse the JSON output for vulnerability counts.

### Generate Dependency Report

**Output:**
```
Dependency Security Scan
========================

Python Dependencies:
- Total Packages: [count]
- Malicious Detected: [count]
- Vulnerable Detected: [count]

Node.js Dependencies:
- Total Packages: [count]
- Typosquatting Detected: [count]
- npm audit Vulnerabilities: [count]

Status: PASSED / FAILED
```
