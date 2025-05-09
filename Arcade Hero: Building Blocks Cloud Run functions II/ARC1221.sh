read -p "Export REGION :- " REGION

REPO_NAME="container-registry"
FORMAT="DOCKER"
POLICY_NAME="Grandfather"
KEEP_COUNT=3

gcloud artifacts repositories create $REPO_NAME \
  --repository-format=$FORMAT \
  --location=$REGION \
  --description="Docker repo for container images"

gcloud artifacts policies create $POLICY_NAME \
   --repository=$REPO_NAME \
   --location=$REGION \
   --package-type=$FORMAT \
   --keep-count=$KEEP_COUNT \
   --action=DELETE
