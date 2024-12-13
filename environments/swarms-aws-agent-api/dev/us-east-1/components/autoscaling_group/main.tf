resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  desired_capacity     = 1
  max_size             = 5
  min_size             = 1

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [local.ec2_subnet_id]

  tags = [
    {
      key                 = "Name"
      value               = local.name
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = local.tags.project
      propagate_at_launch = true
    }
  ]
}
