provider "aws" {
 region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "wizards-bucket-tfstate"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  web_instance_type = {
    stage = "t2.micro"
    prod = "t3.large"
  }
  web_instance_count = {
    stage = ["1"]
    prod = ["1", "2"]
  }
}


data "aws_ami" "ubuntu_server" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = "wizard's-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
}

module "ec2-instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"

  name                        = "wizard_aws_modules_ec2_instance"
  instance_count              = length(local.web_instance_count[terraform.workspace])
  ami                         = data.aws_ami.ubuntu_server.id
  instance_type               = local.web_instance_type[terraform.workspace]
  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  tags = {
    Name = "Wizard's Server"
  }
}

module "ec2-instance2" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"
  for_each = toset(local.web_instance_count[terraform.workspace])
    name                        = "wizard_aws_modules_ec2_instance_for_each"
    instance_count              = length(local.web_instance_count[terraform.workspace])
    ami                         = data.aws_ami.ubuntu_server.id
    instance_type               = local.web_instance_type[terraform.workspace]
    vpc_security_group_ids      = [module.vpc.default_security_group_id]
    subnet_id                   = module.vpc.public_subnets[0]
    tags = {
        Name = "Wizard's Server  ${each.value}"
    }
}
