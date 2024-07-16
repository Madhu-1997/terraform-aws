# VPC creation
resource "aws_vpc" "workshop" {
  cidr_block           = var.vpc_cidr#"10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "workshop"
    Environment =  var.environment#"development"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.workshop.id

  tags = {
    Name = "my_igw"
  }
}

# Create an Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.workshop.id
  cidr_block = var.public_subnet_cidr#"10.0.100.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.subnet_availability_zone#"us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}

# Create an Private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.workshop.id
  cidr_block = var.private_subnet_cidr#"10.0.101.0/24"
  availability_zone = var.subnet_availability_zone#"us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

# Create a Route Table
resource "aws_route_table" "workshop_rt" {
  vpc_id = aws_vpc.workshop.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "workshop_route_table"
  }
}

# Set the Route Table as the Main Route Table
resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.workshop.id
  route_table_id = aws_route_table.workshop_rt.id
}


# Create security group to allow the http and ssh
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Security group with allow all rules"
  vpc_id      = aws_vpc.workshop.id # Replace with your VPC ID

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

# Create aws linux instance
resource "aws_instance" "workshop" {
  ami           = var.ami_id #"ami-06c68f701d8090592"
  instance_type = var.instance_type #"t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name = var.key_name #"workshop-key"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  associate_public_ip_address = true

  tags = {
    Name = "workshop"
    Environment = "DEV"
  }
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.workshop.public_ip
}