# To create the Ec2 instance
resource "aws_instance" "Ec2_instance_1" {
  ami                         = var.ami_value           # Change to your desired AMI ID
  instance_type               = var.instance_type_value # Change to your desired instance type
  subnet_id                   = var.public_subnet_id_value
  associate_public_ip_address = var.associate_public_ip_address         # Enable a public IP
  key_name                    = aws_key_pair.key_pair.key_name # Change to your key pair name
  availability_zone           = var.availability_zone_1
  count                       = var.instance_count
  vpc_security_group_ids      = [aws_security_group.example_security_group.id]
  # Use the user_data variable
  # user_data = var.user_data

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = "EKS-Instance-${count.index}"
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa-4096-example.public_key_openssh
}

resource "local_file" "private_key" {
  content = tls_private_key.rsa-4096-example.private_key_pem
  filename = var.key_name
}

# Define an Elastic IP for each instance
resource "aws_eip" "elastic_ip" {
  count  = var.instance_count  # Create an EIP for each instance
  domain = "vpc"

  tags = {
    Name = "EKS_EC2_Elastic_IP-${count.index}"
  }
}

# Attach each Elastic IP to the corresponding EC2 instance
resource "aws_eip_association" "eip_assoc" {
  count         = var.instance_count
  instance_id   = aws_instance.Ec2_instance_1[count.index].id
  allocation_id = aws_eip.elastic_ip[count.index].id
}

# Create a security group
resource "aws_security_group" "example_security_group" {
  name_prefix = var.security_group_name
  description = "Example security group"
  vpc_id      = var.vpc_id

  # Define your security group rules as needed
  # For example, allow SSH and HTTP traffic
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["${aws_eip.elastic_ip[0].public_ip}/32"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   # Allow traffic from EKS worker nodes (for internal communication)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [var.worknode_security_group_pass]  # Allow traffic from worker nodes
    description = "Allow communication from EKS worker nodes"
  }

  # Allow HTTP access (port 9000) for Sonar-Qube
  ingress {
    description = "sonarqube access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}