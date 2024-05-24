build:
	docker build --platform linux/amd64 -t lambda:test . --no-cache

run:
	docker run --platform linux/amd64 -p 9000:8080 lambda:test

test:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

conda-setup:
	conda env create -n openaq-lambda-raw python=3.12

conda-remove:
	conda env remove -n openaq-lambda-raw --all

setup-reqs:
	pip install pip-tools
	pip-compile reqs/requirements.in
	pip-sync reqs/requirements.txt

update-ecr-lambda: # Does not work. Need to fix
	DEPLOY_CONFIG_FILE_NAME="deploy-config.yml"
	export AWS_REGION=$(yq e '.cd-deploy.aws-region' "./${DEPLOY_CONFIG_FILE_NAME}") 
	export ECR_REPO_NAME=$(yq e '.cd-deploy.ecr-repo-name' "./${DEPLOY_CONFIG_FILE_NAME}")
	export LAMBDA_NAME=$(yq e '.cd-deploy.lambda-name' "./${DEPLOY_CONFIG_FILE_NAME}")
	echo "Build Lambda image and push to ECR repository for Lambda: ${LAMBDA_NAME}..."

	# Build the Docker image
	make build

	# Get the ECR repository URL
	export ECR_URL=$(aws ecr describe-repositories --region ${AWS_REGION} --repository-names ${ECR_REPO_NAME} --query 'repositories[0].repositoryUri' --output text)

	# Authenticate and Push to the ECR repository
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}
	docker tag lambda:test ${ECR_URL}:latest
	docker push ${ECR_URL}:latest

	### Update the Lambda function with the new Docker image
	aws lambda update-function-code --region ${AWS_REGION} --function-name ${LAMBDA_NAME} --image-uri ${ECR_URL}:latest
