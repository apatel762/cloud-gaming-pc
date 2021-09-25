terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  required_version = ">= 1.0.7"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

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
# Create an auto-generated password and put it in the SSM parameter
# store

resource "random_password" "password" {
  length  = 32
  special = true
}

resource "aws_ssm_parameter" "password" {
  name  = "cloud-gaming-administrator-password"
  type  = "SecureString"
  value = random_password.password.result
}

# ---------------------------------------------------------------------
# Create custom security group for instance

resource "aws_security_group" "default" {
  name = "cloud-gaming-sg"
}

# Get current IPv4
# https://tom-henderson.github.io/2021/04/20/terraform-current-ip.html

data "external" "my_ip_from_ipify" {
  program = [
    "bash", "-c",
    "curl -s 'https://api.ipify.org?format=json'"
  ]
}

resource "aws_security_group_rule" "rdp_ingress" {
  security_group_id = aws_security_group.default.id

  type        = "ingress"
  description = "Allow RDP from my IP"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = ["${data.external.my_ip_from_ipify.result.ip}/32"]
}

resource "aws_security_group_rule" "vnc_ingress" {
  security_group_id = aws_security_group.default.id

  type        = "ingress"
  description = "Allow VNC connections from my IP"
  from_port   = 5900
  to_port     = 5900
  protocol    = "tcp"
  cidr_blocks = ["${data.external.my_ip_from_ipify.result.ip}/32"]
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
# IAM role & policy for the instance

resource "aws_iam_policy" "policy_for_getting_password_from_ssm" {
  name = "password-get-parameter-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:GetParameter"
        Effect   = "Allow"
        Resource = aws_ssm_parameter.password.arn
      },
    ]
  })
}

resource "aws_iam_role" "role_for_windows_instance" {
  name = "role_for_windows_instance"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attaching_policy_for_getting_password_from_ssm" {
  role       = aws_iam_role.role_for_windows_instance.name
  policy_arn = aws_iam_policy.policy_for_getting_password_from_ssm.arn
}

resource "aws_iam_instance_profile" "windows_instance_profile" {
  name = "cloud-gaming-instance-profile"
  role = aws_iam_role.role_for_windows_instance.name
}

# ---------------------------------------------------------------------
# A persistent spot request for the Windows instance
#
# Using a spot request for this because it's cheaper than using an
# on-demand instance. The costs will otherwise add up quite quickly
# over time.
#

resource "aws_spot_instance_request" "windows_instance" {
  instance_type        = var.instance_type
  ami                  = data.aws_ami.windows_ami.image_id
  security_groups      = [aws_security_group.default.name]
  iam_instance_profile = aws_iam_instance_profile.windows_instance_profile.id

  # the script which gets the password from SSM and sets up auto login
  # to use the generated password
  user_data = templatefile("${path.module}/templates/userdata.tpl", {
    password_ssm_parameter = aws_ssm_parameter.password.name
  })

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