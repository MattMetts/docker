variable "awsprops" {
    type = "map"
    default = {
    region = "us-east-1"
    vpc = "vpc-5234832d"
    ami = "ami-0c1bea58988a989155"
    itype = "t2.micro"
    subnet = "subnet-81896c8e"
    publicip = true
    keyname = "myseckey"
    secgroupname = "IAC-Sec-Group"
  }
}

provider "aws" {
  region = var.awsprops.region
}

resource "aws_security_group" "project-iac-sg" {
  name = var.awsprops.secgroupname
  description = var.awsprops.secgroupname
  vpc_id = var.awsprops.vpc

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }


  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "project-iac" {
  ami = var.awsprops.ami
  instance_type = var.awsprops.itype"
  subnet_id = var.awsprops.subnet
  associate_public_ip_address = var.awsprops.publicip
  key_name = var.awsprops.keyname


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sg ]
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}
