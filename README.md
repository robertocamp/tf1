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
 
### WordPress Deployment Using Terraform
#### AWS CLI profiles

> A "profile" in the AWS CLI configuration is a collection of credentials and parameters that govern now the AWS CLI command(s) are delivered to AWS. The "default" profile gets configured automaticially  and additoinal profiles can be added to the `config` and `credentials` files

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
    2. credentials: supported methods
        - static:  **hard coding credentials is not recommended**
        - environment variables
        - shared credentials/configuration file
        - CodeBuild, ECS, EKS roles
        - EC2 Instnace Metadata Service (MDS and IMDSv2)
        - CODE EXAMPLE: static

                
                provider "aws" {
                region     = "us-west-2"
                access_key = "my-access-key"
                secret_key = "my-secret-key"
                }
        - CODE EXMAPLE: environment
            - set environment variables in shell


                    $ export AWS_ACCESS_KEY_ID="anaccesskey"
                    $ export AWS_SECRET_ACCESS_KEY="asecretkey"
                    $ export AWS_DEFAULT_REGION="us-west-2"

            - configure TF provider in code:

                `provider "aws" {}`

            - `terraform plan`

        - CODE EXAMPLE: shared credentials file
            - default location of AWS cred file is `$HOME/.aws/credentials`
            - Terraform provider code for AWS:

                    provider "aws" {
                    region                  = "us-west-2"
                    shared_credentials_file = "/Users/tf_user/.aws/creds"
                    profile                 = "customprofile"
                    }

        3. checkout:  4-step Terraform work flow to show that environment is setup correctly:
            -  `terraform init`
            -  `terraform plan`
            -  `terraform apply`
            -   `terraform show`
            -  `terraform destroy`
                - detailed checkout steps
                    1. `touch main.tf`
                    2. boiler plate code to deploy a single ec2:

                        ```
                        terraform {
                            required_providers {
                                aws = {
                                source  = "hashicorp/aws"
                                version = "~> 3.27"
                                }
                            }

                            required_version = ">= 0.14.9"
                            }

                            provider "aws" {
                            profile = "default"
                            region  = "us-east-2"
                            }

                            resource "aws_instance" "app_server" {
                            ami           = "ami-00399ec92321828f5"
                            instance_type = "t2.micro"

                            tags = {
                                Name = "ExampleAppServerInstance"
                            }
                        }
                        ```
                    3. peform terraform work flow




 #### AWS VPC
 ##### VPC overview
 > Amazon Virtual Private Cloud (Amazon VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define.  You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways.

 > AWS VPC constructs:
- subnets
- route tables
- Internet Gateways
- Egress-Only Internet Gateways
- DHCP Option Sets
- DNS
- Elastic IP address
- VPC Endpoints
- NAT
- VPC Peering

> For highly-available networking, you need to have at least 2 availability zone to put your resources in

> When you create a VPC, you must specify a range of IPv4 addresses for the VPC in the form of a Classless Inter-Domain Routing (CIDR) block; for example, 10.0.0.0/16

>The allowed block size is between a /16 netmask (65,536 IP addresses) and /28 netmask (16 IP addresses).

##### subnet networking in VPC
> The CIDR block of a subnet can be the same as the CIDR block for the VPC (for a single subnet in the VPC), or a subset of the CIDR block for the VPC (for multiple subnets).

- The allowed block size is between a /28 netmask and /16 netmask.
- If you create more than one subnet in a VPC, the CIDR blocks of the subnets cannot overlap.

> Example network design:
- VPC with CIDR block, 10.0.0.0/20
- 10.0.0.0/23 — public subnet 1a — 512 IP Address
- 10.0.2.0/23 — public subnet 1b — 512 IP Address
- 10.0.4.0/23 — public subnet 1c — 512 IP Address
- 10.0.10.0/23 — private subnet 1a — 512 IP Address
- 10.0.12.0/23 — private subnet 1b — 512 IP Address
- 10.0.14.0/23 — private subnet 1c — 512 IP Address

> AWS subnet restrictions with VPC networking: you CANNOT use these IPs (exmpmle network 10.0.0.0/23)

-  network address (10.0.0.0)
-  network gateway (10.0.0.1)
-  The IP address of the DNS server is always the base of the VPC network range plus two; however AWS also reserves the base of each subnet "plus two" (10.0.0.2)
-  10.0.0.3: Reserved by AWS for future use.
-  *subnet broadcast address* 10.0.1.255: AWS does not support broadcast in a VPC, therefore AWS reserves this address.



##### VPC routetables: A *route table* contains a set of rules, called routes, that are used to determine where network traffic is directed.

- Each subnet in your VPC must be associated with a route table; the table controls the routing for the subnet
- A subnet can only be associated with one route table at a time
- you can associate multiple subnets with the same route table

##### Internet Gateway

> An internet gateway is a horizontally scaled, redundant, and highly available VPC component that allows communication between instances in your VPC and the internet.

- IG provides a target in your VPC route tables for internet-routable traffic 
- performs network address translation (NAT) for instances that have been assigned public IPv4 addresses

##### NAT gateway
>  network address translation (NAT) gateway enables instances in a private subnet to connect to the internet or other AWS services

- Internet traffic is prevented from initiating connections with instnaces behind a NAT gateway
- AWS NAT gateway hourly usage and data processing rates apply!
- NAT gateways are not supported for IPv6 traffic—use an outbound-only (egress-only) internet gateway instead
- Nat GW should be located on a *public subnet*
- You must associate an elastic IP for NAT GW.

> NOTE: If you have resources in multiple Availability Zones and they share one NAT gateway, in the event that the NAT gateway’s Availability Zone is down, resources in the other Availability Zones lose internet access. To create an Availability Zone-independent architecture, create a NAT gateway in each Availability Zone and configure your routing to ensure that resources use the NAT gateway in the same Availability Zone.


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




