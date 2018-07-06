if [ -z "$GCLOUD_SERVICE_KEY" ]; then
  echo "GCLOUD_SERVICE_KEY is not set on your CI"
  exit 1;
fi

REPO_NAME=${CIRCLE_PROJECT_REPONAME,,}

# Authenticate gcloud
echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/account-auth.json
gcloud auth activate-service-account --key-file=${HOME}/account-auth.json

# Configure gcloud (the same steps as you do on your local machine)
gcloud --quiet config set project ${PROJECT_NAME}
gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
gcloud --quiet container clusters get-credentials ${CLUSTER_NAME}

# Configure Docker to use gce
echo Y | gcloud auth configure-docker

# Push version
docker push $IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:$CIRCLE_BUILD_NUM
# Push latest
docker push $IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:latest

# and finally, "deploy" the new image
kubectl set image deployment $REPO_NAME $REPO_NAME=$IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:$CIRCLE_BUILD_NUM --record
# wait until it's completly deployed
kubectl rollout status deployment $REPO_NAME

echo "Deployed !"
exit 0;
