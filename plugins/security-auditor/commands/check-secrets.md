---
description: Detect hardcoded secrets, API keys, and sensitive data
---

## Primary Method: Execute Secret Detection Script

Scan the codebase for hardcoded secrets and sensitive data:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/check-secrets.sh" $ARGUMENTS
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

---

## Fallback: Native Claude Tools Implementation

If the bash script fails to execute, perform secret detection using Claude's native tools:

### Secret Detection Patterns

Use the **Grep** tool with these patterns on all code files (`**/*.py`, `**/*.js`, `**/*.ts`, `**/*.json`, `**/*.yaml`, `**/*.yml`, `**/*.env`), excluding `node_modules/`, `.git/`, `venv/`:

| Secret Type | Regex Pattern |
|-------------|---------------|
| AWS Access Key | `AKIA[0-9A-Z]{16}` |
| AWS Secret Key | `aws(.{0,20})?['"][0-9a-zA-Z/+]{40}['"]` |
| GitHub Token | `gh[ps]_[a-zA-Z0-9]{36}` |
| Generic API Key | `api[_-]?key['"]?\s*[:=]\s*['"][a-zA-Z0-9_\-]{20,}['"]` |
| Password | `password['"]?\s*[:=]\s*['"][^'"]{4,}['"]` |
| Private Key | `-----BEGIN (RSA\|EC )?PRIVATE KEY-----` |
| Database URL | `(postgres\|mysql\|mongodb)://[^'"\s]+` |
| JWT Token | `eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}` |

### Check for .env Files

Use **Glob** to find:
```
Pattern: **/.env*
Exclude: node_modules/, .git/
```

### Validate .gitignore Coverage

Use **Read** tool to read `.gitignore` and verify these entries exist:
- `.env`
- `.env.local`
- `*.pem`
- `*.key`
- `secrets.json`
- `credentials.json`

### Generate Secret Detection Report

**Output:**
```
Secret Detection Results
========================
Secrets Found: [count]

Findings:
- [file:line] - [secret type]

.gitignore Status:
- [entry]: Present/Missing

Status: PASSED (0 secrets) / FAILED (secrets found)

Recommended Actions:
1. Remove all hardcoded secrets
2. Use environment variables
3. Rotate exposed credentials
4. Add sensitive files to .gitignore
```
