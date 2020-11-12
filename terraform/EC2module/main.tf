resource "aws_lb" "nlb" {
  name               = "MyNLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  count             = 2
  port = var.ports[count.index]
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = var.target_group
  }
}

resource "aws_lb_target_group_attachment" "nlb_instance_target1" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.webserver.id  
  port             = 80
}

resource "aws_lb_target_group_attachment" "nlb_instance_target2" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.dbserver.id
  port             = 80
}

resource "aws_security_group" "instances_sgrules" {
  name   = "sg2"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "MongoDB access"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "API access"
    from_port   = 3000
    to_port     = 3000
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

resource "aws_instance" "webserver" {
  ami                    = "ami-0a669382ea0feb73a"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id1
  user_data              = "${file("template.sh")}"
  #depends_on             = [aws_internet_gateway.internet_gw]
  vpc_security_group_ids = [aws_security_group.instances_sgrules.id]
  key_name               = var.key_name
  iam_instance_profile   = var.instance_profile
  tags = {
    Name = "webserver"
  }
}

resource "aws_instance" "dbserver" {
  ami                    = "ami-0a669382ea0feb73a"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id2
  #depends_on             = [aws_internet_gateway.internet_gw]
  vpc_security_group_ids = [aws_security_group.instances_sgrules.id]
  key_name               = var.key_name
  iam_instance_profile   = var.instance_profile
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