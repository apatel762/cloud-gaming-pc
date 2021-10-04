# Meta info

variable "aws_profile" {
  description = "The profile to use for provisioning infra"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "The region to provision the infra in"
  type        = string
  default     = "eu-west-2"
}

# EC2 info

variable "instance_type" {
  description = "The EC2 instance type. By default, we use one of these: https://aws.amazon.com/ec2/instance-types/t4/"
  type        = string
  default     = "t4g.2xlarge"
}

variable "root_volume_size" {
  description = "The size in GB of the root volume on the instance"
  type        = number
  default     = 120
}

# EC2 user data

variable "ec2_user" {
  description = "The username of the user that you will use you log in to the EC2 instance"
  type        = string
  default     = "amigo"
}

variable "give_sudo_to_ec2_user" {
  description = "Controls whether or not the custom EC2 user will be added to the sudoers list"
  type        = bool
  default     = false
}