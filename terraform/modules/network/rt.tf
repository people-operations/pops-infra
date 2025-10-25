resource "aws_route_table" "rt_public_pops" {
  vpc_id = aws_vpc.vpc-pops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-pops.id
  }

  tags = {
    Name = "rt-public-pops"
  }
}

resource "aws_route_table_association" "rt_public_association" {
  for_each = {
    a = aws_subnet.public_a.id
    b = aws_subnet.public_b.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.rt_public_pops.id
}

resource "aws_route_table" "rt_private_pops_a" {
  vpc_id = aws_vpc.vpc-pops.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_pops_a.id
  }

  tags = {
    Name = "rt-private-a"
  }
}

resource "aws_route_table" "rt_private_c_primary" {
  vpc_id = aws_vpc.vpc-pops.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_pops_a.id
  }

  tags = {
    Name = "rt-private-c-primary"
  }
}

resource "aws_route_table_association" "rt_private_c_association" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.rt_private_c_primary.id
}

/*
# Route table secundária com NAT da AZ B (failover)
resource "aws_route_table" "rt_private_c_failover" {
  vpc_id = aws_vpc.vpc-pops.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_pops_b.id
  }

  tags = {
    Name = "rt-private-c-failover"
  }
}
 */
