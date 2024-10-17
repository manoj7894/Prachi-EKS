# Create a security group
resource "aws_security_group" "devopsshack_cluster_sg" {
  name_prefix = "EKS-security-group"
  description = "EKS security group"
  vpc_id      = var.vpc_id

  # Define your security group rules as needed
  # For example, allow SSH and HTTP traffic
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access (port 8080) for Jenkins web interface
  ingress {
    description = "EFS access"
    from_port   = 2049
    to_port     = 2049
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
  name               = "eks-cluster-role1"
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
    subnet_ids = [var.public_subnet_id_value, var.private_subnet_id_value]
    security_group_ids = [aws_security_group.devopsshack_cluster_sg.id]
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM role policy attachment for EBS actions
resource "aws_iam_policy" "ebs_policy" {
  name        = "EBSAccessPolicy"
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
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# To attach the policy1 to IAM role2
resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# To attach the policy2 to IAM role2
resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

# To attach the policy3 to IAM role2
resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# # Define the Launch Template for Ubuntu AMI
# resource "aws_launch_template" "ubuntu_template" {
#   name_prefix   = "ubuntu-template"
#   image_id       = var.ubuntu_ami
#   instance_type  = var.instance_type_value
#   key_name       = var.key_name

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "ubuntu-launch-template"
#   }
# }

# To create the Worknodes
resource "aws_eks_node_group" "node_01" {
  cluster_name                = aws_eks_cluster.eks-cluster.name
  node_group_name             = var.workernode_name
  node_role_arn               = aws_iam_role.eks_node_role.arn
  subnet_ids                  = [var.public_subnet_id_value]
  instance_types              = [var.instance_type_value]

  remote_access {
    ec2_ssh_key               = var.key_name
    source_security_group_ids = [aws_security_group.devopsshack_cluster_sg.id]
  }


  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  labels = {
    "Name" = "MyWorkerNode"
  }

  tags = {
    "CustomTagKey" = "CustomTagValue"
  }

  capacity_type = "ON_DEMAND"

  #  launch_template {
  #   id      = aws_launch_template.ubuntu_template.id
  #   version = "$Latest"
  # }
}