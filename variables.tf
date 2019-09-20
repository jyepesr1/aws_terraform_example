variable "region" {
  description = "Region in which the infrastructure will be deployed"
  default = "us-east-1"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default = "192.168.0.0/16"
}
variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type = "list"
  default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
}
# Getting availavility zones from data source 
data "aws_availability_zones" "avail_zones" {
  state = "available"
}
variable "public_key_path" {
  description = "Public key path"
  default = "~/.ssh/id_rsa.pub"
}
variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default = "ami-0b69ea66ff7391e80" # ubuntu AMI (free tier)
}
variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}
variable "environment_tag" {
  description = "Environment tag"
  default = "Testing"
}

# Get public ip from I'm running terraform
data "http" "myip" {
  url = "http://ifconfig.co"
}