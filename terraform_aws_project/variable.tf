variable "ami" {
  type    = string
  default = "ami-01b6d88af12965bb6" # Amazon Linux 2 AMI
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_cidr" {
  type = string
}

variable "volume_size" {
  type    = number
  default = 8
}

variable "public_key_path" {
  type = string
}

variable "rsa_key_name" {
  type = string
}

variable "volume_type" {
  type    = string
  default = "gp2"
}

variable "ec2_name" {
  type = list(string)
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

