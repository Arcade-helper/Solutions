gsutil mb gs://$DEVSHELL_PROJECT_ID
gsutil mb gs://$DEVSHELL_PROJECT_ID-2

echo

echo "${BLUE_TEXT}${BOLD_TEXT}Step 2: Downloading Demo Images...${RESET_FORMAT}"

curl -O https://raw.githubusercontent.com/Arcade-helper/Solutions/main/demo-image1-copy.png
curl -O https://raw.githubusercontent.com/Arcade-helper/Solutions/main/demo-image2.png
curl -O https://raw.githubusercontent.com/Arcade-helper/Solutions/main/demo-image1-copy.png

echo

echo "${BLUE_TEXT}${BOLD_TEXT}Step 3: Uploading Images to Cloud Storage...${RESET_FORMAT}"

gsutil cp demo-image1.png gs://$DEVSHELL_PROJECT_ID/demo-image1.png
gsutil cp demo-image2.png gs://$DEVSHELL_PROJECT_ID/demo-image2.png
gsutil cp demo-image1-copy.png gs://$DEVSHELL_PROJECT_ID-2/demo-image1-copy.png

echo

SCRIPT_NAME="arcadecrew.sh"
if [ -f "$SCRIPT_NAME" ]; then
    echo -e "${BOLD_TEXT}${RED_TEXT}Deleting the script ($SCRIPT_NAME) for safety purposes...${RESET_FORMAT}${NO_COLOR}"
    rm -- "$SCRIPT_NAME"
fi
