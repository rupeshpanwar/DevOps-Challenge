resource "aws_launch_configuration" "ec2_public_launch_configuration" {
  image_id                    = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups             = [
    aws_security_group.ec2_public_security_group.id]

}
resource "aws_autoscaling_group" "ec2_public_autoscaling_group" {
  name                  = "Production-WebApp-AutoScalingGroup"
  vpc_zone_identifier   = aws_subnet.public_subnets.*.id
  max_size              = var.max_instance_size
  min_size              = var.min_instance_size
  launch_configuration  = aws_launch_configuration.ec2_public_launch_configuration.name
  health_check_type     = "ELB"
  load_balancers        = [
    aws_elb.webapp_load_balancer.name]

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "WebApp-EC2-Instance"
  }

  tag {
    key                 = "Type"
    propagate_at_launch = false
    value               = "WebApp"
  }
}

resource "aws_autoscaling_policy" "webapp_production_scaling_policy" {
  autoscaling_group_name    = aws_autoscaling_group.ec2_public_autoscaling_group.name
  name                      = "Production-WebApp-AutoScaling-Policy"
  policy_type               = "TargetTrackingScaling"
  min_adjustment_magnitude  = 1

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}