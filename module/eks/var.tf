variable "security_group_name" {
  description = "Name of the security group"
}

variable "ec2_security_group_pass" {
  description = "Pass the ec2 security group in EKS cluster"
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "role_name" {
  description = "EKS IAM role"
}

variable "cluster_name" {
  description = "Give the cluster_name"
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

variable "ami_value" {
    description = "value for the ami"
}

variable "instance_type_value" {
    description = "value for instance_type"
}

variable "associate_public_ip_address" {
  description = "Enable the public IP address"
}

variable "availability_zone_2" {
    description = "availablity_zone name"
}

variable "instance_count" {
    description = "count of instances"
}

variable "key_name" {
    description = "key_pair value name"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "volume_size" {
  description = "Size of EBS volume"
}

variable "volume_type" {
  description = "Type of EBS volume"
}

variable "alb_security_name" {
  description = "Load Balancer Security group name"
}

variable "worker_node_sg_name" {
  description = "Worker node Security group name"
}

# variable "instance_tenancy" {
#     description = "The tenancy of the instance (e.g., default, dedicated, host)"
# }