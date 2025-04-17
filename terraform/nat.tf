resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-pops" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat-pops"
  }
}