variable "backend_service_name" {
  default = "backend-service"
}

variable "image_identifier" {
  description = "Give the ECR Repo URL"
}

variable "image_repository_type" {
  description = "Type of ECR"
}

variable "port" {
  description = "Port Number of the application"
}

variable "cpu" {
  description = "CPU value"
}

variable "memory" {
  description = "Memory value"
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