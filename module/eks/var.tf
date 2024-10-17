variable "public_subnet_id_value" {
    description = "value for the subnet_id"
}

variable "private_subnet_id_value" {
    description = "value for the subnet_id"
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