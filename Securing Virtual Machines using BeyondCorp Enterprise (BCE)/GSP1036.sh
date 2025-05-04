#!/bin/bash
BLUE_TEXT=$'\033[0;94m'
CYAN_TEXT=$'\033[0;96m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
  --format="value(projectNumber)")

gcloud services enable iap.googleapis.com

gcloud compute instances create linux-iap \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=stack-type=IPV4_ONLY,subnet=default,no-address

gcloud compute instances create windows-iap \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=stack-type=IPV4_ONLY,subnet=default,no-address \
  --create-disk=auto-delete=yes,boot=yes,device-name=windows-iap,image=projects/windows-cloud/global/images/windows-server-2016-dc-v20240313,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-standard \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

gcloud compute instances create windows-connectivity \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --create-disk=auto-delete=yes,boot=yes,device-name=windows-connectivity,image=projects/qwiklabs-resources/global/images/iap-desktop-v001,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-standard \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

gcloud compute firewall-rules create allow-ingress-from-iap \
  --network default \
  --allow tcp:22,tcp:3389 \
  --source-ranges 35.235.240.0/20

echo
echo -e "${BLUE_TEXT}${BOLD_TEXT}🔗 Firewall Rule Link: ${UNDERLINE_TEXT}https://console.cloud.google.com/net-security/firewall-manager/firewall-policies/details/allow-ingress-from-iap?project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo
echo -e "${BLUE_TEXT}${BOLD_TEXT}🔗 IAP Settings Link: ${UNDERLINE_TEXT}https://console.cloud.google.com/security/iap?tab=ssh-tcp-resources&project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo
echo
echo -e "${CYAN_TEXT}${BOLD_TEXT}👤 Service Account Email: $PROJECT_NUMBER-compute@developer.gserviceaccount.com${RESET_FORMAT}"
