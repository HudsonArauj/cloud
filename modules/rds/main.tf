
resource "aws_security_group" "project_sg_db" {
  name   = "${var.application_name}_sg_db"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
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

resource "aws_db_instance" "project_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "admin123"
  parameter_group_name   = "default.mysql5.7"
  db_name = "hudson_db"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.project_sg_db.id]
  db_subnet_group_name   = aws_db_subnet_group.project_db_subnet_group.name
  tags = {
    Name = "${var.application_name}_db"
  }

}

resource "aws_db_subnet_group" "project_db_subnet_group" {
  name       = "${var.application_name}_db_subnet_group"
  subnet_ids = [var.private_subnet_a, var.private_subnet_b]
  tags = {
    Name = "${var.application_name}_db_subnet_group"
  }

}
