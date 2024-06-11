#ami_id="ami-058b428b3b45defec"
# Create the AWS VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name      = "workshop"
    terraform = true
  }
}

# Create subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "workshop"
  }
}

# create one security group and open only port no 80 to public, 22 to open only from your laptop

resource "aws_security_group" "allow_all" {
  name        = "allow_all_ingress"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTPS from internet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_traffic"
  }
}

# Create a centos instance
resource "aws_instance" "centos" {
  ami = "ami-0b4f379183e5706b9"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  tags = {
    Name = "CentOs"
  }
}
# Output the instance public IP
output "instance_public_ip" {
  value = aws_instance.centos.public_ip
}