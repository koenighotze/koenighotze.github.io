provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "stage1" {
  instance_type = "t2.micro"
  ami = "ami-a8d2d7ce"

  key_name = "aws-30-days"

  vpc_security_group_ids = ["${aws_security_group.sec-group.id}"]

  provisioner "local-exec" {
    command = "echo ${aws_instance.stage1.public_ip} > ip_address.txt"
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "install.sh"

    connection {
      timeout = "5m"
      user = "ubuntu"
    }
  }

  provisioner "remote-exec" {
    script = "install.sh"

    connection {
      timeout = "5m"
      user = "ubuntu"
    }
  }

  tags {
    Name = "stage1"
    Owner = "dschmitz"
  }
}

resource "aws_security_group" "sec-group" {
  name = "ssh and http"

  # inbound
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Owner = "dschmitz"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.stage1.id}"
}

output "ip" {
  value  = "${aws_eip.ip.public_ip}"
}
