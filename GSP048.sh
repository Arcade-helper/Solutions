#!/bin/bash

# Define color variables
RED_TEXT=$'\033[0;91m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
GREEN_TEXT=$'\033[0;92m'
clear

cat > prepare_disk.sh <<'EOF_END'

gcloud services enable apikeys.googleapis.com

gcloud alpha services api-keys create --display-name="awesome" 

KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=awesome")

API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")

cat > request.json <<EOF

{
    "config": {
            "encoding":"FLAC",
            "languageCode": "en-US"
    },
    "audio": {
            "uri":"gs://cloud-samples-data/speech/brooklyn_bridge.flac"
    }
}

EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json

cat result.json

EOF_END

export ZONE=$(gcloud compute instances list linux-instance --format 'csv[no-heading](zone)')

gcloud compute scp prepare_disk.sh linux-instance:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh linux-instance --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"

read -p "${RED_TEXT}${BOLD_TEXT}Have you checked the progress till TASK 3 (Y/N)?${RESET_FORMAT}" response

if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "${GREEN_TEXT}Proceeding with next steps!${RESET_FORMAT}"
else
        echo "${RED_TEXT}Please check the progress before proceeding.${RESET_FORMAT}"
fi

cat > prepare_disk.sh <<'EOF_END'

KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=awesome")

API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")

rm -f request.json

cat >> request.json <<EOF

 {
    "config": {
            "encoding":"FLAC",
            "languageCode": "fr"
    },
    "audio": {
            "uri":"gs://cloud-samples-data/speech/corbeau_renard.flac"
    }
}

EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json

cat result.json

EOF_END

export ZONE=$(gcloud compute instances list linux-instance --format 'csv[no-heading](zone)')

gcloud compute scp prepare_disk.sh linux-instance:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh linux-instance --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"
