provider "aws" {
  region = "us-east-1"
}

# 1. Security Group
resource "aws_security_group" "web_sg" {
  name        = "devops-assignment-sg-final"
  description = "Security group for web server"

  # [NOTE] Temporarily open SSH to ALL so you don't get 'Connection Failed' errors
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
    description = "Allow SSH for setup and debugging"
  }

  # HTTP allowed for the website
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP web traffic from the internet"
  }

  # Outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# 2. EC2 Instance with Website Script
resource "aws_instance" "web_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t2.micro"

  security_groups = [aws_security_group.web_sg.name]

  # Enforce IMDSv2
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  # Encrypt the root hard drive
  root_block_device {
    encrypted = true
  }
  
  # --- SCRIPT TO INSTALL WEBSITE AUTOMATICALLY ---
  user_data = <<-EOF
              #!/bin/bash
              # Update and install Nginx
              sudo apt-get update
              sudo apt-get install -y nginx
              
              # Create the Hello World page
              echo "<html><head><title>DevOps Assignment</title></head><body>" | sudo tee /var/www/html/index.html
              echo "<h1>Hello! DevOps Assignment Deployed Successfully</h1>" | sudo tee -a /var/www/html/index.html
              echo "<p>Running on AWS EC2</p></body></html>" | sudo tee -a /var/www/html/index.html
              
              # Start the server
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
  # ----------------------------------------------------

  tags = {
    Name = "DevOps-Assignment-Server-Final"
  }
}

# 3. Output the Web Address
output "website_url" {
  value = "http://${aws_instance.web_server.public_ip}"
}
