resource "aws_key_pair" "my_key" {
  key_name   = var.rsa_key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "first_vm" {
  ami                         = var.ami
  instance_type               = var.instance_type
  force_destroy               = true
  subnet_id                   = aws_subnet.my_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_sg.id]
  key_name                    = aws_key_pair.my_key.key_name
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  for_each = toset(var.ec2_name)
  tags = {
    Name = "dev-${substr(var.region, 3, -1)}-${each.value}"
  }
  depends_on = [aws_vpc.my_vpc, aws_internet_gateway.my_igw]

}