resource "random_id" "vpc_id" {
  byte_length = 2
  keepers = {
    vpc_cidr = var.vpc_cidr
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vpc-${substr(var.region, 3, -1)}-${random_id.vpc_id.hex}"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, 1)
  tags = {
    Name = "subnet-${aws_vpc.my_vpc.tags["Name"]}"
  }
}

resource "aws_security_group" "allow_ssh_sg" {
  name   = "allow_ssh"
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "AllowSSH_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyIGW"
  }
}

resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "MyRouteTable-${aws_subnet.my_subnet.id}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}
