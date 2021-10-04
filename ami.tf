# Ensure that we're using the latest Ubuntu server AMI by Canonical

data "aws_ami" "ubuntu_ami" {
  filter {
    name   = "name"
    values = ["ubuntu*-21.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }

  most_recent = true
  owners      = ["099720109477"] # Canonical
}