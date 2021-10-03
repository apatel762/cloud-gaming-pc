output "instance_id" {
  value = aws_spot_instance_request.windows_instance.id
}

output "instance_ip" {
  value = aws_spot_instance_request.windows_instance.public_ip
}