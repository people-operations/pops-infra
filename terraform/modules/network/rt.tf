resource "aws_route_table" "rt-public-pops" {
  vpc_id = aws_vpc.vpc-pops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-pops.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "rt-public-association-pops" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt-public-pops.id
}

resource "aws_route_table" "rt-private-edu-invtt" {
  vpc_id = aws_vpc.vpc-pops.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-pops.id
  }

  tags = {
    Name = "private-route-table"
  }

}

resource "aws_route_table_association" "rt-private-association-pops" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt-private-edu-invtt.id
}