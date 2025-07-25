checkfiles = src/ tests/
py_warn = PYTHONDEVMODE=1

up:
	@uv lock --upgrade

lock:
	uv lock
	pdm lock
	poetry lock
	pipenv lock

deps:
	@uv sync --all-extras --all-groups

_style:
	@ruff check --fix $(checkfiles)
	@ruff format $(checkfiles)
style: deps _style

_typehints:
	@mypy $(checkfiles)
	@twine check dist/*
typehints: build _type

_check:
	@ruff format --check $(checkfiles) || (echo "Please run 'make style' to auto-fix style issues" && false)
	@ruff check $(checkfiles)
	$(MAKE) _typehints
check: build _check

_lint: _build
	ruff format $(checkfiles)
	ruff check --fix $(checkfiles)
	$(MAKE) _typehints
lint: deps _lint

_test:
	$(py_warn) python tests/runtests.py
test: deps _tests

_build:
	uv build
build: deps _build

ci: build _check _test
