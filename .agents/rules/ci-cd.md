# CI/CD

Every CI/CD pipeline must enforce the following steps and standards.

## Mandatory Steps

- **Automated test suite** — Every pipeline must include an automated test suite step.
- **Coverage results** — Coverage results must be generated on every run.
- **Coverage threshold** — Coverage results must be >= 85%.
- **HTML coverage report** — Generate an HTML coverage report as a pipeline artifact.
- **Static analysis and security scanning** — Every pipeline must run static analysis and security scanning.

## Version Pinning

- ALWAYS use very specific version pinning for all dependencies, tools, and images.
- No version drift or changes should occur unless explicitly and manually changed.
