gcloud services enable appengine.googleapis.com

cat > prepare_disk.sh <<'EOF_END'

git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git

cd python-docs-samples/appengine/standard_python3/hello_world

EOF_END

export ZONE=$(gcloud compute instances list lab-setup --format 'csv[no-heading](zone)')

export REGION="${ZONE%-*}"

gcloud compute scp prepare_disk.sh lab-setup:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh lab-setup --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"

git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git

cd python-docs-samples/appengine/standard_python3/hello_world

gcloud app create --region=$REGION

yes | gcloud app deploy

sed -i 's/Hello World!/'"$MESSAGE"'/g' main.py

yes | gcloud app deploy
