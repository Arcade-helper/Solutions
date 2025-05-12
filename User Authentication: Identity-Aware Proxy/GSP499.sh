gcloud services enable iap.googleapis.com

gcloud auth list

gcloud config list project

gsutil cp gs://spls/gsp499/user-authentication-with-iap.zip .

unzip user-authentication-with-iap.zip

cd user-authentication-with-iap

gcloud services enable appengineflex.googleapis.com

cd 1-HelloWorld

sed -i 's/python37/python39/g' app.yaml

gcloud app create --region=$REGION

deploy_function() {
  yes | gcloud app deploy
}

deploy_success=false

while [ "$deploy_success" = false ]; do
  if deploy_function; then
    echo "Function deployed successfully."
    deploy_success=true
  else
    echo "Retrying..."
    sleep 10
  fi
done

cd ~/user-authentication-with-iap/2-HelloUser

sed -i 's/python37/python39/g' app.yaml

deploy_function() {
  yes | gcloud app deploy
}

deploy_success=false

while [ "$deploy_success" = false ]; do
  if deploy_function; then
    echo "Function deployed successfully."
    deploy_success=true
  else
    echo "Retrying..."
    sleep 10
  fi
done

cd ~/user-authentication-with-iap/3-HelloVerifiedUser

sed -i 's/python37/python39/g' app.yaml

deploy_function() {
  yes | gcloud app deploy
}

deploy_success=false

while [ "$deploy_success" = false ]; do
  if deploy_function; then
    echo "Function deployed successfully."
    deploy_success=true
  else
    echo "Retrying..."
    sleep 10
  fi
done

EMAIL="$(gcloud config get-value core/account)" # This uses your current user/email

LINK=$(gcloud app browse)

LINKU=${LINK#https://}

cat > details.json << EOF
{
  App name: IAP Example
  Application home page: $LINK
  Application privacy Policy link: $LINK/privacy
  Authorized domains: $LINKU
  Developer Contact Information: $EMAIL
}
EOF

cat details.json
