resource "aws_key_pair" "project_key_pair" {
  key_name   = "${var.application_name}-key-pair_${timestamp()}"
  public_key = file("project-key-pair.pub")
}

resource "aws_security_group" "project_sg_ssh" {
  name   = "${var.application_name}_security_group"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
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
// instancia de ec2
resource "aws_instance" "ec2" {
  ami                         = var.ami_id //preciso informar a imagem do sistema operacional( nesse caso é uma imagem do ubuntu)
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_a //preciso informar a subnet que a maquina vai ficar
  associate_public_ip_address = true          //preciso informar que a maquina vai ter um ip publico
  key_name                    = aws_key_pair.project_key_pair.key_name
  security_groups             = [aws_security_group.project_sg_ssh.id]
  tags = {
    Name = "${var.application_name}_ec2"
  }
}

//cloudwatch alarm
resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name = "${var.application_name}-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "70"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.ec2.id
  }
}