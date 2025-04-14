export MSG_BODY='Hello World!'

gcloud pubsub topics create cloud-pubsub-topic

gcloud pubsub subscriptions create cloud-pubsub-subscription --topic=cloud-pubsub-topic

gcloud services enable cloudscheduler.googleapis.com

gcloud scheduler jobs create pubsub cron-scheduler-job \
  --location=$LOCATION \
  --schedule="* * * * *" \
  --topic=cloud-pubsub-topic \
  --message-body="Hello World!"

gcloud pubsub subscriptions pull cloud-pubsub-subscription --limit 5
