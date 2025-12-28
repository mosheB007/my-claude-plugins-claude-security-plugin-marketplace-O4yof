---
description: Generate detailed security report for stakeholders
---

## Primary Method: Execute Report Generator

Generate a comprehensive security report combining all audit results:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/generate-report.sh" $ARGUMENTS
```

The report includes:
- Executive summary with security score
- Vulnerability findings by severity
- Dependency security status
- Secret detection results
- Compliance checklist (OWASP, CWE)
- Remediation recommendations
- Deployment readiness assessment

Arguments:
- `--format=markdown` - Output as Markdown (default)
- `--format=json` - Output as JSON

---

## Fallback: Native Claude Tools Implementation

If the bash script fails to execute, generate the report using Claude's native tools:

### Step 1: Run All Security Checks

Execute these commands (or their native fallbacks):
1. `/security-auditor:audit` - Full security audit
2. `/security-auditor:scan-deps` - Dependency analysis
3. `/security-auditor:check-secrets` - Secret detection

### Step 2: Compile Results

Gather all findings from the security checks and organize by severity:
- **Critical**: Hardcoded secrets, malicious packages
- **High**: SQL injection, command injection, vulnerable dependencies
- **Medium**: XSS patterns, outdated packages
- **Low**: Missing .gitignore entries, informational findings

### Step 3: Generate Report

Create a comprehensive report with this structure:

```markdown
# Security Audit Report

**Generated:** [Current Date/Time]
**Project:** [Current Directory Name]
**Auditor:** Security Auditor Plugin v1.0.0

---

## Executive Summary

**Security Score:** [X]/100
**Status:** [PASSED/WARNING/FAILED]

### Quick Stats
- Critical Issues: [count]
- High Issues: [count]
- Medium Issues: [count]
- Low Issues: [count]

---

## Findings by Category

### Hardcoded Secrets
[List of findings or "None detected"]

### Dependency Vulnerabilities
[List of findings or "None detected"]

### Code Security Issues
[List of SQL injection, XSS, command injection findings]

### Configuration Issues
[Sensitive files, .gitignore gaps]

---

## OWASP Top 10 Compliance

| Category | Status |
|----------|--------|
| A01:2021 Broken Access Control | [Check/Warning/N/A] |
| A02:2021 Cryptographic Failures | [Check/Warning/N/A] |
| A03:2021 Injection | [Check/Warning/N/A] |
| A04:2021 Insecure Design | [Check/Warning/N/A] |
| A05:2021 Security Misconfiguration | [Check/Warning/N/A] |
| A06:2021 Vulnerable Components | [Check/Warning/N/A] |
| A07:2021 Auth Failures | [Check/Warning/N/A] |
| A08:2021 Integrity Failures | [Check/Warning/N/A] |
| A09:2021 Logging Failures | [Check/Warning/N/A] |
| A10:2021 SSRF | [Check/Warning/N/A] |

---

## Recommendations

[Prioritized list of remediation actions]

---

## Deployment Readiness

**Approved for Production:** [YES/NO]

[Explanation based on security score and critical issues]
```

### Step 4: Save Report

Save the report as `security-report-[timestamp].md` in the current directory.
