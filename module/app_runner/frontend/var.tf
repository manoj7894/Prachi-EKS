variable "frontend_service_name" {
  default = "frontend-service"
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

variable "security_group_id" {
  description = "Security group ID for EFS"
  type        = string
}

variable "apprunner_service_role_arn" {
  description = "Set up the ARN for Apprunner"
}

variable "apprunner_vpc_connector_arn" {
  description = "VPC Connect with Apprunner"
}