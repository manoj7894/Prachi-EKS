output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "worker_node_security_group_id" {
  value = aws_security_group.worker_node_sg.id
}

output "private_ip" {
  value = aws_instance.worknode[*].private_ip
}