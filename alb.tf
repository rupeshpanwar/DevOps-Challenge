
resource "aws_alb" "Application_load_balancer" {
  load_balancer_type = "application"
  name            = "Production-App-LoadBalancer"
  internal        = false
  security_groups = [aws_security_group.elb_security_group.id]

  tags = {
    Name = "App_load_balancer_AAvenue"
  }
  subnets = [aws_subnet.public_subnets[0].id,
              aws_subnet.public_subnets[3].id
  ]
  depends_on = [aws_subnet.public_subnets,
                 aws_security_group.elb_security_group]

}


resource "aws_alb_target_group" "alb_frontend_http" {
  name	= "alb-frontend-http"
  vpc_id	= aws_vpc.AAvenue-MainVPC.id
  port	= "80"
  protocol	= "HTTP"
  health_check {
    path = "/"
    port = "80"
    protocol = "HTTP"
    healthy_threshold = 5
    unhealthy_threshold = 2
    interval = 5
    timeout = 4
    matcher = "200"
  }
  tags = {
    Name = "alb_front_http_AAvenue"
  }
  depends_on = [aws_vpc.AAvenue-MainVPC]
}

resource "aws_alb_target_group_attachment" "targetgroup_alb" {
  target_group_arn = aws_alb_target_group.alb_frontend_http.arn
  count    = length(var.availability_zone)
  port     = 80
  target_id        = element(aws_instance.PublicEC2.*.id, count.index)
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.Application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_frontend_http.arn
  }

  depends_on = [aws_alb.Application_load_balancer,
                aws_alb_target_group.alb_frontend_http
  ]
}
