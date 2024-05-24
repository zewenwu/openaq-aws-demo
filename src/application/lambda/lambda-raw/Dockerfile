FROM public.ecr.aws/lambda/python:3.12

# Install make
RUN dnf -y update && \
    dnf -y install make && \
    dnf clean all

# Copy all local files to the container
COPY . ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN make setup-reqs

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda_function.lambda_handler" ]
