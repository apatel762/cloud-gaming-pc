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

variable "ssh_key_filename" {
  description = "The name of the private key file (must be '.pem') that will be used for SSH"
  type        = string
  default     = "workstation.pem"
}

# EC2 user data

variable "ec2_user" {
  description = "The username of the user that you will use you log in to the EC2 instance"
  type        = string
  default     = "amigo"
}

# Resource naming

variable "naming_prefix" {
  description = "3 character prefix for all resources created"
  type        = string
  default     = "arj"
}

variable "naming_project" {
  description = "4-10 character project name included in the name of all resources"
  type        = string
  default     = "cloudws"
}

variable "naming_env" {
  description = "1 letter that represents the environment"
  type        = string
  default     = "p"
}