# CI lint
setup-lint:
	pip install pip-tools
	pip-compile reqs/lint_requirements.in
	pip-sync reqs/lint_requirements.txt

lint:
	black --check . --line-length 79
	isort --check . --profile black
	flake8 . --count --show-source --statistics

format:
	black . --line-length 79
	isort . --profile black
	flake8 . --count --show-source --statistics
