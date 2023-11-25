resource "aws_key_pair" "project_key_pair" {
  key_name   = "projeto-key-pair"
  public_key = file("project-key-pair.pub")
}

resource "aws_lb" "this" {
  name               = "${var.application_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project_sg_lb.id]
  subnets            = var.public_subnets
  enable_deletion_protection = false

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
  key_name      = aws_key_pair.project_key_pair.key_name
   network_interfaces {
    security_groups = [aws_security_group.project_sg_instance.id]
    associate_public_ip_address = true
    subnet_id = var.public_subnet_a_id
  
  }

  iam_instance_profile {
    name = var.profile_name
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo touch app.log 
    export DEBIAN_FRONTEND=noninteractive

    sudo apt -y remove needrestart
    echo "fez o needrestart" >> app.log
    sudo apt-get update
    echo "fez o update" >> app.log
    sudo apt-get install -y python3-pip python3-venv git
    echo "fez o install de tudo" >> app.log

    # Criação do ambiente virtual e ativação
    python3 -m venv /home/ubuntu/myappenv
    echo "criou o env" >> app.log
    source /home/ubuntu/myappenv/bin/activate
    echo "ativou o env" >> app.log

    # Clonagem do repositório da aplicação
    git clone https://github.com/ArthurCisotto/aplicacao_projeto_cloud.git /home/ubuntu/myapp
    echo "clonou o repo" >> app.log

    # Instalação das dependências da aplicação
    pip install -r /home/ubuntu/myapp/requirements.txt
    echo "instalou os requirements" >> app.log

    sudo apt-get install -y uvicorn
    echo "instalou o uvicorn" >> app.log
 
    # Configuração da variável de ambiente para o banco de dados
    export DATABASE_URL="mysql+pymysql://admin:secretpassword@admin123/hudson_db"
    echo "exportou o url" >> app.log

    cd /home/ubuntu/myapp
    # Inicialização da aplicação
    uvicorn main:app --host 0.0.0.0 --port 80 
    echo "inicializou" >> app.log
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
  name                      = "${var.application_name}_asg"
  
  launch_template {
    id      = aws_launch_template.project_launch_template.id
    version = "$Latest"    
  }
  target_group_arns         = [aws_lb_target_group.lb_target_group.arn] //preciso informar o target group
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = var.public_subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300
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
  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   security_groups = [aws_security_group.project_sg_lb.id]
  # }
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
   ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.project_sg_lb.id]
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
  lb_target_group_arn   = aws_lb_target_group.lb_target_group.arn

}
