provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "simple" {
  instance_type = "t2.micro"
  ami = "ami-a8d2d7ce"
}
