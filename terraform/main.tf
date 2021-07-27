provider "aws" {
 region = "us-west-2"
}

data "aws_ami" "ubuntu_server" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current_region" {}

resource "aws_instance" "wizard_http_server" {
  ami                    = data.aws_ami.ubuntu_server.id
  instance_type          = "t2.micro"
  user_data              = file("init-script.sh")
  #cpu_core_count         = 1   # t2.micro не позволяет указывать про CPU
  #cpu_threads_per_core   = 1
  vpc_security_group_ids = [aws_security_group.wizard_http_server_sg.id]
  tags                   = {
    Name  = "Wizard's Ubuntu HTTP Server"
    Owner = "Andrey Pirozhkov"
  }
/*
  credit_specification {
    cpu_credits = "standard"
  }
*/
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "wizard_http_server_sg" {
  name        = "Wizard HTTP Server Security Group"
  description = "My Security Group"

  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Wizard HTTP Server Security Group"
    Owner = "Andrey Pirozhkov"
  }
}