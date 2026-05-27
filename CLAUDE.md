# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## First Steps

**Your first tool call in this repository MUST be reading .claude/CODING_STANDARD.md.
Do not read any other files, search, or take any actions until you have read it.**
This contains InfraHouse's comprehensive coding standards for Terraform, Python, and general formatting rules.

## What This Repository Is

Puppet Hiera data for InfraHouse infrastructure, packaged as a Debian package (`infrahouse-puppet-data`). This is the data layer for Puppet — it contains no Puppet code (modules/manifests logic), only YAML configuration values that Puppet looks up via Hiera.

The package installs to `/opt/infrahouse-puppet-data` and depends on `puppet-agent` and `puppet-code`.

## Build and Packaging

```bash
# Build the .deb package (requires debuild toolchain)
OS_VERSION=jammy make package

# Install build dependencies (run as root on Ubuntu)
make bootstrap

# Install the InfraHouse APT repo (run as root)
make install-infrahouse-repo

# Set up git pre-commit hook
make hooks
```

Version is managed in `setup.cfg` via bumpversion (current: 2.0.0). The `support/package.sh` script generates the debian changelog from the version and runs `debuild`.

## CD Pipeline

On push to `main`, `.github/workflows/CD.yml` builds the package for three Ubuntu codenames (jammy, noble, oracular) and publishes each to the corresponding InfraHouse S3-backed APT repository using `ih-s3-reprepro`.

## Hiera Data Architecture

Two Puppet environments exist: `production` and `development`. Each has identical structure:

```
environments/<env>/
  hiera.yaml         # Hiera v5 config defining lookup hierarchy
  manifests/site.pp  # Single line: lookup('classes', {merge => unique}).include
  data/
    common.yaml      # Base data for all nodes (packages, sudo, users)
    <role>.yaml       # Per-role overrides (matched via %{::puppet_role} fact)
    nodes/            # Per-node overrides (matched via %{::trusted.certname})
```

**Hiera lookup order** (first match wins): per-role data -> per-node data -> common.yaml.

Role YAML files assign Puppet classes and set role-specific parameters. Current production roles: `gha_runner`, `jumphost`, `webserver`, `mta`, `infrahouse_github_backup`.

## Formatting

- Maximum line length: 120 characters
- All files must end with a newline
