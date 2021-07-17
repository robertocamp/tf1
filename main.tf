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


resource "aws_eip" "nat" {
  count = 3
  vpc = true 
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "dev-vpc"
  cidr = "10.0.0.0/20"
  azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets = ["10.0.0.0/23", "10.0.2.0/23", "10.0.4.0/23"]
  private_subnets = ["10.0.10.0/23", "10.0.12.0/23", "10.0.14.0/23"]
  enable_nat_gateway = true
  reuse_nat_ips = true
  external_nat_ip_ids = "${aws_eip.nat.*.id}"

  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
