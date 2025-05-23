gcloud auth list

export PROJECT_ID=$DEVSHELL_PROJECT_ID

cat > bucket1.json <<EOF_CP
{
   "name": "$DEVSHELL_PROJECT_ID-bucket-1",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF_CP


curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data-binary @bucket1.json "https://storage.googleapis.com/storage/v1/b?project=$DEVSHELL_PROJECT_ID"


cat > bucket2.json <<EOF_CP
{
   "name": "$DEVSHELL_PROJECT_ID-bucket-2",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF_CP

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data-binary @bucket2.json "https://storage.googleapis.com/storage/v1/b?project=$DEVSHELL_PROJECT_ID"

curl -O https://raw.githubusercontent.com/Arcade-helper/Solutions/main/world.jpeg


curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: image/jpeg" --data-binary @world.jpeg "https://storage.googleapis.com/upload/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o?uploadType=media&name=world.jpeg"


curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data '{"destination": "$DEVSHELL_PROJECT_ID-bucket-2"}' "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/world.jpeg/copyTo/b/$DEVSHELL_PROJECT_ID-bucket-2/o/world.jpeg"


cat > public_access.json <<EOF
{
  "entity": "allUsers",
  "role": "READER"
}
EOF


curl -X POST --data-binary @public_access.json -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/world.jpeg/acl"

