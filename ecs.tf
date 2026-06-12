# ECS Cluster
resource "aws_ecs_cluster" "singingai_cluster" {
  name = "singingai-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "singingai-cluster"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "node_logs" {
  name              = "/ecs/singingai-node"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "python_logs" {
  name              = "/ecs/singingai-python"
  retention_in_days = 7
}

# Security Group for ECS tasks
resource "aws_security_group" "ecs_sg" {
  name        = "singingai-ecs-sg"
  description = "Security group for SingingAI ECS tasks"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Node.js from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Python from Node.js only"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "singingai-ecs-sg"
  }
}

# ── SERVICE DISCOVERY ────────────────────────────────────────────────────────

resource "aws_service_discovery_private_dns_namespace" "singingai" {
  name        = "singingai.local"
  description = "Private DNS namespace for SingingAI internal services"
  vpc         = aws_vpc.vpc.id
}

resource "aws_service_discovery_service" "python" {
  name = "singingai-python"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.singingai.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

# ── NODE.JS TASK DEFINITION ──────────────────────────────────────────────────

resource "aws_ecs_task_definition" "singingai_node" {
  family                   = "singingai-node"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "singingai-node"
    image     = "${aws_ecr_repository.singingai_node.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]

    environment = [
      { name = "NODE_ENV",           value = "production" },
      { name = "PORT",               value = "3000" },
      { name = "PYTHON_BACKEND_URL", value = "http://singingai-python.singingai.local:8000" },
      { name = "NEXTAUTH_URL",       value = "https://singingai.prasadcloud.com" },
      { name = "CALLBACK_URL",       value = "https://singingai.prasadcloud.com/api/auth/google/callback" }
    ]

    secrets = [
      { name = "DATABASE_URL",         valueFrom = "${aws_secretsmanager_secret.singingai_secrets.arn}:DATABASE_URL::" },
      { name = "GROQ_API_KEY",         valueFrom = "${aws_secretsmanager_secret.singingai_secrets.arn}:GROQ_API_KEY::" },
      { name = "GOOGLE_CLIENT_ID",     valueFrom = "${aws_secretsmanager_secret.singingai_secrets.arn}:GOOGLE_CLIENT_ID::" },
      { name = "GOOGLE_CLIENT_SECRET", valueFrom = "${aws_secretsmanager_secret.singingai_secrets.arn}:GOOGLE_CLIENT_SECRET::" },
      { name = "SESSION_SECRET",       valueFrom = "${aws_secretsmanager_secret.singingai_secrets.arn}:SESSION_SECRET::" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/singingai-node"
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "ecs"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "node -e \"require('http').get('http://localhost:3000/api/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))\" || exit 1"]
      interval    = 30
      timeout     = 10
      retries     = 3
      startPeriod = 30
    }
  }])
}

# ── PYTHON TASK DEFINITION ───────────────────────────────────────────────────

resource "aws_ecs_task_definition" "singingai_python" {
  family                   = "singingai-python"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "singingai-python"
    image     = "${aws_ecr_repository.singingai_python.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 8000
      protocol      = "tcp"
    }]

    environment = [
      { name = "PYTHONUNBUFFERED", value = "1" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/singingai-python"
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "ecs"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8000/health')\" || exit 1"]
      interval    = 30
      timeout     = 10
      retries     = 3
      startPeriod = 90
    }
  }])
}

# ── NODE.JS SERVICE ──────────────────────────────────────────────────────────

resource "aws_ecs_service" "singingai_node" {
  name                 = "singingai-node-service"
  cluster              = aws_ecs_cluster.singingai_cluster.id
  task_definition      = aws_ecs_task_definition.singingai_node.arn
  desired_count        = 1
  launch_type          = "FARGATE"
  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.privatesubnet1a-App.id, aws_subnet.privatesubnet1b-App.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_target_group.arn
    container_name   = "singingai-node"
    container_port   = 3000
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_policy,
    aws_lb_listener.https_listener,
    aws_lb_listener.http_listener
  ]

  tags = {
    Name = "singingai-node-service"
  }
}

# ── PYTHON SERVICE ───────────────────────────────────────────────────────────

resource "aws_ecs_service" "singingai_python" {
  name                 = "singingai-python-service"
  cluster              = aws_ecs_cluster.singingai_cluster.id
  task_definition      = aws_ecs_task_definition.singingai_python.arn
  desired_count        = 1
  force_new_deployment = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 4
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  network_configuration {
    subnets          = [aws_subnet.privatesubnet1a-App.id, aws_subnet.privatesubnet1b-App.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.python.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_policy
  ]

  tags = {
    Name = "singingai-python-service"
  }
}

# ── OUTPUTS ──────────────────────────────────────────────────────────────────

output "ecs_cluster_name" {
  value = aws_ecs_cluster.singingai_cluster.name
}

output "python_service_dns" {
  value = "http://singingai-python.singingai.local:8000"
}
