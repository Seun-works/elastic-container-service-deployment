# Created a launch template
resource "aws_launch_template" "elastic_launch_template" {
  name_prefix   = "elastic_container_template"
  image_id      = data.aws_ssm_parameter.ecs_node_ami.value # Used an ecs optimized image from the AWS marketplace
  instance_type = "t3.micro"
  key_name      = "ecslog"
  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo "ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name}" >> /etc/ecs/ecs.config;
    EOF
  )
  vpc_security_group_ids = [aws_security_group.elastic_container_security_group.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_profile.arn
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "elastic_container_instance"
    }
  }

}

#Have to create an instance profile for the ECS instances
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceRole"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_key_pair" "elastic_key_pair" {
  key_name   = "ecslog"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name_prefix = "elastic_container_asg-"
  max_size    = 4
  min_size    = 2
  launch_template {
    id      = aws_launch_template.elastic_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = [for subnet in aws_subnet.elastic_container_subnets : subnet.id if subnet.tags["Name"] == "elastic_container_subnet_public"]
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  # Ensure the ASG is deleted before the launch template
  depends_on = [ aws_internet_gateway.elastic_container_igw ]

}