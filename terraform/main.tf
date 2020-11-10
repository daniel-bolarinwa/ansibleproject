provider "aws" {
    region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "tester-s3-bucket"
    key    = "ansibleproject/terraform/.terraform/terraform.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_vpc" "mpvpc" {
    cidr_block = "172.31.0.0/16"
    tags = {
        Name = "MiniProjectVPC"
    }
}

resource "aws_subnet" "pubsub1" {
  vpc_id            = aws_vpc.mpvpc.id
  cidr_block        = "172.31.16.0/20"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "websubnet"
  }
}

resource "aws_subnet" "pubsub2" {
  vpc_id            = aws_vpc.mpvpc.id
  cidr_block        = "172.31.32.0/20"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "dbsubnet"
  }
}

resource "aws_instance" "webserver" {
  ami                    = "ami-0a669382ea0feb73a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.pubsub1.id
  user_data              = "${file("template.sh")}"
  depends_on             = [aws_internet_gateway.internet_gw]
  vpc_security_group_ids = [aws_security_group.instances_sgrules.id]
  key_name               = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-profile.name}"
  tags = {
    Name = "webserver"
  }
}

resource "aws_instance" "dbserver" {
  ami                    = "ami-0a669382ea0feb73a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.pubsub2.id
  depends_on             = [aws_internet_gateway.internet_gw]
  vpc_security_group_ids = [aws_security_group.instances_sgrules.id]
  key_name               = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-profile.name}"
  tags = {
    Name = "dbserver"
  }
}

resource "aws_eip" "webserver_eip" {
  instance = aws_instance.webserver.id
}

resource "aws_eip" "dbinstance_eip" {
  instance = aws_instance.dbserver.id
}