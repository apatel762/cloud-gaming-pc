# Meta info

variable "aws_profile" {
  description = "The profile to use for provisioning infra"
  type        = string
  default     = "default"
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    Project     = "cloud-gaming-pc",
    Environment = "dev"
  }
}

# EC2 info

variable "instance_type" {
  description = "The EC2 instance type. By default, we use one of these: https://aws.amazon.com/ec2/instance-types/g4/"
  type        = string
  default     = "g4dn.xlarge"
}

variable "root_volume_size" {
  description = "The size in GB of the root volume on the instance"
  type        = number
  default     = 120
}