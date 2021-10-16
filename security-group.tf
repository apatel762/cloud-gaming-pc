resource "aws_security_group" "workstation_security_group" {
  name = "workstation-sg"
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
  security_group_id = aws_security_group.workstation_security_group.id

  type        = "ingress"
  description = "Allow RDP from my IP"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = ["${data.external.my_ip_from_ipify.result.ip}/32"]
}

resource "aws_security_group_rule" "ssh_ingress" {
  security_group_id = aws_security_group.workstation_security_group.id

  type        = "ingress"
  description = "Allow SSH connections from my IP"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${data.external.my_ip_from_ipify.result.ip}/32"]
}

# Allow all outbound connections
resource "aws_security_group_rule" "default" {
  security_group_id = aws_security_group.workstation_security_group.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}