resource "aws_vpc" "vpc-pops" {
  cidr_block = "10.0.0.0/23"

  tags = {
    Name = "vpc-pops"
  }
}