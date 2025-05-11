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

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Step 1: Display contents of installhugo.sh
echo "${BOLD}${GREEN}Displaying installhugo.sh contents...${RESET}"
cat /tmp/installhugo.sh

# Step 2: Move to home directory and execute installhugo.sh
echo "${BOLD}${YELLOW}Moving to home directory and executing installhugo.sh...${RESET}"
cd ~
/tmp/installhugo.sh

# Step 3: Set project environment variables
echo "${BOLD}${BLUE}Setting project environment variables...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Step 4: Update and install required packages
echo "${BOLD}${MAGENTA}Updating system and installing Git & GitHub CLI...${RESET}"
sudo apt-get update
sudo apt-get install git
sudo apt-get install gh

# Step 5: Install GitHub CLI using webi.sh
echo "${BOLD}${CYAN}Installing GitHub CLI using webi.sh...${RESET}"
curl -sS https://webi.sh/gh | sh

# Step 6: Authenticate GitHub CLI
echo "${BOLD}${YELLOW}Authenticating GitHub CLI...${RESET}"
gh auth login
gh api user -q ".login"

# Step 7: Configure GitHub user details
echo "${BOLD}${GREEN}Configuring GitHub user details...${RESET}"
GITHUB_USERNAME=$(gh api user -q ".login")
git config --global user.name "${GITHUB_USERNAME}"
git config --global user.email "${USER_EMAIL}"
echo ${GITHUB_USERNAME}
echo ${USER_EMAIL}

# Step 8: Create and clone Hugo site repository
echo "${BOLD}${YELLOW}Creating and cloning Hugo site repository...${RESET}"
cd ~
gh repo create  my_hugo_site --private 
gh repo clone  my_hugo_site 

# Step 9: Initialize Hugo site
echo "${BOLD}${BLUE}Initializing Hugo site...${RESET}"
cd ~
/tmp/hugo new site my_hugo_site --force

# Step 10: Clone Hugo theme
echo "${BOLD}${MAGENTA}Cloning Hugo theme...${RESET}"
cd ~/my_hugo_site
git clone \
  https://github.com/rhazdon/hugo-theme-hello-friend-ng.git themes/hello-friend-ng
echo 'theme = "hello-friend-ng"' >> config.toml

# Step 11: Remove unnecessary Git files from theme
echo "${BOLD}${CYAN}Removing unnecessary Git files from theme...${RESET}"
sudo rm -r themes/hello-friend-ng/.git
sudo rm themes/hello-friend-ng/.gitignore 

# Step 12: Start Hugo server in the background
echo "${BOLD}${RED}Starting Hugo server in the background...${RESET}"
nohup /tmp/hugo server -D --bind 0.0.0.0 --port 8080 > hugo.log 2>&1 &

echo "Hugo server is running in the background with PID: $!"
echo "To stop it, run: kill $!"

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "${BOLD}${YELLOW}Have you checked your progress upto Task 1 ? (Y/N): ${RESET}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${BOLD}${GREEN}Great! Proceeding to the next steps...${RESET}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${BOLD}${RED}Please check your progress upto Task 1 and then press Y to continue.${RESET}"
        else
            echo
            echo "${BOLD}${MAGENTA}Invalid input. Please enter Y or N.${RESET}"
        fi
    done
}

# Call function to check progress before proceeding
check_progress

# Step 13: Install Firebase CLI
echo "${BOLD}${GREEN}Installing Firebase CLI...${RESET}"
curl -sL https://firebase.tools | bash

# Step 14: Initialize Firebase project
echo "${BOLD}${YELLOW}Initializing Firebase project...${RESET}"
cd ~/my_hugo_site
firebase init

# Step 15: Deploy Hugo site to Firebase
echo "${BOLD}${BLUE}Deploying Hugo site to Firebase...${RESET}"
/tmp/hugo && firebase deploy

# Step 16: Configure Git user details for commits
echo "${BOLD}${MAGENTA}Configuring Git user details for commits...${RESET}"
git config --global user.name "hugo"
git config --global user.email "hugo@blogger.com"

