resource "aws_vpc" "medium_post_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Medium Post VPC"
  }
}

resource "aws_subnet" "public_medium_post_subnet" {
  vpc_id     = aws_vpc.medium_post_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Public_Medium_Post_Subnet"
  }
}



resource "aws_internet_gateway" "medium_post_igw" {
  vpc_id = aws_vpc.medium_post_vpc.id

  tags = {
    Name = "Medium_Post_Internet_Gateway"
  }
}


resource "aws_route_table" "public_medium_post_route_table" {
    vpc_id = aws_vpc.medium_post_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.medium_post_igw.id
    }

    tags = {
        Name = "Public_Medium_Post_Route_Table"
    }
}

resource "aws_route_table_association" "public_medium_post_route_table" {
    subnet_id = aws_subnet.public_medium_post_subnet.id
    route_table_id = aws_route_table.public_medium_post_route_table.id
}


resource "aws_security_group" "medium_post_allow_ssh" {
  name        = "medium_post_allow_ssh_sg"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.medium_post_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }


  tags = {
    Name = "medium_post_allow_ssh_sg"
  }
}


resource "aws_instance" "medium_post_instance" {
  ami           = "ami-0a669382ea0feb73a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.medium_post_allow_ssh.id]
  subnet_id = aws_subnet.public_medium_post_subnet.id
  associate_public_ip_address = true
  user_data = <<-EOF
            #! /bin/bash 
            sudo yum install httpd -y
            sudo systemctl start httpd
            sudo systemctl enable httpd
            echo "<h1> Webserver for the Medium Article!</h1>" >> /var/www/html/index.html
  EOF
  tags = {
    Name = "Public_Medium_Post_Instance"
  }
}



output "My-Instance-Public-IP" {
  value = aws_instance.medium_post_instance.public_ip
}