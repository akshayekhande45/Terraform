terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      version = "~>3.1"
    }
  }
}

provider "aws" {
  region     = var.my_region  
  access_key = var.access_key 
  secret_key = var.secret_key 
}

resource "aws_instance" "myec2" {

  ami           = var.my_ami    
  instance_type = var.instance_type  
  count         = 2
  tags = {
    Name = "myinstance= ${count.index + 1}"
  }
  key_name = "realme"
  #user_data = file("${path.module}/user_data.sh")
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
    host = aws_instance.myec2[1].public_ip

  }
  provisioner "remote-exec" {
    inline = [ 
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo systemctl start nginx"
     ]
    
  }
}
resource "aws_security_group" "mysg" {
  name   = "my-sg1"
  vpc_id = var.vpc_id 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "realme"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "realme.pem"
}


