# resource "aws_apprunner_vpc_connector" "frontend_vpc_connector" {
#   vpc_connector_name = "vpc_connector"
#   subnets            = [var.public_subnet_id_value, var.private_subnet_id_value]
#   security_groups    = [var.security_group_id]
# }


/*
# Create Apprunner with ECR public image
resource "aws_apprunner_service" "main" {
  service_name = var.frontend_service_name

  source_configuration {
    image_repository {
      image_identifier      = var.image_identifier
      image_repository_type = var.image_repository_type
      image_configuration {
        port = var.port
      }
    }
    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu    = var.cpu # 1 vCPU
    memory = var.memory # 2 GB RAM
  }

  health_check_configuration {
    path                = "/"          # Health check URL path for the backend
    interval            = 5            # How often to perform the health check (in seconds)
    timeout             = 5            # Timeout for each health check (in seconds)
    healthy_threshold   = 3            # How many successful checks to consider the service healthy
    unhealthy_threshold = 3            # How many failed checks to consider the service unhealthy
    protocol            = "HTTP"       # Give TCP or HTTP no problem
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.frontend_vpc_connector.arn
    }
  }

  tags = {
    Name = "example-apprunner-service"
  }

} */



# To create apprunner with Private ECR image

# Define the IAM role
# resource "aws_iam_role" "frontend_service_role" {
#   name = "MyAppRunnerServiceRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "build.apprunner.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "time_sleep" "waitrolecreate" {
#   depends_on      = [aws_iam_role.frontend_service_role]
#   create_duration = "60s"
# }

# # Define the IAM policy
# resource "aws_iam_policy" "frontend_policy" {
#   name        = "apprunner-policy"
#   description = "IAM policy for AWS App Runner service with ECR, CloudWatch Logs, and Secrets Manager permissions"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetAuthorizationToken",
#           "ecr:BatchGetImage",
#           "ecr:DescribeImages"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:DescribeLogGroups",
#           "logs:DescribeLogStreams"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:ListSecrets",
#           "secretsmanager:DescribeSecret"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach the policy to the IAM role
# resource "aws_iam_role_policy_attachment" "apprunner_service_policy_attachment" {
#   role       = aws_iam_role.frontend_service_role.name
#   policy_arn = aws_iam_policy.frontend_policy.arn
# }

resource "aws_apprunner_service" "frontend" {
  service_name = var.frontend_service_name

  source_configuration {
    image_repository {
      image_configuration {
        port = var.port
      }
      image_identifier      = var.image_identifier
      image_repository_type = var.image_repository_type
    }
    auto_deployments_enabled = true
    authentication_configuration {
      access_role_arn = var.apprunner_service_role_arn
    }
  }

  instance_configuration {
    cpu    = var.cpu # 1 vCPU
    memory = var.memory # 2 GB RAM
  }

  health_check_configuration {
    path                = "/"
    interval            = 5
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"           # Give TCP or HTTP no problem
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = var.apprunner_vpc_connector_arn
    }
  }

  tags = {
    Name = "example-apprunner-service"
  }

}