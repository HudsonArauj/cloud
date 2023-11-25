resource "aws_security_group" "project_sg_lb" {
  name   = "${var.application_name}_security_group_lb"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "this" {
  name               = "${var.application_name}-lb"
  internal           = false
  load_balancer_type = "application"  // tipo de balanceamento
  security_groups    = [aws_security_group.project_sg_lb.id] //informando o security group
  subnets = var.public_subnet_ids  //informando a subrede
}

//health_check  apenas para instancias saudaveis
resource "aws_lb_target_group" "this" {
  name     = "${var.application_name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}
