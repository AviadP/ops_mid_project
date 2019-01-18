#1/bin/bash

cd terraform
./terraform init
./terraform appl --auto-approve
./terraform output private_key > ~/.ssh/midproj.pem
chmod 600 ~/.ssh/midproj.pem
