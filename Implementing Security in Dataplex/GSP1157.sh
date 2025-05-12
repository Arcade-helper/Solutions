gcloud services enable dataplex.googleapis.com

gcloud services enable datacatalog.googleapis.com

gcloud dataplex lakes create customer-info-lake \
  --location=$REGION \
  --display-name="Customer Info Lake"

gcloud alpha dataplex zones create customer-raw-zone \
            --location=$REGION --lake=customer-info-lake \
            --resource-location-type=SINGLE_REGION --type=RAW \
            --display-name="Customer Raw Zone"

gcloud dataplex assets create customer-online-sessions --location=$REGION \
            --lake=customer-info-lake --zone=customer-raw-zone \
            --resource-type=STORAGE_BUCKET \
            --resource-name=projects/$DEVSHELL_PROJECT_ID/buckets/$DEVSHELL_PROJECT_ID-bucket \
            --display-name="Customer Online Sessions"
