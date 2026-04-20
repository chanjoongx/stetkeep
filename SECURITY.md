# Security Policy

## Supported versions

| Version | Supported |
| ------- | --------- |
| 0.4.x   | ✅ |
| < 0.4   | ❌ (rebranded from `mdbrain`; use `stetkeep` instead) |

## Reporting a vulnerability

Email **cj@stetkeep.com** with a subject starting with `[security]`. Please include:

- A clear description of the vulnerability
- Steps to reproduce (or a minimal proof of concept)
- The affected version (`npm view stetkeep version` or git commit SHA)
- Your preferred disclosure timeline

You will receive an acknowledgment within **72 hours**. Critical issues are patched with priority; we aim to publish a fix within 14 days of acknowledgment when feasible.

Please do **not** open public GitHub issues for security reports until a fix is released.

## Supply chain attestations

stetkeep publishes with strong supply chain signals so you can verify the integrity of what you install:

- **OIDC Trusted Publisher**: releases go to npm only via `.github/workflows/publish.yml` on semver tag push. No long-lived `NPM_TOKEN` exists. See [npm docs on trusted publishing](https://docs.npmjs.com/trusted-publishers).
- **Sigstore provenance (SLSA v1)**: every release tarball carries a provenance attestation signed by Sigstore, binding it to the exact source commit and build workflow. Verify with `npm install stetkeep --foreground-scripts` or inspect the attestation at `https://registry.npmjs.org/-/npm/v1/attestations/stetkeep@<version>`.
- **SHA-pinned GitHub Actions**: `actions/checkout` and `actions/setup-node` are pinned by commit SHA rather than tag to prevent silent upstream changes.

Each tarball's "Provenance" section on the npm page links directly to the source commit on GitHub and the public Rekor transparency log entry.

## Runtime attack surface

- **Zero runtime dependencies**: `package.json` declares no `dependencies`. stetkeep uses only Node.js stdlib.
- **No network calls at runtime**: the CLI (`install`, `scan`) and hooks (`safety-net.sh` / `.ps1`) do not reach out to any external service. See [PRIVACY.md](PRIVACY.md).
- **Hooks are shell scripts**: before adopting, review `hooks/safety-net.sh` and `hooks/safety-net.ps1`. They read JSON from stdin, grep for anti-pattern markers, and emit permission decisions. They do not execute network calls or modify files outside the project directory.

## Scope

In scope for security reports:
- Any path that exfiltrates user code, prompts, or environment to a third party
- Tarball tampering or provenance verification failures
- Hooks that modify files outside the declared hook decision contract
- Injection attacks through `.craftignore` / `.perfignore` parsing

Out of scope:
- Behavioral outcomes of Claude Code (model errors are not stetkeep vulnerabilities)
- Deliberate user actions (e.g., `git commit --no-verify` bypassing hooks)
- Theoretical weaknesses in upstream Claude Code or Anthropic infrastructure
