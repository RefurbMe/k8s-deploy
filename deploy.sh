#!/bin/bash

# This is optimized for CircleCI
# Thanks to: https://github.com/circleci/docker-hello-google
# user defined variables:
# - REPO_NAME
# - PROJECT_NAME
# - CLUSTER_NAME
# - CLOUDSDK_COMPUTE_ZONE
# - GCLOUD_SERVICE_KEY

# Exit on any error
set -e

# Kubernetes Configuration
IMAGE_REGISTRY="us.gcr.io"

if [ -z "$GCLOUD_SERVICE_KEY" ]; then
  echo "GCLOUD_SERVICE_KEY is not set on your CI"
  exit 1;
else
  # Update k8s and log in
  sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update
  sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update kubectl
  echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/account-auth.json
  sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/account-auth.json
  sudo /opt/google-cloud-sdk/bin/gcloud config set project $PROJECT_NAME
  sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster $CLUSTER_NAME
  sudo /opt/google-cloud-sdk/bin/gcloud config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
  sudo /opt/google-cloud-sdk/bin/gcloud container clusters get-credentials $CLUSTER_NAME

  # Deploy
  sudo /opt/google-cloud-sdk/bin/gcloud docker -- push $IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:$CIRCLE_BUILD_NUM
  sudo /opt/google-cloud-sdk/bin/gcloud docker -- push $IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:latest

  sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
  sudo GOOGLE_APPLICATION_CREDENTIALS=${HOME}/account-auth.json /opt/google-cloud-sdk/bin/kubectl set image deployment/$REPO_NAME $REPO_NAME=$IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:$CIRCLE_BUILD_NUM
  sudo GOOGLE_APPLICATION_CREDENTIALS=${HOME}/account-auth.json /opt/google-cloud-sdk/bin/kubectl rollout status deployment/$REPO_NAME
fi

echo "Deployed !"
exit 0;
