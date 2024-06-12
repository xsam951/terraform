locals {
  # The name of the EC2 instance
  name = "webserver"
  owner = "st"
}

### Select the newest AMI

data "aws_ami" "latest_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }
}

### Create Security Group

resource "aws_security_group" "sec_group" {
  name        = "webserver_sg"
  description = "http & ssh"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver_sg"
  }
}


### Create an EC2 instance

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.latest_linux_ami.id
  instance_type               = "t2.micro"
  availability_zone           = "us-west-2a"
  associate_public_ip_address = true
  key_name                    = "vockey"
  vpc_security_group_ids      = [aws_security_group.sec_group.id]
  subnet_id                   = aws_subnet.public-1.id
  count = 1
  tags = {
    Name = "webserver-deham14"
 # user_data = file("userdata.tpl")
  }

  user_data = file("userdata.tpl")
# user_data = "${base64encode(data.template_file.ec2userdatatemplate.rendered)}"

  provisioner "local-exec" {
    command = "echo Instance Type = ${self.instance_type}, Instance ID = ${self.id}, Public IP = ${self.public_ip}, AMI ID = ${self.ami} >> metadata"
  }
}

output "public_ip" {
  value = aws_instance.instance[0].public_ip
}