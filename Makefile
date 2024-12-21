.DEFAULT_GOAL := all

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("docs/_build/html/index.html")
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"
OS_VERSION ?= jammy

PWD := $(shell pwd)
INSTALL_DIR = "/opt/infrahouse-puppet-data"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

.PHONY: hooks
hooks:
	test -L .git/hooks/pre-commit || ln -fs ../../hooks/pre-commit .git/hooks/pre-commit

bootstrap:
	apt-get -y install devscripts \
		debhelper

all:
	@echo "Nothing to build"

install:
	mkdir -p "${DESTDIR}${INSTALL_DIR}"
	cp -R environments "${DESTDIR}${INSTALL_DIR}"; find "${DESTDIR}${INSTALL_DIR}/environments/" -type f -exec chmod 644 {} \;

.PHONY: package
package:
	bash support/package.sh

.PHONY: install-infrahouse-repo
install-infrahouse-repo:
	# Install dependencies
	apt-get update
	apt-get install gpg lsb-release curl
	# Add a GPG public key to verify InfraHouse packages
	mkdir -p /etc/apt/cloud-init.gpg.d/
	curl  -fsSL https://release-$$(lsb_release -cs).infrahouse.com/DEB-GPG-KEY-release-$$(lsb_release -cs).infrahouse.com \
		| gpg --dearmor -o /etc/apt/cloud-init.gpg.d/infrahouse.gpg
	# Add the InfraHouse repository source
	echo "deb [signed-by=/etc/apt/cloud-init.gpg.d/infrahouse.gpg] https://release-$$(lsb_release -cs).infrahouse.com/ $$(lsb_release -cs) main" \
		> /etc/apt/sources.list.d/infrahouse.list
	apt-get update
