# Security Policy

## Reporting a vulnerability

Please report security vulnerabilities using
[GitHub's private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability)
feature on this repository (Security tab → "Report a vulnerability"),
rather than opening a public issue. This lets maintainers assess and fix
the issue before details are public.

If that feature isn't available for any reason, please avoid opening a
public issue for anything that looks like a genuine security
vulnerability (as opposed to a general bug) until a private contact
method is added here.

## Scope

Given LibreTunnel's architecture, particular attention is warranted for:

- **Subprocess invocation** (`OpenFOAMRuntime`, `SolverBridge`, once they
  exist) — anywhere the application constructs command-line arguments or
  file paths from user-supplied input (geometry filenames, project names,
  case directory paths) before passing them to `Process`.
- **Project file loading** (`ProjectKit`, once it exists) — a malicious or
  corrupted project file should never be able to cause unsafe behavior
  when opened.
- The Homebrew-driven installation flow (ADR-0002) — since it requests
  elevated privileges to install software, it should be auditable and
  should never execute anything not explicitly reviewed and documented.

## Supported versions

No tagged releases exist yet (Phase 1, development scaffold). This
section will be updated once versioned releases begin.
