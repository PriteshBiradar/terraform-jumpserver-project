resource "aws_vpc" "vpc_a" {
  cidr_block           = var.vpc_a_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Jump-server-vpc-a"
  }

}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_az
  map_public_ip_on_launch = true

  tags = {
    Name = "Jump-server-public-subnet"
  }
}

resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id

  tags = {
    Name = "jump-server-IGW"
  }
}

resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.vpc_a.id
  #route
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id

  }
  #peering
  route {
    cidr_block                = aws_vpc.vpc-b.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
  tags = {
    Name = "public_route_table"
  }

}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-RT.id
}

resource "aws_vpc" "vpc-b" {
  cidr_block           = var.vpc_b_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Jump-server-vpc-b"
  }

}
resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.vpc-b.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.private_az
  map_public_ip_on_launch = false

  tags = {
    Name = "application-private-subnet"
  }
}

resource "aws_subnet" "private-subnet-db" {
  vpc_id                  = aws_vpc.vpc-b.id
  cidr_block              = var.private-db-cidr_block
  availability_zone       = var.private-db-az
  map_public_ip_on_launch = false

  tags = {
    Name = "DB-private-subnet"
  }


}
resource "aws_subnet" "public-subnet-b" {
  vpc_id            = aws_vpc.vpc-b.id
  cidr_block        = var.public-subnet-b-cidr-block
  availability_zone = var.public-subnet-v-AZ

  map_public_ip_on_launch = false
  tags = {
    Name = "public-subnet-B"
  }

}
resource "aws_internet_gateway" "public-b-igw" {
  vpc_id = aws_vpc.vpc-b.id

  tags = {
    Name = "public-b-igw"
  }
}
resource "aws_route_table" "public-RT-B" {
  vpc_id = aws_vpc.vpc-b.id
  #internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public-b-igw.id
  }

  tags = {
    Name = "public-subnet-RT-B"
  }
}

resource "aws_route_table_association" "public-route-table-associate-b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.public-RT-B.id
}

resource "aws_eip" "eip-nat" {
  domain = "vpc"

  tags = {
    Name = "NAT-Gateway-EIP"
  }
}
resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.public-subnet-b.id

  tags = {
    Name = "Private-nat-gateway"
  }

  depends_on = [aws_internet_gateway.public-b-igw]

}
resource "aws_route_table" "private-RT" {
  vpc_id = aws_vpc.vpc-b.id
  #peering
  route {
    cidr_block                = aws_vpc.vpc_a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  #NAT gateway 
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "application-private-rt"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-RT.id
}
resource "aws_route_table_association" "private_route_table_db" {
  subnet_id      = aws_subnet.private-subnet-db.id
  route_table_id = aws_route_table.private-RT.id
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc-b.id
  auto_accept = true

  tags = {
    Name = "jump-server-to-application-server"
  }
}

resource "aws_security_group" "sg" {
  for_each    = var.Security-Groups
  name        = each.key
  description = each.value.description
  vpc_id      = each.value.vpc == "vpc_a" ? aws_vpc.vpc_a.id : aws_vpc.vpc-b.id



  tags = {
    Name = "${each.key}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion-rdp" {
  security_group_id = aws_security_group.sg["bastion-sg"].id

  cidr_ipv4   = "103.110.241.21/32"
  from_port   = 3389
  to_port     = 3389
  ip_protocol = "tcp"



  description = "Allow RDP from bastion host"
}
resource "aws_vpc_security_group_ingress_rule" "bastion-ssh" {
  security_group_id = aws_security_group.sg["bastion-sg"].id

  cidr_ipv4   = "103.110.241.21/32"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  description = "Allow SSH from my IP"
}

resource "aws_vpc_security_group_ingress_rule" "bastion-empheral" {
    security_group_id = aws_security_group.sg["bastion-sg"].id

  cidr_ipv4   = "103.110.241.21/32"
  from_port   = 1024
  to_port     = 65535
  ip_protocol = "tcp"

  description = "Allow SSH from my IP"
}




resource "aws_vpc_security_group_egress_rule" "bastion-all" {
  security_group_id = aws_security_group.sg["bastion-sg"].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow all outbound traffic from bastion host"
}

resource "aws_vpc_security_group_ingress_rule" "application_ssh" {

  security_group_id = aws_security_group.sg["application-sg"].id
  referenced_security_group_id = aws_security_group.sg["bastion-sg"].id
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  description = "Allow ssh"
}

resource "aws_vpc_security_group_ingress_rule" "application-http" {
    security_group_id = aws_security_group.sg["application-sg"].id
    referenced_security_group_id = aws_security_group.sg["bastion-sg"].id

    from_port = 80
    to_port = 80
    ip_protocol = "tcp"

    description = "Allowing http from jump to bastion "
}
resource "aws_vpc_security_group_ingress_rule" "application_empheral" {

  security_group_id = aws_security_group.sg["application-sg"].id
  referenced_security_group_id = aws_security_group.sg["bastion-sg"].id
  from_port   = 1024
  to_port     = 65535
  ip_protocol = "tcp"

  description = "Allow ssh"
}

resource "aws_vpc_security_group_egress_rule" "application-all" {
  security_group_id = aws_security_group.sg["application-sg"].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "allowing all outbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "rds_mysql" {

  security_group_id = aws_security_group.sg["rds-sg"].id

  referenced_security_group_id = aws_security_group.sg["application-sg"].id

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"

  description = "Allow MySQL from Application Server"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {

  security_group_id = aws_security_group.sg["rds-sg"].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}

resource "aws_instance" "window-server" {

  ami           = var.Windows-ami-id
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  key_name                    = var.key_name

  vpc_security_group_ids = [aws_security_group.sg["bastion-sg"].id]

  tags = {
    Name = "Window-jump-server"
  }

}


resource "aws_instance" "linux-server" {
  ami           = var.linux-ami-id
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.private-subnet.id
  associate_public_ip_address = false
  key_name                    = var.key_name

  vpc_security_group_ids = [aws_security_group.sg["application-sg"].id]

  tags = {
    Name = "Private-Application-server"
  }
}

resource "aws_db_subnet_group" "mysql" {
  name = "mysql-subnet-group"

  subnet_ids = [aws_subnet.private-subnet.id, aws_subnet.private-subnet-db.id]

  tags = {
    Name = "mysql-private-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier        = "application-mysql"
  engine            = "mysql"
  engine_version    = "8.0.42"
  instance_class    = "db.t3.small"
  allocated_storage = 20
  storage_type      = "gp3"
  db_name           = "employee_db"
  username          = "admin"
  password          = var.db_password

  db_subnet_group_name = aws_db_subnet_group.mysql.name

  vpc_security_group_ids = [aws_security_group.sg["rds-sg"].id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "Application-mysql"
  }
}