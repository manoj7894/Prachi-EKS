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