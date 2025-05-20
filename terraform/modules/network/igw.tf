resource "aws_internet_gateway" "igw-pops" {
  vpc_id = aws_vpc.vpc-pops.id

  tags = {
    Name = "igw-vpc-edu-invtt"
  }
}