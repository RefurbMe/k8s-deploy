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

```

# Edit in batch environment variables for CircleCI
```sh

CIRCLE_TOKEN="xxxxxxx"
repos=( "service-1" "service-2" "service-3" "service-4" )

for repo in "${repos[@]}"
do
  echo "\n$repo\n"

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"GCLOUD_SERVICE_KEY\", \"value\":\"${GCLOUD_SERVICE_KEY}\"}" "https://circleci.com/api/v1.1/project/github/RefurbMe/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"PROJECT_NAME\", \"value\":\"${PROJECT_NAME}\"}" "https://circleci.com/api/v1.1/project/github/RefurbMe/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"CLOUDSDK_COMPUTE_ZONE\", \"value\":\"${CLOUDSDK_COMPUTE_ZONE}\"}" "https://circleci.com/api/v1.1/project/github/RefurbMe/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"

  curl -X POST --header "Content-Type: application/json" -d "{\"name\":\"CLUSTER_NAME\", \"value\":\"${CLUSTER_NAME}\"}" "https://circleci.com/api/v1.1/project/github/RefurbMe/${repo}/envvar?circle-token=${CIRCLE_TOKEN}"

  sleep 1;
done
```
