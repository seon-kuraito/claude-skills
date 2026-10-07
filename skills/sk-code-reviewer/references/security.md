# Security axis

Review the change as a senior security engineer looking for high-confidence vulnerabilities with real exploitation potential. This is not a general code review: report only the security implications the change introduces, and nothing already present in the codebase.

## Rules

1. **Minimise false positives.** Flag an issue only when you are more than 80% confident it is exploitable.
2. **No noise.** Skip theoretical issues, style concerns, and low-impact findings.
3. **Impact first.** Prioritise what could lead to unauthorised access, a data breach, or system compromise.
4. **Local is still real.** Something exploitable only from the local network can still be high severity.

## Categories

**Input validation**: SQL injection, command injection in system calls or subprocesses, XXE in XML parsing, template injection, NoSQL injection, path traversal in file operations.

**Authentication and authorisation**: bypass logic, privilege-escalation paths, session-management flaws, JWT flaws, authorisation bypasses.

**Cryptography and credentials**: hard-coded API keys, passwords, or tokens; weak algorithms or implementations; improper key storage; weak randomness; certificate-validation bypasses.

**Injection and code execution**: remote code execution through deserialisation, pickle or YAML deserialisation, eval of dynamic code, XSS (reflected, stored, DOM-based).

**Data exposure**: sensitive data logged or stored, PII handling violations, API endpoints that leak data, debug information exposed.

## Method

1. **Context.** Find the security frameworks and libraries in use, the established sanitisation and validation patterns, and the project's security model.
2. **Comparison.** Compare the new code with those patterns: deviations, inconsistent implementations, new attack surface.
3. **Assessment.** Trace data flow from user input to sensitive operations; look for privilege boundaries crossed unsafely, injection points, unsafe deserialisation.

## Report format

One entry per finding:

```
# Vuln 1: <category>: `<file>:<line>`

* Severity: High | Medium | Low
* Description: <what is wrong and where the untrusted input comes from>
* Exploit scenario: <how an attacker uses it>
* Recommendation: <the fix>
```

Severity: **High** — directly exploitable, leading to RCE, a data breach, or an authentication bypass. **Medium** — needs specific conditions but has significant impact. **Low** — defence in depth. Report High and Medium; include Medium only when it is obvious and concrete.

## Exclusions

Do not report:

- denial of service, resource exhaustion, rate limiting, memory or CPU consumption;
- credentials stored on disk when they are otherwise secured;
- missing input validation on fields that are not security-critical, without a proven impact;
- a lack of hardening: code need not implement every best practice, only avoid concrete vulnerabilities;
- theoretical race conditions or timing attacks;
- outdated third-party libraries;
- memory-safety issues in memory-safe languages;
- files that are only tests;
- log spoofing, regex injection, regex denial of service;
- SSRF that controls only the path, not the host or the protocol;
- user-controlled content in AI prompts;
- documentation files;
- a lack of audit logs.

## Precedents

- Logging a high-value secret in plain text is a vulnerability; logging a URL is assumed safe; logging non-PII data is not a vulnerability.
- UUIDs are unguessable and need no validation.
- Environment variables and CLI flags are trusted; an attack that relies on controlling them is invalid.
- Subtle web issues — tabnabbing, XS-Leaks, prototype pollution, open redirects — only at very high confidence.
- React and Angular escape by default: report XSS there only with `dangerouslySetInnerHTML`, `bypassSecurityTrustHtml`, or the like.
- Missing permission checks in client-side code are not a vulnerability; the server validates.
- Command injection in a shell script, or a vulnerability in a CI workflow or a notebook, only with a concrete path for untrusted input.

## OWASP Top 10 (2025) quick reference

| # | Category | Key mitigation |
|---|---|---|
| A01 | Broken access control | auth middleware on every endpoint, RBAC, ownership checks |
| A02 | Security misconfiguration | security headers, no debug in production, no default credentials |
| A03 | Software supply-chain failures | dependency audit, lockfile integrity, SBOM, provenance |
| A04 | Cryptographic failures | Argon2id or bcrypt for passwords, TLS everywhere, no secrets in code |
| A05 | Injection | parameterised queries, input validation, no raw HTML from user input |
| A06 | Insecure design | threat modelling, secure design patterns, abuse-case testing |
| A07 | Authentication failures | rate-limited login, secure session management, MFA |
| A08 | Software or data integrity failures | SRI for CDN scripts, signed artifacts, no insecure deserialisation |
| A09 | Logging and alerting failures | log security events, no PII in logs, correlation IDs, active alerting |
| A10 | Mishandling of exceptional conditions | handle every error, no stack traces in production, fail secure |
