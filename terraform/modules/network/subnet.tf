resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc-pops.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.vpc-pops.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.vpc-pops.id
  cidr_block        = "10.0.1.0/25"
  availability_zone = "us-east-1c"

  tags = {
    Name = "private-subnet-c"
  }
}
