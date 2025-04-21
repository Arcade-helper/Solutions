gsutil mb -p $DEVSHELL_PROJECT_ID \
    -c standard    \
    -l us \
    gs://$DEVSHELL_PROJECT_ID-vcm/

export BUCKET=$DEVSHELL_PROJECT_ID-vcm

gsutil -m cp -r gs://spls/gsp223/images/* gs://${BUCKET}

gsutil cp gs://spls/gsp223/data.csv .

sed -i -e "s/placeholder/${BUCKET}/g" ./data.csv

gsutil cp ./data.csv gs://${BUCKET}

echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}""https://console.cloud.google.com/vertex-ai/datasets/create?project=$DEVSHELL_PROJECT_ID"""${RESET}"

echo "${YELLOW}${BOLD}NOW${RESET}" "${WHITE}${BOLD}FOLLOW${RESET}" "${GREEN}${BOLD}VIDEO'S INSTRUCTIONS${RESET}"
