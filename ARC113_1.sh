gcloud pubsub subscriptions create pubsub-subscription-message --topic gcloud-pubsub-topic

gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"

sleep 20

gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5

gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
