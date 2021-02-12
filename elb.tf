resource "aws_elb" "webapp_load_balancer" {
  name            = "Production-WebApp-LoadBalancer"
  internal        = false
  security_groups = ["${aws_security_group.elb_security_group.id}"]
  subnets = [aws_subnet.public_subnets[0].id,
             aws_subnet.public_subnets[3].id]

  listener {
    instance_port = 80
    instance_protocol = "HTTP"
    lb_port = 80
    lb_protocol = "HTTP"
  }

  health_check {
    healthy_threshold   = 5
    interval            = 30
    target              = "HTTP:80/index.html"
    timeout             = 10
    unhealthy_threshold = 5
  }
}
