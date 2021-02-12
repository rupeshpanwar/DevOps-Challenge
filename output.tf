output "vpc_id" {
  value = aws_vpc.AAvenue-MainVPC.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "public_subnet_id_1" {
  value = aws_subnet.public_subnets[0].id
}
output "public_subnet_id_4" {
  value = aws_subnet.public_subnets[3].id
}

output "alb_dns" {
  value = aws_elb.webapp_load_balancer.dns_name
}

