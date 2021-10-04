# Used a mixture of the below references to get this set up:
#
#   https://ifritltd.com/2017/12/06/provisioning-ec2-key-pairs-with-terraform/
#   https://stackoverflow.com/questions/49743220/how-do-i-create-an-ssh-key-in-terraform
#   https://www.phillipsj.net/posts/generating-ssh-keys-with-terraform/
#
# Using the `local_file` resource can create noise in the terraform apply
# command if multiple people are deploying the same thing, as it must create
# the local file for each of you (and will report the file as missing for
# each new person who deploys the infra in this repo)
#
# This isn't a problem for my use case though, as I'm the only person using
# this repo.

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "workstation_key_pair" {
  key_name   = "workstation-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = var.ssh_key_filename
  file_permission = "0400"
}