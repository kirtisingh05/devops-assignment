provider "aws" {
  region = "us-east-1"
}

# 1. Secure Security Group
resource "aws_security_group" "web_sg" {
  name        = "devops-assignment-sg-secure-final"
  description = "Security group for web server with restricted access"

  # [FIX 1] SSH RESTRICTED: Only allow access from one specific IP (not the whole world)
  # This fixes the "CRITICAL: Ingress from public internet" error.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.100/32"] 
    description = "Allow SSH from internal admin IP only"
  }

  # HTTP is allowed for the website (This is safe/normal for a web server)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP web traffic from the internet"
  }

  # Egress (Outbound) - allow server to talk to the internet
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

  # [FIX 2] ENCRYPTED ROOT VOLUME: Protects data at rest.
  # This fixes the "HIGH: Unencrypted root block device" error.
  root_block_device {
    encrypted = true
  }

  # [FIX 3] IMDSv2: Prevents SSRF attacks.
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  # Script to launch the website
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

# 3. Output URL
output "website_url" {
  value = "http://${aws_instance.web_server.public_ip}"
}
