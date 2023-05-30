
# EC2 instance type and region

resource "aws_instance" "jenkins-ec2" {
  ami           = "${lookup(var.ami_id, var.region)}"
  instance_type = "${var.instance_type}"
  key_name = "my20key"

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

    Name = "jenkins-ec2-${random_id.random.hex}"
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

resource "aws_s3_bucket" "s3-jenkins" {
  bucket = "s3-jenkins-${random_id.random.hex}"
  tags = {
    Name = "mynew jenkins_S3 Bucket"

}
}
resource "aws_s3_bucket_acl" "jenkins_bucket_acl" {
  bucket = aws_s3_bucket.s3-jenkins.id
  acl = "private"
}

resource "random_id" "random" {
  byte_length = 16
}

resource "aws_key_pair" "my20key_auth" {
  key_name = "my20key"
  public_key = file("~/.ssh/ed01key.pub")
  }

