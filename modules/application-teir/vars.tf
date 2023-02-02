variable "vpc_id" {
  description = "The VPC ID in AWS"
}

variable "name" {
  description = "Name to be used for the Tags"
}

variable "route_table_id" {
  description = "The route table ID in AWS"
}

variable "cidr_block" {
  description = "The CIDR block of the tier subnet"
}

variable "user_data" {
  description = "user data to start the instance"
}

variable "ami_id" {
  description = "the id of the ami for the instance"
}


variable "map_public_ip_on_launch" {
  default = false
}

variable "ingress" {
  description = "Type of list"
}


