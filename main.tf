terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60.0"
    }
  }

  required_version = ">= 1.0.7"
}

provider "aws" {
  profile = var.aws_profile

  default_tags {
    tags = var.resource_tags
  }
}

# ---------------------------------------------------------------------
# Ensure that we're using the latest Windows server AMI

data "aws_ami" "windows_ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

# ---------------------------------------------------------------------
# Create custom security group for instance

resource "aws_security_group" "default" {
  name = "cloud-gaming-sg"
}

resource "aws_security_group_rule" "rdp_ingress" {
  security_group_id = aws_security_group.default.id

  type        = "ingress"
  description = "Allow RDP from my IP"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] #todo: make this my ip only
}

resource "aws_security_group_rule" "vnc_ingress" {
  security_group_id = aws_security_group.default.id

  type        = "ingress"
  description = "Allow VNC connections from my IP"
  from_port   = 5900
  to_port     = 5900
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] #todo: make this my ip only
}

# Allow all outbound connections
resource "aws_security_group_rule" "default" {
  security_group_id = aws_security_group.default.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------
# A persistent spot request for the Windows instance
#
# Using a spot request for this because it's cheaper than using an
# on-demand instance. The costs add up quite quickly over time
# otherwise.
#

resource "aws_spot_instance_request" "windows_instance" {
  instance_type   = var.instance_type
  ami             = data.aws_ami.windows_ami.image_id
  security_groups = [aws_security_group.default.name]

  # ensure that our spot request is one-time so it doesn't spin up
  # another instance if we lose it, and then the price goes down while
  # we aren't using it
  spot_type = "one-time"

  # ensure that terraform waits for the spot request to be fulfilled
  # when provisioning the infra; since we're bidding at on-demand price
  # we _shouldn't_ ever get timeouts here
  wait_for_fulfillment = true

  # allow the root volume size to be overridden by variables
  # and ensure that our instance is EBS Optimized
  root_block_device {
    volume_size = var.root_volume_size
  }
  ebs_optimized = true
}