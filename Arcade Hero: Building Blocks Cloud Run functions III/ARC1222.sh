export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud services enable artifactregistry.googleapis.com

gcloud artifacts repositories create container-registry \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repo with cleanup policy"

gcloud artifacts repositories create maven-registry \
  --repository-format=maven \
  --location=$REGION \
  --description="Maven repo with cleanup policy"
