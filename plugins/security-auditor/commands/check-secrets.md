---
description: Detect hardcoded secrets, API keys, and sensitive data
---

Scan the codebase for hardcoded secrets and sensitive data:

```bash
bash plugins/security-auditor/commands/check-secrets.sh $ARGUMENTS
```

This detects:
- AWS Access Keys
- GitHub tokens
- Generic API keys and passwords
- Database connection strings
- Private keys (RSA, EC)
- JWT tokens

Arguments:
- `true` or `--include-history` - Also scan Git history for leaked secrets
