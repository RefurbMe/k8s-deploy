if [ -z "$GCLOUD_SERVICE_KEY" ]; then
  echo "GCLOUD_SERVICE_KEY is not set on your CI"
  exit 1;
else

  echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/account-auth.json
  # Authenticate gcloud
  gcloud auth activate-service-account --key-file=${HOME}/account-auth.json
  # Configure gcloud (the same steps as you do on your local machine)
  gcloud --quiet config set project ${PROJECT_NAME}
  gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
  gcloud --quiet container clusters get-credentials ${CLUSTER_NAME}
  # Push version
  gcloud docker --docker-host=$DOCKER_HOST -- --tlsverify --tlscacert $DOCKER_CERT_PATH/ca.pem --tlscert $DOCKER_CERT_PATH/cert.pem --tlskey $DOCKER_CERT_PATH/key.pem push $IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:$CIRCLE_BUILD_NUM
  # Push latest
  gcloud docker --docker-host=$DOCKER_HOST -- --tlsverify --tlscacert $DOCKER_CERT_PATH/ca.pem --tlscert $DOCKER_CERT_PATH/cert.pem --tlskey $DOCKER_CERT_PATH/key.pem push $IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:latest
  # and finally, "deploy" the new image
  kubectl set image deployment $REPO_NAME $REPO_NAME=$IMAGE_REGISTRY/$PROJECT_NAME/$REPO_NAME:$CIRCLE_BUILD_NUM --record
fi

echo "Deployed !"
exit 0;
