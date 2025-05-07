export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud services enable artifactregistry.googleapis.com

gcloud artifacts repositories create container-registry \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repository in $REGION"

gcloud artifacts repositories create go-registry \
  --repository-format=go \
  --location=$REGION \
  --description="Go module repository"
