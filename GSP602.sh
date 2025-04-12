export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

gcloud services enable cloudfunctions.googleapis.com

gcloud services enable run.googleapis.com

curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip
unzip main.zip
cd golang-samples-main/functions/codelabs/gopher

gcloud functions deploy HelloWorld --gen2 --runtime go121 --trigger-http --region $REGION --allow-unauthenticated

curl https://$REGION-$GOOGLE_CLOUD_PROJECT.cloudfunctions.net/HelloWorld

gcloud functions deploy Gopher --gen2 --runtime go121 --trigger-http --region $REGION --allow-unauthenticated
