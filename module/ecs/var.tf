variable "aws_ecs_cluster" {
  description = "Name of the ECS"
}

variable "health_check_path" {
    description = "Health_check"
}

variable "family" {
  description = "Task Definition Name"
}

variable "network_mode" {
  description = "Network Mode"
}

variable "fargate_cpu" {
  type    = string
  description = "CPU_Value"
}

variable "fargate_memory" {
  type    = string
  description = "Memory_Value"
}

variable "ami_value" {
    description = "value for the ami"
}

variable "instance_type_value" {
    description = "value for instance_type"
}

variable "key_name" {
    description = "key_pair value name"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id_value" {
  description = "Public subnet ID for EFS mount target"
  type        = string
}

variable "private_subnet_id_value" {
  description = "Private subnet ID for EFS mount target"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for EFS"
  type        = string
}

variable "aws_ecs_service" {
  description = "Name of the service"
}

variable "launch_type" {
  description = "Type of the service"
}