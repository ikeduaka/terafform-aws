provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "New-3tier-key" {
  key_name   = "$(terraform import aws_key_pair.New-3tier-key New-3tier-key)"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCJ9CrHDZVsy2L6lDMGweZPFQ69lCvIaFmYx/8Q/CuvvVuLbPFEvfaMWHnLVUvlefQOM1uuT2dYbNGpwowfpYi7kooxdooD3pgewx6ueFqIV4HuxkTfSY8o3ISUBIgPKOic93vL4e7PAmWNKmahszCNV7wvBtu3kXL6St0DoEIfm4Ii2SFp8JzFTurK66Zedoi4i6yccV+D77jtYy6GshoXPsCggwVOLT8b3vU0ztK/2YLLfgA/v/Yrc6KLzh0c1V964AhkoJM/fzBhU5H0uYzqzhob/ykJmOjIc3s77PQrcISoTIadRiNjOHPntcSuF1zBLgScD0TpMEJ4sgKCuHAT"
}


resource "aws_instance" "jenkins-ec2" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name      = "New-3tier-key"

  user_data = <<-EOF
  #!/bin/bash
  #install Java 11
  sudo apt-get update
  sudo apt-get install default-jdk -y

  #Repo key to the system
  curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc | sudo apt-key add -

  #Append debian package repo address to the system

  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list 
     
  #install Jenkins

  sudo apt-get update
  sudo apt-get install jenkins -y
  EOF

  tags = {
    Name = "jenkins-EC2"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id
  ingress {
    # SSH Port 22 allowed 
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    # inbound traffic from port 8080 
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_s3_bucket" "jenkin-101231101" {
  bucket = "jenkin-101231101"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    }

}