#!/bin/bash


AWS_CREDENTIALS_FILE=~/.aws/credentials

# Where is the [saml] section?
SAML_START=`grep -n -F '[saml]' $AWS_CREDENTIALS_FILE | cut -f1 -d:`

# transform the properties into export commands
tail -n+$SAML_START $AWS_CREDENTIALS_FILE | head -n6 | sed '/saml/d' | sed '/output/d' | sed 's/aws_session_token = /export AWS_SESSION_TOKEN=/' | sed 's/aws_access_key_id = /export AWS_ACCESS_KEY_ID=/' | sed 's/aws_secret_access_key = /export AWS_SECRET_ACCESS_KEY=/' | sed 's/region = /export AWS_DEFAULT_REGION=/'