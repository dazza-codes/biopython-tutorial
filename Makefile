# https://www.gnu.org/software/make/manual/html_node/Makefile-Conventions.html

SHELL = /bin/bash

.ONESHELL:
.SUFFIXES:

LIB = biopython_tutorial
PACKAGE = biopython-tutorial

.PHONY: clean
clean:
	@rm -rf build dist .eggs *.egg-info
	@rm -rf .benchmarks .coverage coverage.xml htmlcov prof report.xml .tox
	@find . -type d -name '.mypy_cache' -exec rm -rf {} +
	@find . -type d -name '__pycache__' -exec rm -rf {} +
	@find . -type d -name '*pytest_cache*' -exec rm -rf {} +
	@find . -type f -name "*.py[co]" -exec rm -rf {} +

.PHONY: flake8
flake8: clean
	@poetry run flake8 --ignore=E501 $(LIB)

.PHONY: format
format: clean
	@poetry run black $(LIB) tests *.py

.PHONY: init
init: poetry
	@poetry env info
	@[[ -f pip.conf ]] && cp pip.conf $$(poetry env info -p)
	@poetry run python -m pip install --upgrade pip
	@poetry install -v --no-interaction --with all

.PHONY: lint
lint: clean
	@poetry run pylint --disable=missing-docstring tests
	@poetry run pylint $(LIB)

NOTEBOOK_LOG = /tmp/notebook-$(PACKAGE).log

.PHONY: notebook-start
notebook-start: poetry
	@poetry run python -m ipykernel install --user --name=$(PACKAGE)
	@poetry run jupyter notebook notebooks/ > $(NOTEBOOK_LOG) 2>&1 &
	@echo "Logs: $(NOTEBOOK_LOG)"

.PHONY: notebook-stop
notebook-stop: poetry
	@poetry run jupyter notebook stop
	@rm -f $(NOTEBOOK_LOG)

.PHONY: test
test: clean
	@poetry run pytest \
		--durations=10 \
		--show-capture=no \
		--cov-config .coveragerc \
		--cov-report html \
		--cov-report term \
		--cov=$(LIB) tests

.PHONY: typehint
typehint: clean
	@poetry run mypy --follow-imports=skip $(LIB)

.PHONY: package
package: clean
	@poetry check
	@poetry build

.PHONY: package-check
package-check: package
	@poetry run twine check dist/*

# This project will not be published
#.PHONY: package-publish
#package-publish: package-check
#	@poetry publish

.PHONY: poetry
poetry:
	@if ! command -v poetry > /dev/null; then \
		curl -sSL https://install.python-poetry.org | python -; \
	fi
	@if ! echo "$PATH" | grep -Eq "(^|:)${HOME}/.local/bin($|:)"; then \
		export PATH="${HOME}/.local/bin:${PATH}"; \
	fi
	@poetry --version
	@echo
