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

module "ec2_configuration" {
  source = "./EC2module"
  vpc_id = aws_vpc.mpvpc.id
  subnet_ids = [aws_subnet.pubsub1.id, aws_subnet.pubsub2.id]
  subnet_id1 = aws_subnet.pubsub1.id
  subnet_id2 = aws_subnet.pubsub2.id
  target_group = aws_lb_target_group.target_group1.arn
  instance_profile = "${aws_iam_instance_profile.ec2-profile.name}"
  key_name = "${var.key_name}"
  target_group_arn = aws_lb_target_group.target_group1.arn
  user_data = "${file("template.sh")}"
}