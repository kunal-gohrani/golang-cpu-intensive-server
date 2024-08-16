provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240701.1"]
  }
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.ubuntu_ami.id
  instance_type   = "t2.micro"
  key_name        = "terraform"
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  tags = {
    Name = "GolangWebServer"
  }

  connection {
    user        = "ubuntu"
    private_key = file("~/Downloads/terraform-3.pem")
    host        = self.public_dns
  } 

  provisioner "remote-exec" {
    when       = create
    on_failure = fail
    script = "../tools/application_initializer.sh"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic and all outbound traffic"
  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}