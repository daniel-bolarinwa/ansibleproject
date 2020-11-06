resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.mpvpc.id
  tags = {
    Name = "i-gw"
  }
}

resource "aws_route_table" "pubRT" {
  vpc_id = aws_vpc.mpvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "route-table"
  }
}

resource "aws_route_table_association" "route_tabele_asc1" {
  subnet_id      = aws_subnet.pubsub1.id
  route_table_id = aws_route_table.pubRT.id
}

resource "aws_route_table_association" "route_table_asc2" {
  subnet_id      = aws_subnet.pubsub2.id
  route_table_id = aws_route_table.pubRT.id
}

resource "aws_lb_target_group" "target_group1" {
  name     = "tg1"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.mpvpc.id
}

resource "aws_network_acl" "network-access-control-list" {
  vpc_id = aws_vpc.mpvpc.id
  tags = {
    Name = "sub-nacls"
  }
  ingress {
    rule_no    = 100
    from_port  = 80
    to_port    = 80
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 200
    from_port  = 22
    to_port    = 22
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }
  egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 300
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_lb" "nlb" {
  name               = "MyNLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.pubsub1.id, aws_subnet.pubsub2.id]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  count             = 2
  port = var.ports[count.index]
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group1.arn
  }
}

resource "aws_lb_target_group_attachment" "nlb_instance_target1" {
  target_group_arn = aws_lb_target_group.target_group1.arn
  target_id        = aws_instance.webserver.id  
  port             = 80
}

resource "aws_lb_target_group_attachment" "nlb_instance_target2" {
  target_group_arn = aws_lb_target_group.target_group1.arn
  target_id        = aws_instance.dbserver.id
  port             = 80
}

resource "aws_security_group" "instances_sgrules" {
  name   = "sg2"
  vpc_id = aws_vpc.mpvpc.id

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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}