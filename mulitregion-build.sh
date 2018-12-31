#!/bin/bash

# *** Change this for your desired regions. These environment variables are the
# same as those defined in deployment-pipeline/pipeline.yaml
if  [ -z "$US_EAST_1_ARTIFACT_BUCKET" ] || 
    [ -z "$US_WEST_2_ARTIFACT_BUCKET" ]
then
      echo "Artifact bucket environment variables are not set correctly"
      exit 1
fi

sam_package () {
  echo "Packaging in region ${1} to bucket ${2}"
  aws cloudformation package \
      --template-file template.yaml \
      --s3-bucket ${2} \
      --output-template-file target/packaged-template-${1}.yaml \
      --region ${1}
}

npm run clean
npm install --production
npm run dist

# *** Change this list of commands for the regions you require - change both the 1st and 2nd arguments!
sam_package us-east-1 ${US_EAST_1_ARTIFACT_BUCKET}
sam_package us-west-2 ${US_WEST_2_ARTIFACT_BUCKET}

