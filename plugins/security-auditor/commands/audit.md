---
description: Run comprehensive security audit on current project
---

## Primary Method: Execute Audit Script

Run the comprehensive security audit script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/audit.sh" $ARGUMENTS
```

This performs:
- Secret detection (API keys, passwords, tokens)
- Dependency vulnerability scanning (Python pip, Node.js npm)
- Security anti-pattern detection (SQL injection, XSS, command injection)
- File permission checks
- Sensitive file detection

Arguments:
- `quick` - Run quick scan (skip some checks)
- `full` - Run full scan (default)

---

## Fallback: Native Claude Tools Implementation

If the bash script fails to execute (exit code 127, or bash unavailable), perform the audit using Claude's native tools:

### Step 1: Scan for Hardcoded Secrets

Use the **Grep** tool with this pattern on all code files:
```
Pattern: (password|api_key|secret|token|private_key)\s*=\s*['"][^'"]{8,}['"]
Files: **/*.py, **/*.js, **/*.ts, **/*.json, **/*.yaml, **/*.env
Exclude: node_modules/, .git/, venv/
```

Flag any matches as **CRITICAL** security issues.

### Step 2: Check for AWS Keys

```
Pattern: AKIA[0-9A-Z]{16}
Files: **/*
```

### Step 3: Check for GitHub Tokens

```
Pattern: gh[ps]_[a-zA-Z0-9]{36}
Files: **/*
```

### Step 4: Scan for SQL Injection Patterns

```
Pattern: (execute|cursor\.execute|query).*(\+|%)
Files: **/*.py, **/*.js
```

### Step 5: Scan for Command Injection Patterns

```
Pattern: (os\.system|subprocess\.call|eval|exec).*(\+|user|input)
Files: **/*.py
```

### Step 6: Scan for XSS Patterns

```
Pattern: innerHTML|dangerouslySetInnerHTML|eval\(
Files: **/*.js, **/*.jsx, **/*.ts, **/*.tsx
```

### Step 7: Check for Sensitive Files

Use **Glob** to check for existence of:
- `.env`
- `.env.local`
- `secrets.json`
- `credentials.json`
- `private.key`
- `.aws/credentials`

### Step 8: Check Python Dependencies

If `requirements.txt` exists, use **Read** tool and check for:
- Known vulnerable packages: `urllib3==1.*`, `requests==2.[0-9].[0-9]`
- Typosquatting packages: `requets`, `urlib3`, `cryptograpy`

### Step 9: Check Node.js Dependencies

If `package.json` exists, use **Read** tool and check for:
- Typosquatting packages: `cross-env.js`, `nodemailer-js`, `mongose`

### Step 10: Generate Security Report

Calculate security score:
- Critical issues: -10 points each
- High issues: -5 points each
- Medium issues: -2 points each
- Starting score: 100

**Output:**
```
Security Audit Results
======================
Critical Issues: [count]
High Issues: [count]
Medium Issues: [count]
Security Score: [score]/100
Status: PASSED (>=85) / WARNING (70-84) / FAILED (<70)
```
