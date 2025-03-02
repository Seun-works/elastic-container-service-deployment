resource "aws_alb" "application_load_balancer" {
  name               = "elastic-container-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elastic_container_security_group.id]
  subnets            = [for subnet in aws_subnet.elastic_container_subnets : subnet.id if subnet.tags["Name"] == "elastic_container_subnet_public"]
  tags = {
    Name = "elastic_container_alb"
  }

}

resource "aws_alb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_alb_target_group.arn
  }

}

resource "aws_alb_target_group" "ecs_alb_target_group" {
  name        = "elastic-container-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.elastic_container_vpc.id
  target_type = "ip"

  health_check {
    path     = "/"
    protocol = "HTTP"
  }

  tags = {
    Name = "elastic_container_target_group"
  }

}