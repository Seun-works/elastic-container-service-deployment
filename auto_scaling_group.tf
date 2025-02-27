# Created a launch template
resource "aws_launch_template" "elastic_launch_template" {
  name_prefix            = "elastic_container_template"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "ecslog"
  user_data              = filebase64("${path.module}/user_data.sh")
  vpc_security_group_ids = [aws_security_group.elastic_container_security_group.id]

  iam_instance_profile {
    name = "ecsInstanceRole"
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

resource "aws_key_pair" "elastic_key_pair" {
  key_name   = "ecslog"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  desired_capacity = 3
  max_size         = 4
  min_size         = 1
  launch_template {
    id      = aws_launch_template.elastic_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = [for subnet in aws_subnet.elastic_container_subnets : subnet.id if subnet.tags["Name"] == "elastic_container_subnet_public"]
  tag {
    key                 = "Name"
    value               = true
    propagate_at_launch = true
  }

}