resource "aws_eip" "nat_eip_a" {
  vpc = true
}

resource "aws_nat_gateway" "nat_pops_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "nat-pops-a"
  }
}

resource "aws_eip" "nat_eip_b" {
  vpc = true
}

resource "aws_nat_gateway" "nat_pops_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name = "nat-pops-b"
  }
}