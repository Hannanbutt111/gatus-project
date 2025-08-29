resource "aws_ecs_cluster" "memos_cluster" {
  name = "memos-cluster"
}

resource "aws_ecs_task_definition" "memos_task" {
  family                   = "memos-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "memos-container"
      image     = var.ecr_image_url
      essential = true
      portMappings = [
        {
          containerPort = 5230
          hostPort      = 5230
        }
      ]
    }
  ])
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_service_sg" {
  vpc_id = var.vpc_id
  name   = "ecs-service-sg"

  ingress {
    from_port        = 5230
    to_port          = 5230
    protocol         = "tcp"
    security_groups  = [var.alb_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "memos_service" {
  name            = "memos-service"
  cluster         = aws_ecs_cluster.memos_cluster.id
  task_definition = aws_ecs_task_definition.memos_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_arn
    container_name   = "memos-container"
    container_port   = 5230
  }
}
