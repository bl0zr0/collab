.PHONY: install install-hooks run-hooks check-squash \
        check-python check-pip check-pre-commit check-terraform check-make \
        install-python install-pip install-pre-commit install-terraform install-make \
        detect-os

OS_NAME := $(shell uname -s)
IS_AMAZON := $(shell grep -i amazon /etc/os-release > /dev/null 2>&1 && echo true || echo false)

install: detect-os check-python check-pip check-make check-terraform check-pre-commit install-hooks

detect-os:
	@echo "🔍 Detected OS: $(OS_NAME)"
	@if [ "$(OS_NAME)" = "Linux" ]; then \
		if [ "$(IS_AMAZON)" = "true" ]; then \
			echo "🟡 Amazon Linux detected"; \
		else \
			echo "🟠 Linux detected, but not Amazon Linux — please update Makefile for other distro"; \
		fi \
	elif echo "$(OS_NAME)" | grep -qi MINGW; then \
		echo "🟦 Windows with Git Bash detected"; \
	else \
		echo "❌ Unsupported OS: $(OS_NAME)"; \
	fi

##############################################
## Tool Checks (OS-agnostic logic wrappers) ##
##############################################

check-python:
	@echo "🔍 Checking for python3..."
	@if ! command -v python3 >/dev/null 2>&1; then \
		$(MAKE) install-python; \
	else \
		echo "✅ python3 is installed."; \
	fi

check-pip:
	@echo "🔍 Checking for pip3..."
	@if ! command -v pip3 >/dev/null 2>&1; then \
		$(MAKE) install-pip; \
	else \
		echo "✅ pip3 is installed."; \
	fi

check-pre-commit:
	@echo "🔍 Checking for pre-commit..."
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		$(MAKE) install-pre-commit; \
	else \
		echo "✅ pre-commit is installed."; \
	fi

check-terraform:
	@echo "🔍 Checking for terraform..."
	@if ! command -v terraform >/dev/null 2>&1; then \
		$(MAKE) install-terraform; \
	else \
		echo "✅ terraform is installed."; \
	fi

check-make:
	@echo "🔍 Checking for make..."
	@if ! command -v make >/dev/null 2>&1; then \
		$(MAKE) install-make; \
	else \
		echo "✅ make is installed."; \
	fi

##################################
## OS-specific Install Commands ##
##################################

install-python:
ifeq ($(OS_NAME),Linux)
	@if [ "$(IS_AMAZON)" = "true" ]; then \
		sudo yum install -y python3; \
	fi
else
	choco install python --pre -y
endif

install-pip:
ifeq ($(OS_NAME),Linux)
	@if [ "$(IS_AMAZON)" = "true" ]; then \
		sudo yum install -y python3-pip; \
	fi
else
	choco install python --pre -y
endif

install-pre-commit:
	pip3 install pre-commit

install-terraform:
ifeq ($(OS_NAME),Linux)
	@if [ "$(IS_AMAZON)" = "true" ]; then \
		sudo yum install -y yum-utils; \
		sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo; \
		sudo yum -y install terraform; \
	fi
else
	choco install terraform -y
endif

install-make:
ifeq ($(OS_NAME),Linux)
	@if [ "$(IS_AMAZON)" = "true" ]; then \
		sudo yum install -y make; \
	fi
else
	choco install make -y
endif

######################
## Git Hook Commands ##
######################

install-hooks:
	@echo "🔧 Installing pre-commit Git hooks..."
	pre-commit install
	pre-commit install --hook-type commit-msg
	pre-commit install --hook-type pre-push
	@echo "✅ Hooks installed successfully."

run-hooks:
	@echo "🔍 Running all pre-commit hooks..."
	pre-commit run --all-files

check-squash:
	@echo "🧪 Checking if commits are squashed..."
	bash scripts/check_squashed.sh

