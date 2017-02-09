FROM alpine:3.5

# File Author / Maintainer
MAINTAINER Cornell IT Cloud DevOps Team <cloud-devops@cornell.edu>

# Expect AWS CLI credentials to be passed in as build arguments
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN

# Install the AWS CLI
RUN \
  wget "s3.amazonaws.com/aws-cli/awscli-bundle.zip" -O "awscli-bundle.zip" && \
  unzip awscli-bundle.zip && \
  apk add --update python && \
  rm /var/cache/apk/* && \
  ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
  rm awscli-bundle.zip && \
  rm -rf awscli-bundle

# An example invocation of the AWS CLI to prove AWS credentials have
# been properly passed.
RUN aws s3 ls

CMD ["/bin/sh"]