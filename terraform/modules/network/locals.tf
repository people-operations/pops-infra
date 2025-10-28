locals {
  public_subnets = {
    a = aws_subnet.public_a.id
    b = aws_subnet.public_b.id
  }
}