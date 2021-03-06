#!/bin/bash

set -eu

if [ -z ${1} ]
then
	echo "Deploy FAILED!"
        echo "Pass the S3 bucket you would like to use for deployment artifacts as first argument"
	exit 1
fi

# Read the application name from the package.json file so that we don't need to duplicate it in this script
STACK_NAME=$(cat package.json | tr -d '\n' | sed 's/.*"name": *"\([^"]*\)".*/\1/')
SAM_BUCKET=${1}

npm run clean
# Delete node_modules, and run npm install --production, to avoid putting dev dependencies in lambda zip file
rm -rf node_modules
npm install --production
npm run dist

# Now perform deployment using AWS SAM package and deploy commands
aws cloudformation package \
    --template-file template.yaml \
    --s3-bucket $SAM_BUCKET \
    --output-template-file target/packaged-template.yaml

aws cloudformation deploy \
    --template-file target/packaged-template.yaml \
    --stack-name $STACK_NAME \
    --capabilities CAPABILITY_IAM

# Deployment now complete, so read some values from AWS that we can display
REGION=$(aws configure get region)
WEB_CONSOLE_URL="https://console.aws.amazon.com/lambda/home?region=${REGION}#/applications/${STACK_NAME}"

echo
echo "** Serverless application deployed!"
echo "** Application / Stack name: $STACK_NAME"
echo
echo "** AWS Console URL: ${WEB_CONSOLE_URL} **"
echo