# tf1

## WordPress Project Using Terraform
> Overview:
```
You are a DevOps engineer at XYZ Ltd. Your company is working mostly on WordPress  projects.  A lot of development hours are lost  to perform WordPress setup with all dependencies like PHP, MySQL, etc. The Company wants  to automate it with the help of a configuration management tool so that they can follow a standard installation procedure for WordPress and its components whenever a new requirement or client comes in. The below mentioned components should be included:
```

- PHP
- Nginx/Apache Web Server
- MySQL
- WordPress
 
### WordPress Deployment Using Terrform
#### AWS CLI profiles
- 
#### Terraform environment setup: MacBook Pro
1. use the 'brew' package manager to install the basic packages
- `brew install awscli`
- `brew install jq` (*helps when working with json data ; not strictly necessary though*)
- `brew install terraform`

2. AWS credentials: Terraform depends on the AWS CLI being installed and setup correctly
    1. create or use an IAM user for Terraform administration (don't use `root` account)
    2. create Access Key for this user
    3. run the `aws configure` command (this is the AWS CLI in action!)
        - promted for AWS Access Key
        - prompted for Secret 
        - **these items come from 'step2` above --create access key**
    4. this process will create a .aws folder in your workstation account
    5. the .aws folder contains 2 files :
        - config
        - credentials
    > the AWS CLI creates a "profile" with these two configuration files. A profile is a collection of settings and credentials that you can apply to an AWS CLI command. There will always be a "default" profile and additonal profiles can be setup in these files and used with the AWS CLI. To use a profile other than default, pass in the **--profile** option with the AWS CLI command.
    6. **ALTERNATE METHOD FOR CREDENTIALS SETUP:  ENVIRONMENT VARIABLES**
    ```
    export AWS_ACCESS_KEY_ID=access_key_string
    export AWS_SECRET_ACCESS_KEY=secret_access_key_string
    export AWS_DEFAULT_REGION=region_string
    ```
    7. CHECKOUT: run some simple commands to verify everything is working
        - `aws --version`
        - `aws s3 ls`

3. Terraform environemnt setup: Terraform Provider
    1. provider setup: example code
    ```
    terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}
    ```
    2. credentials











 ## Using "Let's Encrypt For SSL

- typically DNS will resolve an IP address to an "A" Record
- additionally, DNS can be pointed to :
    - CNAME
    - Azure LB
    - AWS LB
    - EC2 instance
    - Kubernetes ingress controller


### Let's Encrypt: Theory
- uses a public key and validates our www site via a set of challenges
- we  run a utillity on our www server to prove that we own the server
- we will need to place a certificate on our www server at a path where Let's Encrypt can find it
- by adding the file to the server, we are proving that we are the server admin
- we verify this by signing a **"NONCE"**
- Let's Encrypt will make a www request tp verify our certificate and the signature on the NONCE
- once the challenges are complete and verified by the CA, our utility that is identified by the key pair, is authorized to do certificate management on our domain

#### Let's Encrypt: High Level Implementation
1. create/configure a wwww service (can be port 80/unencrypted to start)
2. identify the IP address for the wwww service entry point (this is what needs to be encrypted)
3. associate a DNS record (using one of the established constructs above) to the IP address
4. domain validation:  Lets Ecrypt CertBot
5. we will run CertBot behind our domain to prove that we own it
6. CertBot will request the Certificate Challenge from Let's Encrypt
6. Let's Encrypt will ask us to place a file on the www server at a desginated path
7. Let's Encrypt  will issue a NONCE 
8. CertBot will generate the file and sign the NONCE
9. The CA will issue the Certificate to CertBot

##### Considerations for Running at Scale
- in a Production environment, you will likely have many www servers running
- the www servers will likely be running behind some type of Load Balancer
- generally you will not want each individual web server instance to be generating a certificate
- having a shared volume will allow one single CertBot instance to serve the files up to Let's Encrypt
- the idea is to have one CertBot instance to generate the Certificate and eithe copy or distribute (using a shared volume) to each of the web server instances



 ## LINKS
 ### eks-related
https://www.youtube.com/watch?v=QThadS3Soig&list=PLEKDo6dXMe16qjMz4duPNRyk8DWLwoDHe&index=10
https://medium.com/adobetech/designing-a-kubernetes-cluster-with-amazon-eks-from-scratch-4b4ee9d1b8f
https://medium.com/circuitpeople/aws-cli-with-jq-and-bash-9d54e2eabaf1
https://www.lewuathe.com/aws-cli-with-jq-make-things-easy.html
https://www.youtube.com/watch?v=Y4kNINPe9ho
eksworkshop.com

### go-related
https://firehydrant.io/blog/develop-a-go-app-with-docker-compose/
https://golangcode.com/basic-docker-setup/
https://levelup.gitconnected.com/deploying-simple-golang-webapp-to-kubernetes-25dc1736dcc4
https://martinheinz.dev/blog/5
https://blog.golang.org/using-go-modules
https://github.com/thockin/go-build-template
https://semaphoreci.com/community/tutorials/how-to-deploy-a-go-web-application-with-docker
https://medium.com/@fonseka.live/getting-started-with-go-modules-b3dac652066d

#### Docker-related
https://www.youtube.com/watch?v=XQNNAeyMAkk
https://youtu.be/8fi7uSYlOdc

#### Terraform and WordPress
##### Pablo:
- https://www.youtube.com/watch?v=8_QSES_P67s&lc=UgwU2iVElD3sEMzrz_14AaABAg.9PnO8XlpDcn9PpjGNrf_P_
- https://github.com/dyordsabuzo/pablosspot/blob/main/ep-08/nginx/server.conf


- https://dev.to/abhivaidya07/connecting-wordpress-to-amazon-rds-using-terraform-15bm
- https://github.com/abhivaidya07/wordpress_rds/blob/master/script.sh


- https://github.com/aleti-pavan/terraform-aws-wordpress
- https://www.youtube.com/watch?v=49aOUHkvlgg


- https://github.com/pixelicous/terraform-aws-wordpress

##### MEDIUM:
- https://medium.com/muhammet-arslan/create-a-secure-and-h-a-vpc-on-aws-with-terraform-71b9b0a61151
- https://medium.com/muhammet-arslan/install-a-secure-fault-tolerant-and-h-a-wordpress-on-aws-with-terraform-2-b29d9a720aee


#### Terraform SSL 
https://www.oss-group.co.nz/blog/automated-certificates-aws
https://github.com/nelg/terraform-aws-acmdemo


#### Terraform Variables
- https://upcloud.com/community/tutorials/terraform-variables/


https://www.padok.fr/en/blog/aws-eks-cluster-terraform

#### Terraform AWS EKS

https://learn.hashicorp.com/tutorials/terraform/eks


#### AWS CLI

https://www.youtube.com/watch?v=PWAnY-w1SGQ