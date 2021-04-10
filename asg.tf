resource "aws_launch_template" "asg_template_ec2_t2medium" {
  name_prefix   = "asg_template_ec2_t2medium"
  image_id      = data.aws_ami.ubuntu.id
  // testing t2.micro instance
  instance_type = "t2.micro"
  // and this one is final instance type
  //instance_type = "t2.medium"
  
}

resource "aws_autoscaling_group" "asg_devops" {
  capacity_rebalance  = true
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private_subnet.id]

  launch_template {
    id      = aws_launch_template.asg_template_ec2_t2medium.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "devops_asg_scaling_policy" {
  name                   = "Target CPU Scaling"
  autoscaling_group_name = aws_autoscaling_group.asg_devops.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 45.0
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}