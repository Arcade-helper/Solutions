export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(echo "$ZONE" | cut -d '-' -f 1-2)

export VM_EXT_IP=$(gcloud compute instances describe cls-vm --zone=$ZONE \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

gsutil mb -p $DEVSHELL_PROJECT_ID -c STANDARD -l $REGION -b on gs://scc-export-bucket-$DEVSHELL_PROJECT_ID

gsutil uniformbucketlevelaccess set off gs://scc-export-bucket-$DEVSHELL_PROJECT_ID

curl -LO raw.githubusercontent.com/QUICK-GCP-LAB/2-Minutes-Labs-Solutions/refs/heads/main/Mitigate%20Threats%20and%20Vulnerabilities%20with%20Security%20Command%20Center%20Challenge%20Lab/findings.jsonl

gsutil cp findings.jsonl gs://scc-export-bucket-$DEVSHELL_PROJECT_ID

echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}""https://console.cloud.google.com/security/web-scanner/scanConfigs/edit?project=$DEVSHELL_PROJECT_ID"""${RESET}"

echo "${YELLOW}${BOLD}Copy this: "${RESET}""${GREEN}${BOLD}""http://$VM_EXT_IP:8080"""${RESET}"

echo "${YELLOW}${BOLD}NOW${RESET}" "${WHITE}${BOLD}FOLLOW${RESET}" "${GREEN}${BOLD}VIDEO'S INSTRUCTIONS${RESET}"
