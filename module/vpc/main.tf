resource "aws_vpc" "vpc" {
    cidr_block       = var.vpc_id
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "EKS_VPC"
    }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
  cidr_block        = var.public_subnet_id_value   # Replace with your desired CIDR block
  availability_zone = var.availability_zone_1 # Replace with your desired Availability Zone
  map_public_ip_on_launch = var.map_public_ip_on_launch           # Enable auto-assign public IP

  # Optional: Assign tags to your subnets
  tags = {
    Name = "EKS_Public_Subnet"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
  cidr_block        = var.private_subnet_id_value_1  # Replace with your desired CIDR block
  availability_zone = var.availability_zone_2 # Replace with your desired Availability Zone

  # Optional: Assign tags to your subnets
  tags = {
    Name = "EKS_Private_Subnet_01"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.vpc.id  # Replace with your VPC ID
  cidr_block        = var.private_subnet_id_value_2  # Replace with your desired CIDR block
  availability_zone = var.availability_zone_3 # Replace with your desired Availability Zone

  # Optional: Assign tags to your subnets
  tags = {
    Name = "EKS_Private_Subnet_02"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  # Optional: Assign tags to your Internet Gateway
  tags = {
    Name = "EKS_Internet_Gateway"
  }
}

resource "aws_eip" "eip" {
    domain = "vpc"

  # Optional: Associate tags with the Elastic IP
  tags = {
    Name = "EKS_ElasticIP"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

# Optional: Associate tags with the Elastic IP
  tags = {
    Name = "EKS_Nat_gateway"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Optional: Assign tags to your route table
  tags = {
    Name = "EKS_RouteTable_1"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  # Optional: Assign tags to your route table
  tags = {
    Name = "EKS_RouteTable_2"
  }
}

resource "aws_route_table_association" "subnet_association_1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "subnet_association_2" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "subnet_association_3" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.rt2.id
}