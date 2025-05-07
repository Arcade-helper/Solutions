 export REGION=$(gcloud compute project-info describe \
 --format="value(commonInstanceMetadata.items[google-compute-default-region])")

 gcloud services enable artifactregistry.googleapis.com

 gcloud artifacts repositories create container-registry \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker registry with cleanup policy"

 gcloud artifacts repositories create python-registry \
  --repository-format=python \
  --location=$REGION \
  --description="Python registry with cleanup policy"
