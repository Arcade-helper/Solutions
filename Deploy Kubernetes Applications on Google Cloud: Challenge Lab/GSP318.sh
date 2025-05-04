export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

source <(gsutil cat gs://cloud-training/gsp318/marking/setup_marking_v2.sh)

gsutil cp gs://spls/gsp318/valkyrie-app.tgz .
tar -xzf valkyrie-app.tgz
cd valkyrie-app

cat > Dockerfile <<EOF
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF

docker build -t $DCKR_IMG:$TAG .

cd ..
./step1_v2.sh

cd valkyrie-app
docker run -d -p 8080:8080 $DCKR_IMG:$TAG

cd ..
./step2_v2.sh

cd valkyrie-app

gcloud artifacts repositories create $REPO \
    --repository-format=docker \
    --location=$REGION \
    --description="awesome lab" \
    --async

gcloud auth configure-docker $REGION-docker.pkg.dev --quiet

sleep 30

Image_ID=$(docker images --format='{{.ID}}')

docker tag $Image_ID $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DCKR_IMG:$TAG

docker push $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DCKR_IMG:$TAG

sed -i s#IMAGE_HERE#$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DCKR_IMG:$TAG#g k8s/deployment.yaml

gcloud container clusters get-credentials valkyrie-dev --zone $ZONE

kubectl create -f k8s/deployment.yaml
kubectl create -f k8s/service.yaml
