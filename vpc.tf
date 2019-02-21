#VPC Creation
resource "aws_vpc" "myvpc" {
  cidr_block       = "172.20.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "APM"
  }
}
#Public Subnet Creation
resource "aws_subnet" "public-subnet1" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "172.20.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Public Subnet1"
  }
}
#Private Subnet1 Creation
resource "aws_subnet" "private-subnet1" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "172.20.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private Subnet1"
  }
}
#Private Subnet2 Creation
resource "aws_subnet" "private-subnet2" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "172.20.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "Private Subnet2"
  }
}
#Internet Gateway Creation
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
    Name = "APM-IGW"
  }
}
#Elastic Ip Creation
resource "aws_eip" "nat" {
    vpc      = true
}
#NAT Gateway Creation
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public-subnet1.id}"
  depends_on = ["aws_internet_gateway.gw"]
}
#Public Route Table Creation
resource "aws_route_table" "publicrt" {
  vpc_id = "${aws_vpc.myvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "PublicRT"
  }
}
#Private Route Table Creation
resource "aws_route_table" "privatert" {
  vpc_id = "${aws_vpc.myvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }
  tags = {
    Name = "PrivateRT"
  }
}
#Public Route Table Association
resource "aws_route_table_association" "public-association" {
  subnet_id      = "${aws_subnet.public-subnet1.id}"
  route_table_id = "${aws_route_table.publicrt.id}"
}
#Private Route Table Associations
resource "aws_route_table_association" "private1-association" {
  subnet_id      = "${aws_subnet.private-subnet1.id}"
  route_table_id = "${aws_route_table.privatert.id}"
}
resource "aws_route_table_association" "private2-association" {
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  route_table_id = "${aws_route_table.privatert.id}"
}

#Bastion host
resource "aws_instance" "Bastion" {
  ami = "${lookup(var.AMIS,var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.public-subnet1.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  tags {
    Name = "Webserver"
  } 
}
#Webserver
resource "aws_instance" "Webserver" {
  ami = "${lookup(var.AMIS,var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.public-subnet1.id}" 
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  tags {
    Name = "Webserver"
  }
}
 # provisioner "remote-exec" {
 #   command = "ansible-playbook -u ec2-user -i '${self.private_ip},' --private-key ${var.ssh_key_private} apache.yml" 
 # }
 # connection {
 #     type        = "ssh"
 #     user        = "ec2-user"
 #     private_key = "${file(var.ssh_key_private)}"
 #   }
 #}
#APM portal server
resource "aws_instance" "APM-portal" {
  ami = "${lookup(var.AMIS,var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.private-subnet1.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  tags {
    Name = "APM-portal"
  }
}
 # provisioner "remote-exec" {
 #   command = "ansible-playbook -u ec2-user -i '${self.private_ip},' --private-key ${var.ssh_key_private} main-portal.yml"
 # }
 # connection {
  #    type        = "ssh"
  #    user        = "ec2-user"
  #    private_key = "${file(var.ssh_key_private)}"
  #  }
 #}
#APM Alipay server
resource "aws_instance" "APM-alipay" {
  ami = "${lookup(var.AMIS,var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.private-subnet1.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  tags {
    Name = "APM-alipay"
  }
}
 # provisioner "remote-exec" {
 #   command = "ansible-playbook -u ec2-user -i '${self.private_ip},' --private-key ${var.ssh_key_private} main-alipay.yml"
 # }
 # connection {
 #     type        = "ssh"
 #     user        = "ec2-user"
 #     private_key = "${file(var.ssh_key_private)}"
 #   }
 #}
#APM schedular  server
resource "aws_instance" "APM-schedular" {
  ami = "${lookup(var.AMIS,var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.private-subnet1.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  tags {
    Name = "APM-schedular"
  }
}
 # provisioner "remote-exec" {
 #   command = "ansible-playbook -u ec2-user -i '${self.private_ip},' --private-key ${var.ssh_key_private} main-scheduler.yml"
 # }
 # connection {
 #     type        = "ssh"
 #     user        = "ec2-user"
 #     private_key = "${file(var.ssh_key_private)}"
 #   }
# }
#APM Mysql  DB  server
resource "aws_instance" "APM-DB" {
  ami = "${lookup(var.AMI,var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.private-subnet2.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  tags {
    Name = "APM-DB"
  }
}
 # provisioner "remote-exec" {
 #   command = "ansible-playbook -u ubuntu -i '${self.private_ip},' --private-key ${var.ssh_key_private} mysql-playbook.yml"
 # }
 # connection {
 #     type        = "ssh"
 #    user        = "ubuntu"
 #     private_key = "${file(var.ssh_key_private)}"
 #   }
 #}
#SG for Bastion server
resource "aws_security_group" "sg" {
  name        = "sg1"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"

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
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags {
    Name = "sg1"
  }
}
