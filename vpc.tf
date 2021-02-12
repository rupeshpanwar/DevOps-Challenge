resource "aws_vpc" "AAvenue-MainVPC" {
  cidr_block            = var.vpc_cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true

  tags = {
    Name = "VPC_TF"
  }

}
resource "aws_internet_gateway" "IGW_AAvenue" {
  vpc_id = aws_vpc.AAvenue-MainVPC.id

  tags = {
    Name = "IGW_AAvenue"
  }
  depends_on = [aws_vpc.AAvenue-MainVPC]
}