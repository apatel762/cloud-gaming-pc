output "ssh_command" {
  # this is the command that you should run after everything is started up to
  # connect to the workstation over SSH
  value = format(
    "ssh %s@%s -i %s",
    var.ec2_user,
    aws_spot_instance_request.workstation_instance.public_ip,
    var.ssh_key_filename
  )
}

output "workstation_public_hostname" {
  value = aws_spot_instance_request.workstation_instance.public_dns
}