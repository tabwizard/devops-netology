provider "aws" {
 region = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_key_pair" "tabwizard" {
  key_name   = "aws"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRnZP+ce+ZHHY3jFEoAL1NV+YcslUSzTarbbtDHWXgWuvEIhX9MVvY9T1srydMdalK2BqIqtVwlgoGz/MVXDFOl3ejiGDUOtU1qJXDPxM+zlzbgN0lK/VJmWnUXbmlIwAsYiw7wYcef+LfnxNgqjVWIbtFg6q2UG6iS7SmW+Y+p9JnnMQvTSrK2wac1YOiCXcUU3NXUd2FeDwsNqYWWQ65sB2N+X4/bL8GXeWMyjighyKIbu3d7csdDwp00YNrF/w5JNhOgDUzGheL+Rsk7t9VqYER050V9mWlSGMPizFh7XTb6/gOzpNhhLuyxlLYxXTkHknzj0iG19cjKKDqjb+NK/p9mzisAmNXHhrIH33alGNeNYKBByLXX6QF7v4+IHL2t8kC9CM9HNB5jOdEkWjXNhyKnlBmZuAUXp6y8I89YAIUhFdp12++yjNa9zjpqzs2/8Qb+J2My3WwWx6Yh84Q2kaKyGO2g4D/qOwJLgSJNjyvBJNtRg+xG0S4DQYT85s= wizard@wizard-pc"
}

data "aws_ami" "ubuntu_server" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "wizard_control_plane" {
  count                  = 1
  ami                    = data.aws_ami.ubuntu_server.id
  instance_type          = "t3.small"
  key_name               = aws_key_pair.tabwizard.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 100
  }
  tags = {
    Name = "ControlPlane"
  }
}

resource "aws_instance" "wizard_node" {
  count                  = 4
  ami                    = data.aws_ami.ubuntu_server.id
  instance_type          = "t3.small"
  key_name               = aws_key_pair.tabwizard.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 100
  }
  tags = {
    Name = "Node${count.index + 1}"
  }
}
