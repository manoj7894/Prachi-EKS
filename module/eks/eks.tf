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
    security_group_ids = [var.security_group_id]
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
    source_security_group_ids = [var.security_group_id]
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