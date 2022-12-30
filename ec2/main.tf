# TODO create a bastion keypair inside terraform?...
resource "aws_key_pair" "bastion_rsa" {
  key_name   = "bastion_rsa"
  public_key = var.public_key
}

resource "aws_instance" "dominion_bastion_host" {
  ami                         = "ami-0ceecbb0f30a902a6"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true
  subnet_id                   = var.subnets[0].id
  monitoring                  = true
  key_name                    = "bastion_rsa"
  depends_on                  = [var.internet_gateway]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("/Users/curtisblanchette/.ssh/bastion_rsa.pem")
    timeout     = "4m"
  }

  tags = {
    Name        = "${var.name}-bastion-host-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_network_interface" "dominion_bastion_eni" {
  subnet_id       = var.subnets[0].id
  private_ips     = ["10.0.0.54"]
  security_groups = [var.bastion_sg_id]

  attachment {
    instance     = aws_instance.dominion_bastion_host.id
    device_index = 1
  }

  tags = {
    Name        = "${var.name}-bastion-eni-${var.environment}"
    Environment = var.environment
  }
}


