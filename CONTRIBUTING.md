# Contributing to pp-terraform

Thank you for your interest in contributing to the Power Platform Terraform infrastructure project! This document provides guidelines and information for contributors.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)

---

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow. By participating, you are expected to:

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

---

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, use the **Bug Report** issue template and include:

- Clear and descriptive title
- Steps to reproduce the issue
- Expected vs. actual behavior
- Terraform version and provider versions
- Environment details (dev/test/prod)
- Relevant logs and error messages

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Use the **Feature Request** template and include:

- Clear description of the proposed feature
- Use case and business value
- Example configuration (if applicable)
- Impact on existing functionality

### Infrastructure Issues

For deployment failures or Azure resource problems, use the **Infrastructure Issue** template and provide:

- Environment affected
- Error output and logs
- Recent changes or modifications
- Steps already attempted

### Documentation Improvements

Documentation contributions are always welcome! Use the **Documentation** template for:

- Corrections to existing docs
- Missing information
- Clarifications or examples
- Typo fixes

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Terraform** >= 1.5.0
- **Azure CLI** >= 2.50.0
- **Git** for version control
- Azure subscription with appropriate permissions
- Text editor with Terraform support (VS Code recommended)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/pp-terraform.git
   cd pp-terraform
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/aidevme/pp-terraform.git
   ```

### Setup Development Environment

1. **Install Terraform extensions** (if using VS Code):
   - HashiCorp Terraform
   - Azure Terraform

2. **Configure Azure CLI**:
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

3. **Initialize Terraform** (for testing):
   ```bash
   cd terraform
   terraform init -backend-config=environments/backend-dev.hcl
   ```

---

## Development Workflow

### Branching Strategy

- `main` - Production-ready code
- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation updates

### Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the [Coding Standards](#coding-standards)

3. **Test your changes** locally before committing

4. **Commit your changes** with meaningful messages

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request** against the `main` branch

### Keeping Your Fork Updated

```bash
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

---

## Coding Standards

### Terraform Code Style

- **Use `terraform fmt`** to format all `.tf` files
  ```bash
  terraform fmt -recursive
  ```

- **Follow naming conventions**:
  - Resources: `azurerm_resource_type.descriptive_name`
  - Variables: `snake_case`
  - Outputs: `snake_case`
  - Modules: `kebab-case` for directories

- **Add comments** for complex logic or non-obvious decisions

- **Use variables** instead of hardcoded values

- **Keep modules focused** - One responsibility per module

### File Organization

```
modules/
└── module-name/
    ├── main.tf       # Primary resources
    ├── variables.tf  # Input variables
    ├── outputs.tf    # Output values
    └── README.md     # Module documentation (if complex)
```

### Variable Definitions

```hcl
variable "example_variable" {
  description = "Clear description of what this variable controls"
  type        = string
  default     = "default-value"  # Optional: only if sensible default exists
}
```

### Resource Naming

Follow Azure CAF naming conventions:

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}
```

### Tag All Resources

```hcl
tags = {
  Environment = var.environment
  Project     = var.project_name
  ManagedBy   = "Terraform"
}
```

---

## Pull Request Process

### Before Submitting

- [ ] Code passes `terraform fmt -check`
- [ ] Code passes `terraform validate`
- [ ] All tests pass (if applicable)
- [ ] Documentation is updated
- [ ] Commit messages follow guidelines
- [ ] PR description explains the change

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe testing performed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings generated
```

### Review Process

1. Automated checks must pass (format, validate)
2. At least one maintainer approval required
3. All conversations must be resolved
4. Branch must be up-to-date with main

### After Approval

- Squash and merge (preferred for small PRs)
- Regular merge (for larger feature branches)
- Maintainers will handle the merge

---

## Commit Message Guidelines

### Format

```
<type>: <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

### Examples

```
feat: Add API Management module for production environments

- Create APIM module with consumption and standard tiers
- Configure backend pointing to function app
- Store subscription key in Key Vault
- Add conditional deployment based on environment

Closes #42
```

```
fix: Resolve Application Insights workspace_id lifecycle issue

Add lifecycle block to ignore workspace_id changes that Azure 
automatically sets after resource creation.

Fixes #38
```

### Best Practices

- Use imperative mood ("Add feature" not "Added feature")
- Keep subject line under 50 characters
- Wrap body at 72 characters
- Reference issues and PRs in footer
- Explain **why** not just **what**

---

## Testing Guidelines

### Local Testing

1. **Format check**:
   ```bash
   terraform fmt -check -recursive
   ```

2. **Validation**:
   ```bash
   terraform validate
   ```

3. **Plan (dry-run)**:
   ```bash
   terraform plan -var-file=environments/dev.tfvars
   ```

4. **Test in dev environment** before submitting PR

### What to Test

- [ ] Resources create successfully
- [ ] Outputs are correct
- [ ] Variables work as expected
- [ ] Conditional deployments work
- [ ] Dependencies are properly configured
- [ ] Tagging is applied correctly

### Testing New Modules

When adding a new module:

1. Test in isolation first
2. Test integration with existing modules
3. Test in all environments (dev, test, prod)
4. Verify cleanup (destroy) works correctly

---

## Documentation

### Required Documentation

- **README.md** - Repository overview and quick start
- **docs/architecture.md** - Architecture decisions and diagrams
- **Module README** - For complex modules (optional)
- **Inline comments** - For complex logic

### Documentation Style

- Use clear, concise language
- Include code examples
- Add diagrams where helpful (Mermaid preferred)
- Keep formatting consistent
- Update docs when code changes

### Updating Documentation

When making changes that affect documentation:

- [ ] Update README.md if public API changes
- [ ] Update architecture.md for architectural changes
- [ ] Update inline comments for complex logic
- [ ] Add examples if introducing new features

---

## Questions or Need Help?

- **Open an issue** - For bugs or feature requests
- **Start a discussion** - For questions or ideas
- **Check documentation** - Review docs/ folder first

---

## Recognition

Contributors will be recognized in:

- GitHub contributors list
- Release notes for significant contributions
- Project documentation (with permission)

---

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE) file).

---

**Thank you for contributing to pp-terraform!** 🚀

Your contributions help make Power Platform infrastructure automation better for everyone.
