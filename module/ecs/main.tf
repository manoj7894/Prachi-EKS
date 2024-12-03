# To create policy documenent1
data "aws_iam_policy_document" "assume_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# To create the IAM role1
resource "aws_iam_role" "example" {
  name               = "myECcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_policy" "custom_ecs_execution_policy" {
  name        = "CustomECSTaskExecutionPolicy"
  description = "Custom policy for ECS Task Execution with permissions to access ECR and CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ecr:GetAuthorizationToken"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ecr:BatchGetImage"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ecr:BatchCheckLayerAvailability"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the custom policy to the ECS execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.custom_ecs_execution_policy.arn
}


# To create Load Balancer
resource "aws_alb" "example" {
  name            = "example-alb"
  internal        = false # Set to true if you want an internal ALB
  subnets         = [var.public_subnet_id_value, var.private_subnet_id_value]
  security_groups = [var.security_group_id]
}

# To create Target Group
resource "aws_alb_target_group" "example" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id # Replace with your VPC ID

  # Set the health check configuration
  health_check {
    path                = var.health_check_path # Specify the path for the health check
    interval            = 30                    # Health check interval in seconds
    timeout             = 3                     # Health check timeout in seconds
    healthy_threshold   = 2                     # Number of consecutive successful health checks
    unhealthy_threshold = 2                     # Number of consecutive failed health checks
    protocol            = "HTTP"
    matcher             = "200"
  }
}

# To create load balancer listener
resource "aws_alb_listener" "example" {
  load_balancer_arn = aws_alb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.example.arn
  }
}


# Create an ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = var.aws_ecs_cluster # Specify your cluster name
}

# Define an ECS task definition
resource "aws_ecs_task_definition" "my_task" {
  family                   = var.family
  network_mode             = var.network_mode
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.example.arn

  cpu    = var.fargate_cpu # Specify the CPU units for the task (e.g., "256")
  memory = var.fargate_memory # Specify the memory for the task in MiB (e.g., "512")

  container_definitions = jsonencode([
    {
      "name" : "my-container",
      "image" : "941377114289.dkr.ecr.us-east-1.amazonaws.com/my-docker-repo:latest",
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80
        }
      ],
      "mount_points" : [
        {
          "container_path" : "home/ec2-user/var/lib/docker/volumes",
          "source_volume" : "volume-name"
        }
      ]
    }
  ])
}



# Define the ECS service
resource "aws_ecs_service" "example" {
  name            = var.aws_ecs_service
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  launch_type     = var.launch_type
  desired_count   = 2 # Specify the desired number of tasks means replica

  network_configuration {
    subnets          = [var.public_subnet_id_value, var.private_subnet_id_value]
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.example.arn
    container_name   = "my-container"
    container_port   = 80
  }
  depends_on = [aws_alb_listener.example, data.aws_iam_policy_document.assume_role]
}

# # To launch the cofiguration
# resource "aws_launch_configuration" "example" {
#   name_prefix     = "example-launch-config-"
#   image_id        = var.ami_value  # Change to your desired AMI ID
#   instance_type   = var.instance_type_value       # Change to your desired instance type
#   key_name        = var.key_name            # Change to your key pair name
#   security_groups = [var.security_group_id]
# }

# data "aws_iam_policy_document" "ssm_ec2_connect_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "ec2_ssm_role" {
#   name               = "ecs_instance_ssm_role"
#   assume_role_policy = data.aws_iam_policy_document.ssm_ec2_connect_policy.json
# }

# # Attach AmazonSSMManagedInstanceCore policy to the role
# resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
#   role       = aws_iam_role.ec2_ssm_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# # Attach EC2 Instance Connect Policy (AmazonSSMManagedInstanceCore) for connecting to instances
# resource "aws_iam_role_policy_attachment" "ec2_connect_policy_attachment" {
#   role       = aws_iam_role.ec2_ssm_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # Updated to the correct policy for EC2 SSM access
# }

# # Create IAM instance profile for the EC2 instance role
# resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
#   name = "ecs_instance_profile"
#   role = aws_iam_role.ec2_ssm_role.name
# }

# resource "aws_iam_role_policy_attachment" "ec2_instance_connect" {
#   role       = aws_iam_role.ec2_ssm_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2InstanceConnect"
# }

# Create EC2 launch template with IAM instance profile for SSM access
resource "aws_launch_template" "example" {
  name_prefix   = "example-launch-template-"
  image_id      = var.ami_value              # Change to your desired AMI ID
  instance_type = var.instance_type_value     # Change to your desired instance type
  key_name      = var.key_name               # Your key pair name for SSH access
  
  # iam_instance_profile {
  #   name = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  # }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name                      = "my-ecs-auto-scaling-group"
  max_size                  = 10
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = [var.public_subnet_id_value, var.private_subnet_id_value]

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}



# # create autoscaling
# resource "aws_autoscaling_group" "example" {
#   name                      = "my-ecs-auto-scaling-group"
#   launch_configuration      = aws_launch_template.example.name
#   min_size                  = 1
#   max_size                  = 10
#   desired_capacity          = 1
#   health_check_grace_period = 300
#   health_check_type         = "ELB"
#   vpc_zone_identifier       = [var.public_subnet_id_value, var.private_subnet_id_value]
# }

# To create autoscaling target group
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.my_cluster.name}/${aws_ecs_service.example.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# To create autoscaling policy
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "ecs-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60.0
  }
}