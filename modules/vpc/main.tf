resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/16"  //bloco de endereço
  enable_dns_hostnames = true          // configurar uma abela de hosts e rotas 
  enable_dns_support   = true

  tags = {
    Name = "${var.application_name}_public_vpc"
  }
}


//configurando a subrede
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.application_name}_public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.application_name}_public_subnet_b"
  }
}

resource "aws_internet_gateway" "project_gateway" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "${var.application_name}_internet_gateway"
  }
}

// Preciso fazer o roteamento para a internet
resource "aws_route_table" "projeto_route_table" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "${var.application_name}_route_table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_gateway.id
  }
}

//vincular a subnet a subrede, tornar ela publica
resource "aws_route_table_association" "table_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.projeto_route_table.id
}

resource "aws_route_table_association" "table_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.projeto_route_table.id
}

//criar subrede privada
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.application_name}_private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.application_name}_private_subnet_b"
  }
}


# resource "aws_eip" "project_eip_a" {
#   vpc        = true
#   # depends_on = [aws_internet_gateway.project_gateway]
#   tags = {
#     Name = "${var.application_name}_eip_a"
#   }

# }

# resource "aws_eip" "project_eip_b" {
#   vpc        = true
#   # depends_on = [aws_internet_gateway.project_gateway]
#   tags = {
#     Name = "${var.application_name}_eip_b"
#   }

# }


# resource "aws_nat_gateway" "project_nat_gateway_a" {
#   allocation_id = aws_eip.project_eip_a.id
#   subnet_id     = aws_subnet.public_subnet_a.id
#   tags = {
#     Name = "${var.application_name}_nat_gateway_a"
#   }

# }

# resource "aws_nat_gateway" "project_nat_gateway_b" {
#   allocation_id = aws_eip.project_eip_b.id
#   subnet_id     = aws_subnet.public_subnet_b.id
#   tags = {
#     Name = "${var.application_name}_nat_gateway_b"
#   }

# }


// criar rota para internet
# resource "aws_route_table" "route_table_nat_a" {
#   vpc_id = aws_vpc.project_vpc.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.project_nat_gateway_a.id

#   }
#   tags = {
#     Name = "${var.application_name}_route_table_nat_a"
#   }
# }

# resource "aws_route_table" "route_table_nat_b" {
#   vpc_id = aws_vpc.project_vpc.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.project_nat_gateway_b.id

#   }
#   tags = {
#     Name = "${var.application_name}_route_table_nat_b"
#   } 
# }

# resource "aws_route" "route_internet_access" {
#   route_table_id = aws_route_table.projeto_route_table.id
#   destination_cidr_block = "0.0.0.0/0"  //todo endereço de internet vamos direcionar para um gateway
# }


// vincular a subrede privada a tabela de roteamento
# resource "aws_route_table_association" "table_private_a" {
#   subnet_id      = aws_subnet.private_subnet_a.id
#   route_table_id = aws_route_table.route_table_nat_a.id
# }

# resource "aws_route_table_association" "table_private_b" {
#   subnet_id      = aws_subnet.private_subnet_b.id
#   route_table_id = aws_route_table.route_table_nat_b.id
# }
