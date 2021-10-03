# Ensure that we're using the latest Ubuntu server AMI by Canonical

data "aws_ami" "ubuntu_ami" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-groovy-20.10-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  most_recent = true
  owners      = ["099720109477"] # Canonical
}