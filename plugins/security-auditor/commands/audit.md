---
description: Run comprehensive security audit on current project
---

Run a comprehensive security audit on the current project by executing the audit script:

```bash
bash plugins/security-auditor/commands/audit.sh $ARGUMENTS
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
