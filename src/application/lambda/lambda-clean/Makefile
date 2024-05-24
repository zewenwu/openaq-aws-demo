build:
	docker build --platform linux/amd64 -t lambda:test . --no-cache

run:
	docker run --platform linux/amd64 -p 9000:8080 lambda:test

test:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

conda-setup:
	conda env create -n openaq-lambda-clean python=3.12

conda-remove:
	conda env remove -n openaq-lambda-clean --all

setup-reqs:
	pip install pip-tools
	pip-compile reqs/requirements.in
	pip-sync reqs/requirements.txt
