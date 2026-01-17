provider "aws" {
  region = "us-east-1"
}

# 1. Secure Security Group
resource "aws_security_group" "web_sg" {
  name        = "devops-assignment-sg-secure"
  description = "Security group for web server with restricted access"

  # [FIXED] SSH is now restricted to a single Private IP (simulating your office/home IP)
  # This fixes the CRITICAL vulnerability of having Port 22 open to the world.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.100/32"] 
    description = "Allow SSH from internal network only"
  }

  # [FIXED] HTTP (Port 80) MUST be open for a web server to work.
  # We added a description to satisfy the "Low" severity audit finding.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP web traffic from the internet"
  }

  # [FIXED] Added description to Egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# 2. Secure EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t2.micro"

  security_groups = [aws_security_group.web_sg.name]

  # [FIXED] Enforce IMDSv2 (Token Required) to prevent SSRF attacks
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  # [FIXED] Encrypt the root hard drive to protect data at rest
  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "DevOps-Assignment-Server-Secure"
  }
}