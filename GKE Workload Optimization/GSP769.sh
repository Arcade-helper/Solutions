#!/bin/bash

# Define color variables
YELLOW_TEXT=$'\033[0;33m'
MAGENTA_TEXT=$'\033[0;35m'
NO_COLOR=$'\033[0m'
GREEN_TEXT=$'\033[0;32m'
RED_TEXT=$'\033[0;31m'
CYAN_TEXT=$'\033[0;36m'
BOLD_TEXT=$'\033[1m'
RESET_FORMAT=$'\033[0m'
BLUE_TEXT=$'\033[0;34m'

export ZONE=$ZONE

gcloud config set compute/zone $ZONE

gcloud container clusters create test-cluster --num-nodes=3 --enable-ip-alias

cat << EOF > gb_frontend_pod.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: gb-frontend
  name: gb-frontend
spec:
    containers:
    - name: gb-frontend
      image: gcr.io/google-samples/gb-frontend-amd64:v5
      resources:
        requests:
          cpu: 100m
          memory: 256Mi
      ports:
      - containerPort: 80
EOF

kubectl apply -f gb_frontend_pod.yaml

cat << EOF > gb_frontend_cluster_ip.yaml
apiVersion: v1
kind: Service
metadata:
  name: gb-frontend-svc
  annotations:
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: ClusterIP
  selector:
    app: gb-frontend
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
EOF

kubectl apply -f gb_frontend_cluster_ip.yaml

cat << EOF > gb_frontend_ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gb-frontend-ingress
spec:
  defaultBackend:
    service:
      name: gb-frontend-svc
      port:
        number: 80
EOF

kubectl apply -f gb_frontend_ingress.yaml

sleep 70

BACKEND_SERVICE=$(gcloud compute backend-services list | grep NAME | cut -d ' ' -f2)
gcloud compute backend-services get-health $BACKEND_SERVICE --global

kubectl get ingress gb-frontend-ingress

# Prompt user to check the score for Task 1
echo "${YELLOW_TEXT}${BOLD_TEXT}NOW${RESET_FORMAT} ${WHITE_TEXT}${BOLD_TEXT}Check The Score${RESET_FORMAT} ${GREEN_TEXT}${BOLD_TEXT}For Task 1.${RESET_FORMAT}"

while true; do
    read -p "${MAGENTA_TEXT}${BOLD_TEXT}Have you checked the progress for Task 1? (Y/N): ${RESET_FORMAT}" user_input
    case $user_input in
        [Yy]|[Yy][Ee][Ss])
            echo "${GREEN_TEXT}Proceeding to the next step...${RESET_FORMAT}"
            break
            ;;
        [Nn]|[Nn][Oo])
            echo "${RED_TEXT}Please check the progress for Task 1 before proceeding.${RESET_FORMAT}"
            ;;
        *)
            echo "${RED_TEXT}Invalid input. Please enter Y or N.${RESET_FORMAT}"
            ;;
    esac
done

gsutil -m cp -r gs://spls/gsp769/locust-image .
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/locust-tasks:latest locust-image

gcloud container images list

gsutil cp gs://spls/gsp769/locust_deploy_v2.yaml .
sed 's/${GOOGLE_CLOUD_PROJECT}/'$GOOGLE_CLOUD_PROJECT'/g' locust_deploy_v2.yaml | kubectl apply -f -

sleep 70

cat << EOF > liveness-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    demo: liveness-probe
  name: liveness-demo-pod
spec:
  containers:
  - name: liveness-demo-pod
    image: centos
    args:
    - /bin/sh
    - -c
    - touch /tmp/alive; sleep infinity
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/alive
      initialDelaySeconds: 5
      periodSeconds: 10
EOF

kubectl apply -f liveness-demo.yaml

kubectl describe pod liveness-demo-pod

kubectl exec liveness-demo-pod -- rm /tmp/alive

kubectl describe pod liveness-demo-pod

cat << EOF > readiness-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    demo: readiness-probe
  name: readiness-demo-pod
spec:
  containers:
  - name: readiness-demo-pod
    image: nginx
    ports:
    - containerPort: 80
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/healthz
      initialDelaySeconds: 5
      periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: readiness-demo-svc
  labels:
    demo: readiness-probe
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  selector:
    demo: readiness-probe
EOF

kubectl apply -f readiness-demo.yaml

sleep 70

kubectl exec readiness-demo-pod -- touch /tmp/healthz

kubectl describe pod readiness-demo-pod | grep ^Conditions -A 5

kubectl delete pod gb-frontend

cat << EOF > gb_frontend_deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gb-frontend
  labels:
    run: gb-frontend
spec:
  replicas: 5
  selector:
    matchLabels:
      run: gb-frontend
  template:
    metadata:
      labels:
        run: gb-frontend
    spec:
      containers:
        - name: gb-frontend
          image: gcr.io/google-samples/gb-frontend-amd64:v5
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
          ports:
            - containerPort: 80
              protocol: TCP
EOF

kubectl apply -f gb_frontend_deployment.yaml
