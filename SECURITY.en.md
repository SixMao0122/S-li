# S-li Security Policy

`S-li` (Six Life Injoy / Shell Line Interface) is committed to providing a secure, lightweight, and trustworthy modern terminal experience. Our design adheres to a strict **Security-First** philosophy.

[English](SECURITY.en.md) | [繁體中文](SECURITY.md)

---

## Core Security Principles

1. **Zero Arbitrary Remote Execution**
   - S-li runs strictly on transparent native shell scripts (PowerShell, Bash, Lua). We never download closed-source binaries or external executables (`.exe` / `.dll`).
   - S-li does not evaluate untrusted strings via `Invoke-Expression` or `eval` during prompt evaluation.

2. **Privacy by Design**
   - **Privacy Mode**: Mask usernames and file paths with a single toggle (`sli privacy on`) during live streaming, presentations, or screenshots.
   - Home directories (`C:\Users\<username>`) are automatically shortened to `~`, preventing accidental exposure of real personal names.

3. **Credential & Environment Protection**
   - The prompt engine only inspects benign state indicators (e.g. `$env:VIRTUAL_ENV`, `$env:CONDA_DEFAULT_ENV`, Git branch).
   - Reading or echoing environment variables that may contain sensitive credentials (e.g. `*_TOKEN`, `*_KEY`, `*_SECRET`, `PASSWORD`) is strictly forbidden.

4. **Automated CI/CD Security Audits**
   - Every push and pull request is scanned by `Gitleaks` in GitHub Actions to prevent accidental secret or credential leaks.

---

## Reporting a Vulnerability

If you discover a potential vulnerability or security concern in `S-li`, please **do not** open a public issue.

Follow these steps to submit a report:
1. Navigate to the **Security** tab of the S-li repository on GitHub.
2. Click **Report a vulnerability** to submit an advisory privately.
3. We will respond within 48 hours to assess and patch the reported issue.

Thank you for helping keep the S-li community secure!
