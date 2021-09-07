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

resource "aws_instance" "wizard_aws_instance" {
  count                  = length(local.web_instance_count[terraform.workspace])
  ami                    = data.aws_ami.ubuntu_server.id
  instance_type          = local.web_instance_type[terraform.workspace]
 
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "Server Number ${count.index + 1}"
  }
}

resource "aws_instance" "wizard_aws_instance_for" {
  for_each = toset(local.web_instance_count[terraform.workspace])
    ami           = data.aws_ami.ubuntu_server.id
    instance_type = local.web_instance_type[terraform.workspace]
    tags = {
      Name = "Server FOR Number ${each.value}"
    }
}
