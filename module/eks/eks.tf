# Create a security group
resource "aws_security_group" "EKS_cluster_sg" {
  name_prefix = var.security_group_name
  description = "EKS security group"
  vpc_id      = var.vpc_id

  # Define your security group rules as needed
  # For example, allow SSH and HTTP traffic
  ingress {
    description = "Allow traffic within the cluster"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    # security_groups = [var.ec2_security_group_pass]  # ✅ Correct usage
  }

  # outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# To create policy documenent1
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# To create the IAM role1
resource "aws_iam_role" "eks_role_1" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

# To attach the policy to IAM role1
resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role_1.name
}

# To Create EKS cluster
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role_1.arn

  vpc_config {
    subnet_ids = [var.private_subnet_id_value_1, var.private_subnet_id_value_2]
    security_group_ids = [aws_security_group.EKS_cluster_sg.id]
  }
}

# 2. IAM Role for Worker Nodes
resource "aws_iam_role" "worker_node_role" {
  name = "eks-worker-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM role policy attachment for EBS actions
resource "aws_iam_policy" "ebs_policy" {
  name        = var.ebs_policy
  description = "Policy to allow EBS actions for EKS worker nodes"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:ModifyVolume"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the EBS policy to the IAM role used by EKS nodes
resource "aws_iam_role_policy_attachment" "attach_ebs_policy" {
  policy_arn = aws_iam_policy.ebs_policy.arn
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_instance_profile" "worker_node_profile" {
  name = "eks-worker-node-profile"
  role = aws_iam_role.worker_node_role.name
}

# Attach AmazonEKSWorkerNodePolicy
resource "aws_iam_policy_attachment" "worker_node_policy" {
  name       = "eks-worker-node-policy"
  roles      = [aws_iam_role.worker_node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach AmazonEC2ContainerRegistryReadOnly
resource "aws_iam_policy_attachment" "worker_node_ecr_policy" {
  name       = "eks-worker-node-ecr-policy"
  roles      = [aws_iam_role.worker_node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach AmazonEKS_CNI_Policy
resource "aws_iam_policy_attachment" "worker_node_cni_policy" {
  name       = "eks-worker-node-cni-policy"
  roles      = [aws_iam_role.worker_node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Attach AmazonEBSCSIDriverPolicy
resource "aws_iam_policy_attachment" "ebs_csi_driver_policy" {
  name       = "eks-worker-node-ebs-csi-policy"
  roles      = [aws_iam_role.worker_node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}








# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name_prefix = var.alb_security_name
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow traffic from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow traffic from the internet"
    from_port   = 443
    to_port     = 443
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


# Worker Node Security Group
resource "aws_security_group" "worker_node_sg" {
  name_prefix = var.worker_node_sg_name
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [var.ec2_security_group_pass] # Allow SSH from Public_Server
  }

  ingress {
    description = "Allow traffic from EKS Control Plane"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.EKS_cluster_sg.id]
  }

  ingress {
    description = "Allow traffic from ALB"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# To create the Ec2 instance
resource "aws_instance" "worknode" {
  ami                         = var.ami_value           # Change to your desired AMI ID
  instance_type               = var.instance_type_value # Change to your desired instance type
  subnet_id                   = var.private_subnet_id_value_1
  associate_public_ip_address = var.associate_public_ip_address         # Enable a public IP
  key_name                    = var.key_name # Change to your key pair name
  availability_zone           = var.availability_zone_2
  count                       = var.instance_count
  vpc_security_group_ids      = [aws_security_group.worker_node_sg.id]
  iam_instance_profile = aws_iam_instance_profile.worker_node_profile.name  # Attach IAM Role
  # Use the user_data variable
  # user_data = var.user_data

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = "Workernode-${count.index}"
  }
}