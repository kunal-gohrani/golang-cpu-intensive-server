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
  user_data       = <<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install -y git make
                sudo apt install -y golang-go
                git clone https://github.com/kunal-gohrani/golang-cpu-intensive-server /home/ubuntu/app
                sudo chown -R ubuntu /home/ubuntu/app
                cd /home/ubuntu/app/golang-server
                make run
                EOF
  tags = {
    Name = "GolangWebServer"
  }
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "instance_dns" {
  value = aws_instance.web.public_dns
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
