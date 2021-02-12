variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR of VPC"
}

variable "public_subnet_cidr" {
  type = list(string)
  description = "Subnet CIDR"
}

variable "public_subnet_names" {
  type = list(string)
  description = "Subnet names"
}

variable "availability_zone" {
  type = list(string)
  description = "Availability zones"
}


variable "ami" {
  default = "ami-047a51fa27710816e"
}
variable "instance_type" {
  description = "instance type of EC2"
}