# Step 17: Ignore resources directory and push to GitHub
echo "${BOLD}${CYAN}Ignoring resources directory and pushing to GitHub...${RESET}"
cd ~/my_hugo_site
echo "resources" >> .gitignore

git add .
git commit -m "Add app to GitHub Repository"
git push -u origin master

# Step 18: Copy cloudbuild.yaml and display its content
echo "${BOLD}${RED}Copying and displaying cloudbuild.yaml...${RESET}"
cd ~/my_hugo_site
cp /tmp/cloudbuild.yaml .

cat cloudbuild.yaml

# Step 19: Create Cloud Build GitHub connection
echo "${BOLD}${GREEN}Creating Cloud Build GitHub connection...${RESET}"
gcloud builds connections create github cloud-build-connection --project=$PROJECT_ID  --region=$REGION

echo

# Step 20: Display Cloud Build Repositories Console Link
echo "${BOLD}${BLUE}Open Cloud Build Repositories Console: ${RESET}""https://console.cloud.google.com/cloud-build/repositories/2nd-gen?project=$PROJECT_ID"

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "${BOLD}${YELLOW}Have you Installed the Cloud Build GitHub App ? (Y/N): ${RESET}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${BOLD}${GREEN}Great! Proceeding to the next steps...${RESET}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${BOLD}${RED}Please Install the Cloud Build GitHub App and then press Y to continue.${RESET}"
        else
            echo
            echo "${BOLD}${MAGENTA}Invalid input. Please enter Y or N.${RESET}"
        fi
    done
}

# Call function to check progress before proceeding
check_progress

# Step 21: Describe Cloud Build connection
echo "${BOLD}${YELLOW}Describing Cloud Build connection...${RESET}"
gcloud builds connections describe cloud-build-connection --region=$REGION

# Step 22: Create a Cloud Build repository connection
echo "${BOLD}${MAGENTA}Creating Cloud Build repository connection...${RESET}"
gcloud builds repositories create hugo-website-build-repository \
  --remote-uri="https://github.com/${GITHUB_USERNAME}/my_hugo_site.git" \
  --connection="cloud-build-connection" --region=$REGION

# Step 23: Create Cloud Build trigger
echo "${BOLD}${CYAN}Creating Cloud Build trigger...${RESET}"
gcloud builds triggers create github --name="commit-to-master-branch1" \
   --repository=projects/$PROJECT_ID/locations/$REGION/connections/cloud-build-connection/repositories/hugo-website-build-repository \
   --build-config='cloudbuild.yaml' \
   --service-account=projects/$PROJECT_ID/serviceAccounts/$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
   --region=$REGION \
   --branch-pattern='^master$'

# Step 24: Update the site title in config.toml
echo "${BOLD}${RED}Updating the site title in config.toml...${RESET}"
sed -i "s/^title = .*/title = 'Blogging with Hugo and Cloud Build'/" config.toml

# Step 25: Add, commit, and push changes to Git
echo "${BOLD}${GREEN}Adding, committing, and pushing changes to Git...${RESET}"
git add .
git commit -m "I updated the site title"
git push -u origin master

sleep 15

# Step 26: List all builds in Cloud Build
echo "${BOLD}${YELLOW}Listing Cloud Builds...${RESET}"
gcloud builds list --region=$REGION

# Step 27: Fetch and display logs for the latest build
echo "${BOLD}${BLUE}Fetching logs for the latest Cloud Build...${RESET}"
gcloud builds log --region=$REGION $(gcloud builds list --format='value(ID)' --filter=$(git rev-parse HEAD) --region=$REGION)

# Step 28: Sleep for 15 seconds to allow build logs to update
echo "${BOLD}${MAGENTA}Sleeping for 15 seconds to allow logs to update...${RESET}"
sleep 15

# Step 29: Extract and display the Hosting URL from Cloud Build logs
echo "${BOLD}${CYAN}Extracting Hosting URL from Cloud Build logs...${RESET}"
gcloud builds log "$(gcloud builds list --format='value(ID)' --filter=$(git rev-parse HEAD) --region=$REGION)" --region=$REGION | grep "Hosting URL"

echo
echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files
