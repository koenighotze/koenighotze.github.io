provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "stage1" {
  instance_type = "t2.micro"
  ami = "ami-a8d2d7ce"

  tags {
    Name = "stage1"
  }
}