#Created a cluster and its capacity provider

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "elastic-container-cluster"
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "elastic-container-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_autoscaling_group.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }
  }

}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}

# Created a task execution role for the ECS tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = "my-ecs-task"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  cpu                = 256
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name      = "nextjs-app"
      image     = "seunworks/react-with-terraform:latest"
      essential = true
      memory    = 512
      cpu       = 256
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }

    }
  ])

}


resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }
  network_configuration {
    subnets         = [for subnet in aws_subnet.elastic_container_subnets : subnet.id if subnet.tags["Name"] == "elastic_container_subnet_public"]
    security_groups = [aws_security_group.elastic_container_security_group.id]
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_alb_target_group.arn
    container_name   = "nextjs-app"
    container_port   = 3000
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }
  depends_on = [aws_autoscaling_group.ecs_autoscaling_group]

}