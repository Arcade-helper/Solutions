change_zone_automatically() {

    # Check if the command was successful
    if [[ -z "$ZONE_1" ]]; then
        echo "Could not retrieve the current zone. Exiting."
        return 1
    fi

    echo "Current Zone (ZONE_1): $ZONE_1"

    # Extract the zone prefix (everything except the last character)
    zone_prefix=${ZONE_1::-1}

    # Extract the last character
    last_char=${ZONE_1: -1}

    # Define a list of valid zone characters
    valid_chars=("b" "c" "d")

    # Find the next valid character in the list
    new_char=$last_char
    for char in "${valid_chars[@]}"; do
        if [[ $char != "$last_char" ]]; then
            new_char=$char
            break
        fi
    done

    # Construct the new zone and store it in ZONE_2
    ZONE_2="${zone_prefix}${new_char}"

    # Export the new zone to the environment variable
    export ZONE_2
    echo "New Zone (ZONE_2) is now set to: $ZONE_2"
}

echo "${CYAN}${BOLD}Retrieving default zone and region.${RESET}"
export ZONE_1=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Step 2: Create firewall rule to allow HTTP traffic
echo "${MAGENTA}${BOLD}Creating firewall rule to allow HTTP traffic.${RESET}"
gcloud compute firewall-rules create app-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=my-internal-app \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=10.10.0.0/16 \
    --target-tags=lb-backend

# Step 3: Create firewall rule to allow health checks
echo "${RED}${BOLD}Creating firewall rule to allow health checks.${RESET}"
gcloud compute firewall-rules create app-allow-health-check \
    --direction=INGRESS \
    --priority=1000 \
    --network=my-internal-app \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=lb-backend

# Step 4: Create instance template for subnet-a
echo "${GREEN}${BOLD}Creating instance template for subnet-a.${RESET}"
gcloud compute instance-templates create instance-template-1 \
    --machine-type e2-micro \
    --network my-internal-app \
    --subnet subnet-a \
    --tags lb-backend \
    --metadata startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh \
    --region=$REGION

# Step 5: Create instance template for subnet-b
echo "${BLUE}${BOLD}Creating instance template for subnet-b.${RESET}"
gcloud compute instance-templates create instance-template-2 \
    --machine-type e2-micro \
    --network my-internal-app \
    --subnet subnet-b \
    --tags lb-backend \
    --metadata startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh \
    --region=$REGION

# Step 6: Determine and set the secondary zone
echo "${YELLOW}${BOLD}Determining and setting the secondary zone.${RESET}"
change_zone_automatically

# Step 6: Create instance group 1
echo "${MAGENTA}${BOLD}Creating managed instance group 1.${RESET}"
gcloud beta compute instance-groups managed create instance-group-1 \
    --project=$DEVSHELL_PROJECT_ID \
    --base-instance-name=instance-group-1 \
    --size=1 \
    --template=instance-template-1 \
    --zone=$ZONE_1 \
    --list-managed-instances-results=PAGELESS \
    --no-force-update-on-repair

# Step 7: Set autoscaling for instance group 1
echo "${CYAN}${BOLD}Setting autoscaling for instance group 1.${RESET}"
gcloud beta compute instance-groups managed set-autoscaling instance-group-1 \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE_1 \
    --cool-down-period=45 \
    --max-num-replicas=5 \
    --min-num-replicas=1 \
    --mode=on \
    --target-cpu-utilization=0.8

# Step 8: Create instance group 2
echo "${RED}${BOLD}Creating managed instance group 2.${RESET}"
gcloud beta compute instance-groups managed create instance-group-2 \
    --project=$DEVSHELL_PROJECT_ID \
    --base-instance-name=instance-group-2 \
    --size=1 \
    --template=instance-template-2 \
    --zone=$ZONE_2 \
    --list-managed-instances-results=PAGELESS \
    --no-force-update-on-repair

# Step 9: Set autoscaling for instance group 2
echo "${GREEN}${BOLD}Setting autoscaling for instance group 2.${RESET}"
gcloud beta compute instance-groups managed set-autoscaling instance-group-2 \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE_2 \
    --cool-down-period=45 \
    --max-num-replicas=5 \
    --min-num-replicas=1 \
    --mode=on \
    --target-cpu-utilization=0.8

# Step 10: Create utility VM
echo "${BLUE}${BOLD}Creating utility VM.${RESET}"
gcloud compute instances create utility-vm \
    --zone $ZONE_1 \
    --machine-type e2-micro \
    --network my-internal-app \
    --subnet subnet-a \
    --private-network-ip 10.10.20.50

# Step 11: Create health check
echo "${YELLOW}${BOLD}Creating health check.${RESET}"
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -d '{
    "checkIntervalSec": 5,
    "description": "",
    "healthyThreshold": 2,
    "name": "my-ilb-health-check",
    "region": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'",
    "tcpHealthCheck": {
      "port": 80,
      "proxyHeader": "NONE"
    },
    "timeoutSec": 5,
    "type": "TCP",
    "unhealthyThreshold": 2
  }' \
  "https://compute.googleapis.com/compute/beta/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/healthChecks"

sleep 30 

# Step 12: Create backend service
echo "${MAGENTA}${BOLD}Creating backend service.${RESET}"
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -d '{
    "backends": [
      {
        "balancingMode": "CONNECTION",
        "failover": false,
        "group": "projects/'"$DEVSHELL_PROJECT_ID"'/zones/'"$ZONE_1"'/instanceGroups/instance-group-1"
      },
      {
        "balancingMode": "CONNECTION",
        "failover": false,
        "group": "projects/'"$DEVSHELL_PROJECT_ID"'/zones/'"$ZONE_2"'/instanceGroups/instance-group-2"
      }
    ],
    "connectionDraining": {
      "drainingTimeoutSec": 300
    },
    "description": "",
    "failoverPolicy": {},
    "healthChecks": [
      "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'/healthChecks/my-ilb-health-check"
    ],
    "loadBalancingScheme": "INTERNAL",
    "logConfig": {
      "enable": false
    },
    "name": "my-ilb",
    "network": "projects/'"$DEVSHELL_PROJECT_ID"'/global/networks/my-internal-app",
    "protocol": "TCP",
    "region": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'",
    "sessionAffinity": "NONE"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/backendServices"

sleep 20

 # Step 13: Create forwarding rule
echo "${RED}${BOLD}Creating forwarding rule.${RESET}"
 curl -X POST -H "Content-Type: application/json" \
 -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
 -d '{
   "IPAddress": "10.10.30.5",
   "IPProtocol": "TCP",
   "allowGlobalAccess": false,
   "backendService": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'/backendServices/my-ilb",
   "description": "",
   "ipVersion": "IPV4",
   "loadBalancingScheme": "INTERNAL",
   "name": "my-ilb-forwarding-rule",
   "networkTier": "PREMIUM",
   "ports": [
     "80"
   ],
   "region": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'",
   "subnetwork": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'/subnetworks/subnet-b"
 }' \
 "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/forwardingRules"
