aws_region = "us-east-1"

vpc_a_cidr = "10.0.0.0/16"

public_subnet_cidr = "10.0.1.0/24"

public_az = "us-east-1a"

vpc_b_cidr = "10.1.0.0/16"

private_subnet_cidr = "10.1.1.0/24"

private_az = "us-east-1a"

my_ip = "103.110.241.21/32"

private-db-cidr_block = "10.1.2.0/24"

private-db-az = "us-east-1b"

public-subnet-b-cidr-block = "10.1.3.0/24"

public-subnet-v-AZ = "us-east-1a"

Security-Groups = {
  "bastion-sg" = {
    description = "Allow ssh to bastion host"
    vpc         = "vpc_a"

  }
  "application-sg" = {
    description = "Allow ssh to jump server"
    vpc         = "vpc-b"

  }
  "rds-sg" = {
    description = "MySQL RDS"
    vpc         = "vpc-b"
  }
}

Windows-ami-id = "ami-0e63f9f6f90117000"

linux-ami-id = "ami-0bdc7d025135d7b49"

key_name = "Jump-server"

db_password = "Admin123"

