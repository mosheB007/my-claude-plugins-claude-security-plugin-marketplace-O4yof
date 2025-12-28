---
description: Generate detailed security report for stakeholders
---

Generate a comprehensive security report combining all audit results:

```bash
bash plugins/security-auditor/commands/generate-report.sh $ARGUMENTS
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
