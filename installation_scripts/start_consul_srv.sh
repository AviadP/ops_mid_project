#!/bin/bash
docker run --name consul -d --net=host -v /consul/data:/consul/data \
-e CONSUL_LOCAL_CONFIG='{
"datacenter":"us-east-1",
"server":true,
"enable_debug":true
}' consul:1.2.1 agent -server -bind 127.0.0.1 -bootstrap-expect=1 

echo "Setup complete."