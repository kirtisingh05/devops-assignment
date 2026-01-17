provider "aws" {
  region = "us-east-1"
}

# 1. Secure Security Group
resource "aws_security_group" "web_sg" {
  name        = "devops-assignment-sg-strict"
  description = "Security group for web server with restricted access"

  # [FIX 1] INGRESS: SSH Restricted to specific IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.100/32"] 
    description = "Allow SSH from internal admin IP only"
  }

  # INGRESS: HTTP Allowed (Standard for Web Server)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP web traffic from the internet"
  }

  # [FIX 3 - THE NEW FIX] EGRESS: Only allow HTTP/HTTPS (No "All Traffic")
  # This fixes the "CRITICAL: Egress" error.
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound for updates"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for updates"
  }
}

# 2. Secure EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t2.micro"

  security_groups = [aws_security_group.web_sg.name]

  # [FIX 2] ENCRYPTED ROOT VOLUME
  root_block_device {
    encrypted = true
  }

  # [FIX 4] IMDSv2
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              echo "<h1>Hello! DevOps Assignment Deployed Successfully</h1>" | sudo tee /var/www/html/index.html
              echo "<p>Running on AWS EC2</p>" | sudo tee -a /var/www/html/index.html
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "DevOps-Assignment-Server-Secure"
  }
}

output "website_url" {
  value = "http://${aws_instance.web_server.public_ip}"
}
