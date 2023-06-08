# Define the provider
provider "aws" {
  region = "us-east-1"
}




# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}


# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}





# Local variables
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  prefix_main  = "${local.prefix}-${var.env}"
}
module "globalvars" {
  source = "/home/ec2-user/environment/terraform/modules/globalvars"
}




# Create VPC 
data "aws_vpc" "default" {
  default = true
}


# Create webserver 1
resource "aws_instance" "ws1" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = lookup(var.type, var.env)
  key_name      = aws_key_pair.web_key.key_name
  #subnet_id                   = data.terraform_remote_state.network_dev.outputs.private_subnet_dev[0]
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  #associate_public_ip_address = false




  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.prefix_main}_ws1"
    }
  )
}





# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = local.prefix_main
  public_key = file("${local.prefix_main}.pub")
}


# Security Group For ws1
resource "aws_security_group" "sg_web" {
  name        = "webserver traffic"
  description = "webserver traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from everywhere"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups  = [aws_security_group.sg_web.id]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description = "HTTP from everywhere"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups  = [aws_security_group.sg_web.id]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description = "HTTP from everywhere"
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups  = [aws_security_group.sg_web.id]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups  = [aws_security_group.sg_web.id]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.prefix_main}_sg_web"
    }
  )
}




resource "aws_ecr_repository" "webapp" {
  name                 = "webapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}



resource "aws_ecr_repository" "db_mysql" {
  name                 = "db_mysql"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}