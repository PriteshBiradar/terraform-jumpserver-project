variable "aws_region" {
  description = "AWS region "
  type        = string
}

variable "vpc_a_cidr" {
  description = "CIDR Range for vpc A"
  type        = string
}

variable "public_subnet_cidr" {
  description = "cidr block for public subnet"
  type        = string
}

variable "public_az" {
  description = "Availability zone for public subnet"
  type        = string
}

variable "vpc_b_cidr" {
  description = "CIDR range for vpc B"
  type        = string
}

variable "private_subnet_cidr" {
  description = "cidr block for private subnet"
  type        = string
}

variable "private_az" {
  description = "Availability zone for private subnet"
  type        = string
}

variable "private-db-cidr_block" {
  description = "private subnet cidr block for DB subnets"
  type        = string
}
variable "private-db-az" {
  description = "private subnet AZ  for DB subnets"
  type        = string
}

variable "public-subnet-b-cidr-block" {
  description = "cidr block of vpc b public subnet"
  type        = string
}
variable "public-subnet-v-AZ" {
  description = "Availability zone for public subnet vpc b"
  type        = string
}

variable "my_ip" {
  description = "IP address for jump server"
  type        = string
}

variable "Security-Groups" {
  description = "Security Groups"
  type = map(object({
    description = string
    vpc         = string
    # ingress = list(object({
    #     from_port = number
    #     to_port = number
    #     protocol = string
    #     cidr_blocks = optional(list(string),[])
    #     security_groups = optional(list(string),[])
    # }))

    # egress = list(object({
    #     from_port = number
    #     to_port = number
    #     protocol = string
    #     cidr_blocks = list(string)
    # }))
  }))
}

variable "Windows-ami-id" {
  description = "AMI ID for Windows"
  type        = string
}

variable "linux-ami-id" {
  description = "Ami id for Amazon linux"
  type        = string
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name "
  type        = string
}
variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}