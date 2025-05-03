gsutil mb gs://$DEVSHELL_PROJECT_ID

curl -O 
curl -O 

gsutil cp start_station_name.csv gs://$DEVSHELL_PROJECT_ID/
gsutil cp end_station_name.csv gs://$DEVSHELL_PROJECT_ID/

gcloud sql instances create my-demo \
    --database-version=MYSQL_8_0 \
    --region=$REGION \
    --tier=db-f1-micro \
    --root-password=arcadehelper

gcloud sql databases create bike --instance=my-demo
