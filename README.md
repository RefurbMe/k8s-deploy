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
