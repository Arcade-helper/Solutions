export OAUTH2_TOKEN=$(gcloud auth print-access-token)
export USERNAME=$(gcloud config get-value core/account | sed 's/-/_/g; s/@.*//')

echo "${BOLD}${BLUE}Enabling Google Fitness API...${RESET}"
gcloud services enable fitness.googleapis.com

echo "${BOLD}${CYAN}Creating bucket configuration...${RESET}"
echo '{
  "name": "'"$DEVSHELL_PROJECT_ID"'-bucket",
  "location": "us",
  "storageClass": "multi_regional"
}' > values.json

echo "${BOLD}${MAGENTA}Creating Google Cloud Storage bucket...${RESET}"
curl -X POST --data-binary @values.json \
    -H "Authorization: Bearer $OAUTH2_TOKEN" \
    -H "Content-Type: application/json" \
    "https://www.googleapis.com/storage/v1/b?project=$DEVSHELL_PROJECT_ID"

echo "${BOLD}${YELLOW}Downloading demo image...${RESET}"
curl -LO 

echo "${BOLD}${GREEN}Uploading demo image to the bucket...${RESET}"
curl -X POST --data-binary @/home/$USERNAME/demo-image.png \
    -H "Authorization: Bearer $OAUTH2_TOKEN" \
    -H "Content-Type: image/png" \
    "https://www.googleapis.com/upload/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket/o?uploadType=media&name=demo-image"
