
resource "aws_lb" "this" {
  name                       = "${var.application_name}-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.project_sg_lb.id]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
  depends_on                 = [aws_autoscaling_group.project_asg]
  tags = {
    Name = "${var.application_name}_lb"
  }
}


resource "aws_lb_target_group" "lb_target_group" {
  name     = "${var.application_name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags = {
    Name = "${var.application_name}_target_group"
  }
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    path                = "/docs"
    protocol            = "HTTP"
    port                = "80"
  }
}


resource "aws_lb_listener" "projeto_lb_listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }

}




resource "aws_launch_template" "project_launch_template" {
  name_prefix   = "${var.application_name}_launch_template"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  network_interfaces {
    security_groups             = [aws_security_group.project_sg_instance.id]
    associate_public_ip_address = true
    subnet_id                   = var.public_subnet_a_id

  }

  iam_instance_profile {
    name = var.profile_name
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo touch app.log 
    export DEBIAN_FRONTEND=noninteractive

    sudo apt -y remove needrestart
    sudo apt-get update
    sudo apt-get install -y python3-pip python3-venv git

    # Criação do ambiente virtual e ativação
    python3 -m venv /home/ubuntu/myappenv
    
    source /home/ubuntu/myappenv/bin/activate
   

    # Clonagem do repositório da aplicação
    git clone https://github.com/HudsonArauj/aplicacao_cloud.git /home/ubuntu/myapp
    

    # Instalação das dependências da aplicação
    pip install -r /home/ubuntu/myapp/requirements.txt
    
    export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    echo $INSTANCE_ID >> /home/ubuntu/myapp/app.log
    # Creating log stream...
    aws logs create-log-stream --log-group-name "/my-fastapi-app/logs" --log-stream-name "$INSTANCE_ID" --region us-east-1

    sudo apt-get install -y uvicorn
    
    # Configuração da variável de ambiente para o banco de dados
    export DATABASE_URL="mysql+pymysql://admin:admin123@${var.project_db}/hudson_db"
    

    # Setting up authbind for port 80...
    # sudo apt install authbind
    # sudo touch /etc/authbind/byport/80
    # sudo chmod 500 /etc/authbind/byport/80
    # sudo chown ubuntu /etc/authbind/byport/80
    
    cd /home/ubuntu/myapp
    # Inicialização da aplicação
    uvicorn main:app --host 0.0.0.0 --port 80 
  EOF
  )


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.application_name}_launch_template"
    }
  }


}

resource "aws_autoscaling_group" "project_asg" {
  name       = "${var.application_name}_asg"

  lifecycle {
    create_before_destroy = true
  }
  launch_template {
    id      = aws_launch_template.project_launch_template.id
    version = "$Latest"
  }
  target_group_arns         = [aws_lb_target_group.lb_target_group.arn] //preciso informar o target group
  desired_capacity     = 2
  max_size             = 6
  min_size             = 2
  vpc_zone_identifier       = var.public_subnets
  health_check_type         = "EC2"
  health_check_grace_period = 120
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "${var.application_name}_asg"
    propagate_at_launch = true
  }

}


resource "aws_security_group" "project_sg_instance" {
  name   = "${var.application_name}_sg_asg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.project_sg_lb.id]
  }
  ingress {
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

resource "aws_security_group" "project_sg_lb" {
  name   = "${var.application_name}_security_group_lb"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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




resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.project_asg.id
  lb_target_group_arn    = aws_lb_target_group.lb_target_group.arn

}


resource "aws_sns_topic" "sns_topic" {
  name = "my_sns_topic"
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "hudsonmonteiro2011@gmail.com"
}

# Configura o CloudWatch para monitorar a utilização da CPU da instância EC2
# // cloudwatch alarm para baixa utilização da CPU

resource "aws_autoscaling_policy" "asg_policy_up" {
  name                   = "my-asg-policy1"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.project_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 10.0
  }
  
}
resource "aws_autoscaling_policy" "asg_policy_down" {
  name                   = "my-asg-policy2"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.project_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
  
}

resource "aws_cloudwatch_log_group" "my_log_group" {
  name = "/my-fastapi-app/logs"
}