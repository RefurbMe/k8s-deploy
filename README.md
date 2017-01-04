# Kubernetes deploy script for CI

Deploy changes to your k8s deployments right from your CI tool.

## Required environment variables
- `REPO_NAME`: Image name (if you use CircleCI, you can use `REPO_NAME=${CIRCLE_PROJECT_REPONAME,,}`)
- `PROJECT_NAME`: Your Google cloud engine project name
- `CLUSTER_NAME`: Your Google container engine cluster name
- `CLOUDSDK_COMPUTE_ZONE`: Compute zone of your nodes
- `GCLOUD_SERVICE_KEY`: base64 hash of your iam key (check below for instructions)

## Generate GCLOUD_SERVICE_KEY
```sh
PROJECT_NAME="your-project-name"
gcloud iam service-accounts create circleci --display-name=circleci
gcloud projects add-iam-policy-binding ${PROJECT_NAME} --member serviceAccount:circleci@${PROJECT_NAME}.iam.gserviceaccount.com --role roles/container.admin
gcloud projects add-iam-policy-binding ${PROJECT_NAME} --member serviceAccount:circleci@${PROJECT_NAME}.iam.gserviceaccount.com --role roles/container.clusterAdmin
gcloud projects add-iam-policy-binding ${PROJECT_NAME} --member serviceAccount:circleci@${PROJECT_NAME}.iam.gserviceaccount.com --role roles/container.developer
gcloud projects add-iam-policy-binding ${PROJECT_NAME} --member serviceAccount:circleci@${PROJECT_NAME}.iam.gserviceaccount.com --role roles/storage.admin
gcloud iam service-accounts keys create key.json --iam-account circleci@${PROJECT_NAME}.iam.gserviceaccount.com
GCLOUD_SERVICE_KEY=`base64 key.json`
```


# Setup your Kubernetes cluster (sample code)
Full instructions on: https://github.com/RefurbMe/k8s-sample

# Edit in batch environment variables for CircleCI
```sh
# GCLOUD_SERVICE_KEY=`base64 key.json` # comes from the guide above

CIRCLE_TOKEN="your-circleci-api-token"
GIT_ACCOUNT="your-github-username"

IMAGE_REGISTRY='us.gcr.io'
PROJECT_NAME="your-project-name"
CLOUDSDK_COMPUTE_ZONE='us-east1-b'
CLUSTER_NAME="your-cluster-name"
repos=( "api" "frontend" )

for repo in "${repos[@]}"
do
  echo "\n$repo\n"

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"GCLOUD_SERVICE_KEY\", \"value\":\"${GCLOUD_SERVICE_KEY}\"}" "https://circleci.com/api/v1.1/project/github/${GIT_ACCOUNT}/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"
  sleep 0.5;

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"IMAGE_REGISTRY\", \"value\":\"${IMAGE_REGISTRY}\"}" "https://circleci.com/api/v1.1/project/github/${GIT_ACCOUNT}/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"
  sleep 0.5;

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"PROJECT_NAME\", \"value\":\"${PROJECT_NAME}\"}" "https://circleci.com/api/v1.1/project/github/${GIT_ACCOUNT}/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"
  sleep 0.5;

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"CLOUDSDK_COMPUTE_ZONE\", \"value\":\"${CLOUDSDK_COMPUTE_ZONE}\"}" "https://circleci.com/api/v1.1/project/github/${GIT_ACCOUNT}/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"
  sleep 0.5;

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"CLUSTER_NAME\", \"value\":\"${CLUSTER_NAME}\"}" "https://circleci.com/api/v1.1/project/github/${GIT_ACCOUNT}/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"
  sleep 0.5;
done
```
