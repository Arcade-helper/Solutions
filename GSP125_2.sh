echo "Please enter the ZONE:"
read ZONE
export ZONE

if [ -z "$DEVSHELL_PROJECT_ID" ]; then
  echo "Error: DEVSHELL_PROJECT_ID is not set."
  echo "Please enter your GCP project ID:"
  read DEVSHELL_PROJECT_ID
  export DEVSHELL_PROJECT_ID
  echo "The project ID is set to: $DEVSHELL_PROJECT_ID"
fi

echo
gcloud compute ssh "speaking-with-a-webpage" --zone "$ZONE" --project "$DEVSHELL_PROJECT_ID" --quiet --command "pkill -f 'java.*jetty'"

sleep 5
echo
gcloud compute ssh "speaking-with-a-webpage" --zone "$ZONE" --project "$DEVSHELL_PROJECT_ID" --quiet --command "cd ~/speaking-with-a-webpage/02-webaudio && mvn clean jetty:run"
