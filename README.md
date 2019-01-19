# ops_mid_project
pre-requisites:
aws user with proper permissions: create ec2 t3.medium instances, create vpc, create iam role
terraform installed

Clone this git:
```
  git clone https://github.com/AviadP/ops_mid_project.git
```

then:
```
  cd ops_mid_project/terraform
  terraform init
  terraform apply --auto-approve  
```

output will include:
  consul node ip address(using port 8500)
  elk stack node ip address(using port 5601)
  monitoring node ip address (using port 3000)
