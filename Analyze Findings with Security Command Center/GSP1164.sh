clear

#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)


export PROJECT_ID=$(gcloud config get project)

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

export BUCKET_NAME="scc-export-bucket-$PROJECT_ID"

gcloud pubsub topics create projects/$DEVSHELL_PROJECT_ID/topics/export-findings-pubsub-topic

gcloud pubsub subscriptions create export-findings-pubsub-topic-sub --topic=projects/$DEVSHELL_PROJECT_ID/topics/export-findings-pubsub-topic

echo "${BOLD}${BLUE}Please open the URL to create export-findings-pubsub: ${RESET}""https://console.cloud.google.com/security/command-center/config/continuous-exports/pubsub?project=$DEVSHELL_PROJECT_ID"

function check_progress {
    while true; do
        echo
        echo -n "${BOLD}${YELLOW}Have you created ${WHITE}export-findings-pubsub${YELLOW} ? (Y/N): ${RESET}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${BOLD}${GREEN}Great! Proceeding to the next steps...${RESET}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${BOLD}${RED}Please create ${WHITE}export-findings-pubsub${RED} and then press Y to continue.${RESET}"
        else
            echo
            echo "${BOLD}${MAGENTA}Invalid input. Please enter Y or N.${RESET}"
        fi
    done
}

check_progress

gcloud compute instances create instance-1 --zone=$ZONE \
--machine-type e2-micro \
--scopes=https://www.googleapis.com/auth/cloud-platform

bq --location=$REGION --apilog=/dev/null mk --dataset \
$PROJECT_ID:continuous_export_dataset

check_and_enable_securitycenter() {
  echo "${BOLD}${BLUE}Checking if Security Center API is already enabled...${RESET}"
  is_enabled=$(gcloud services list --enabled --filter="securitycenter.googleapis.com" --format="value(NAME)" 2>/dev/null)

  if [ "$is_enabled" == "securitycenter.googleapis.com" ]; then
    # If the API is enabled, do nothing and suppress output
    echo "${BOLD}${CYAN}Security Center API is already enabled.${RESET}"
  else
    # Enabling Security Center API quietly
    echo "${BOLD}${RED}Security Center API is not enabled. Enabling now...${RESET}"
    gcloud services enable securitycenter.googleapis.com --quiet >/dev/null 2>&1

    # Wait until the API is enabled
    echo "${BOLD}${MAGENTA}Waiting for Security Center API to be enabled...${RESET}"
    while true; do
      is_enabled=$(gcloud services list --enabled --filter="securitycenter.googleapis.com" --format="value(NAME)" 2>/dev/null)
      if [ "$is_enabled" == "securitycenter.googleapis.com" ]; then
        echo "${BOLD}${GREEN}Security Center API has been enabled successfully.${RESET}"
        break
      fi
      # Wait before checking again
      echo "${BOLD}${RED}Still waiting for API to be enabled... checking again in 5 seconds.${RESET}"
    done
  fi
}

check_and_enable_securitycenter

gcloud scc bqexports create scc-bq-cont-export --dataset=projects/$PROJECT_ID/datasets/continuous_export_dataset --project=$PROJECT_ID --quiet

for i in {0..2}; do
gcloud iam service-accounts create sccp-test-sa-$i;
gcloud iam service-accounts keys create /tmp/sa-key-$i.json \
--iam-account=sccp-test-sa-$i@$PROJECT_ID.iam.gserviceaccount.com;
done

function wait_for_findings() {
  while true; do
    echo "${BOLD}${CYAN}Running query to check for findings...${RESET}"
    result=$(bq query --apilog=/dev/null --use_legacy_sql=false --format=pretty \
      "SELECT finding_id, event_time, finding.category FROM continuous_export_dataset.findings")

    # Check if result contains any rows excluding headers and formatting lines
    if echo "$result" | grep -qE '^[|] [a-f0-9]{32} '; then
      echo "${BOLD}${GREEN}Findings detected!${RESET}"
      echo "$result"
      break
    else
      echo "${BOLD}${YELLOW}No findings yet. Waiting for 2 minutes...${RESET}"
      sleep 120
    fi
  done
}

wait_for_findings

gsutil mb -l $REGION gs://$BUCKET_NAME/

gsutil pap set enforced gs://$BUCKET_NAME

sleep 15

gcloud scc findings list "projects/$PROJECT_ID" \
  --format=json \
  | jq -c '.[]' \
  > findings.jsonl

sleep 15

gsutil cp findings.jsonl gs://$BUCKET_NAME/

echo "${BOLD}${GREEN}Open BigQuery Console to create ${WHITE}old_findings${GREEN} table:${RESET}" "https://console.cloud.google.com/bigquery?project=$DEVSHELL_PROJECT_ID"
