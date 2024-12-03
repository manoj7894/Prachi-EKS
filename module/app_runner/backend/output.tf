output "security_group_id" {
  value = aws_security_group.app_runner_security_group.id
}

output "apprunner_service_role_arn" {
  description = "The ARN of the App Runner service role"
  value       = aws_iam_role.apprunner_service_role.arn
}

output "apprunner_vpc_connector_arn" {
  description = "The ARN of the App Runner VPC connector"
  value       = aws_apprunner_vpc_connector.vpc_connector.arn
}