provider "aws" {
    region = "ap-south-1"
}

data "aws_ami" "ubuntu_ami" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240701.1"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t2.micro"

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y golang git
                git clone https://github.com/kunal-gohrani/golang-cpu-intensive-server /home/ubuntu/app
                cd /home/ubuntu/app/golang-server
                make build
                ./golang-webserver &
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
