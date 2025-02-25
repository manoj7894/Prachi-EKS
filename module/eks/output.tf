output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "security_group_id" {
  value = aws_security_group.EKS_cluster_sg.id
}