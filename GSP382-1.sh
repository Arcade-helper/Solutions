gcloud scc muteconfigs create muting-flow-log-findings \
  --project=$DEVSHELL_PROJECT_ID \
  --location=global \
  --description="Rule for muting VPC Flow Logs" \
  --filter="category=\"FLOW_LOGS_DISABLED\"" \
  --type=STATIC

gcloud scc muteconfigs create muting-audit-logging-findings \
  --project=$DEVSHELL_PROJECT_ID \
  --location=global \
  --description="Rule for muting audit logs" \
  --filter="category=\"AUDIT_LOGGING_DISABLED\"" \
  --type=STATIC

gcloud scc muteconfigs create muting-admin-sa-findings \
  --project=$DEVSHELL_PROJECT_ID \
  --location=global \
  --description="Rule for muting admin service account findings" \
  --filter="category=\"ADMIN_SERVICE_ACCOUNT\"" \
  --type=STATIC

echo "${YELLOW}${BOLD}Check Score ${RESET}""${WHITE}${BOLD}for task 2${RESET}" "${GREEN}${BOLD}then press Y${RESET}"

gcloud compute firewall-rules delete default-allow-rdp

gcloud compute firewall-rules create default-allow-rdp \
  --source-ranges=35.235.240.0/20 \
  --allow=tcp:3389 \
  --description="Allow HTTP traffic from 35.235.240.0/20" \
  --priority=65534

gcloud compute firewall-rules delete default-allow-ssh --quiet

gcloud compute firewall-rules create default-allow-ssh \
  --source-ranges=35.235.240.0/20 \
  --allow=tcp:22 \
  --description="Allow HTTP traffic from 35.235.240.0/20" \
  --priority=65534

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}""https://console.cloud.google.com/compute/instancesEdit/zones/$ZONE/instances/cls-vm?project=$DEVSHELL_PROJECT_ID"""${RESET}"

echo "${YELLOW}${BOLD}NOW${RESET}" "${WHITE}${BOLD}FOLLOW${RESET}" "${GREEN}${BOLD}VIDEO'S INSTRUCTIONS${RESET}"
