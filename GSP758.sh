read -p "$(echo -e ${WHITE_TEXT}${BOLD_TEXT}Enter your zone: ${RESET_FORMAT})" ZONE

gcloud services enable notebooks.googleapis.com

gcloud services enable aiplatform.googleapis.com

sleep 15

export NOTEBOOK_NAME="lab-workbench"
export MACHINE_TYPE="e2-standard-2"

gcloud notebooks instances create $NOTEBOOK_NAME \
  --location=$ZONE \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf-latest-cpu

PROJECT_ID=$(gcloud config get-value project)

echo "${BLUE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/vertex-ai/workbench/user-managed?project=$DEVSHELL_PROJECT_ID ${RESET_FORMAT}"
