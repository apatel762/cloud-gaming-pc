output "instance_ip" {
  value = aws_spot_instance_request.workstation_instance.public_ip
}