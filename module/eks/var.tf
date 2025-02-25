variable "security_group_name" {
  description = "Name of the security group"
}

variable "ec2_security_group_pass" {
  description = "Pass the ec2 security group in EKS cluster"
}

# variable "vpc_cidr_block" {
#   description = "The CIDR block of the VPC"
#   type        = string
# }

variable "role_name" {
  description = "EKS IAM role"
}

variable "private_subnet_id_value_1" {
    description = "value for the subnet_id"
}

variable "private_subnet_id_value_2" {
    description = "value for the subnet_id"
}

variable "worker_node_role" {
  description = "WorkerNode IAM role"
}

variable "ebs_policy" {
  description = "EBS policy name"
}

variable "instance_type_value" {
    description = "value for instance_type"
}

variable "cluster_name" {
  description = "Give the cluster_name"
}

variable "workernode_name" {
  description = "Give the workernode_name"
}

variable "key_name" {
    description = "key_pair value name"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

# variable "ubuntu_ami" {
#   description = "value of ubuntu AMI_id"
# }