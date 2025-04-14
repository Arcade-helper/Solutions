gcloud pubsub schemas create city-temp-schema \
        --type=avro \
        --definition='{                                             
            "type" : "record",                               
            "name" : "Avro",                                 
            "fields" : [                                     
            {                                                
                "name" : "city",                             
                "type" : "string"                            
            },                                               
            {                                                
                "name" : "temperature",                      
                "type" : "double"                            
            },                                               
            {                                                
                "name" : "pressure",                         
                "type" : "int"                               
            },                                               
            {                                                
                "name" : "time_position",                    
                "type" : "string"                            
            }                                                
        ]                                                    
    }'

gcloud pubsub topics create temp-topic \
        --message-encoding=JSON \
        --schema=temperature-schema

gcloud services enable eventarc.googleapis.com
gcloud services enable run.googleapis.com

gcloud services enable eventarc.googleapis.com
gcloud services enable run.googleapis.com

cat > index.js <<'EOF_END'
const functions = require('@google-cloud/functions-framework');

// Register a CloudEvent callback with the Functions Framework that will
// be executed when the Pub/Sub trigger topic receives a message.
functions.cloudEvent('helloPubSub', cloudEvent => {
  // The Pub/Sub message is passed as the CloudEvent's data payload.
  const base64name = cloudEvent.data.message.data;

  const name = base64name
    ? Buffer.from(base64name, 'base64').toString()
    : 'World';

  console.log(`Hello, ${name}!`);
});
EOF_END

cat > package.json <<'EOF_END'
{
  "name": "gcf_hello_world",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF_END

gcloud functions deploy gcf-pubsub \
  --gen2 \
  --runtime=nodejs22 \
  --region=$LOCATION \
  --source=. \
  --entry-point=helloPubSub \
  --trigger-topic gcf-topic \
  --quiet
  }
