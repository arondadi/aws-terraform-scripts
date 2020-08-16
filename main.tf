provider "aws" {
  profile = "default"
  region = "eu-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] #Canonical, ubuntu publisher
  
  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

# Remove if default vpc works
/*
resource "aws_vpc" "main" {
  cidr_block       = "172.31.0.0/16" # From AWS console
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}
*/

variable "vpc_id" {
  default = "vpc-d433cdad"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
  cidr_block       = "172.31.0.0/16" # From AWS console
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}



resource "aws_launch_configuration" "terraform-test-launch-config" {
  name          = "terraform-test-launch-config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"


  key_name        = var.key_name
  security_groups = [aws_security_group.allow_tls.name]
  # security_groups = [var.sec_group] #[aws_security_group.allow_tls.name]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "auto-scaling-group" {
  name               = "auto-scaling-group"
  availability_zones = ["eu-west-1b", "eu-west-1c"]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 1

  launch_configuration = aws_launch_configuration.terraform-test-launch-config.name

  lifecycle {
    create_before_destroy = true
  }
}
