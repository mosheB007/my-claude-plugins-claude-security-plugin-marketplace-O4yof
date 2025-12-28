---
description: Scan all dependencies for known vulnerabilities and malicious packages
---

Scan project dependencies for security vulnerabilities and malicious packages:

```bash
bash plugins/security-auditor/commands/scan-dependencies.sh $ARGUMENTS
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
