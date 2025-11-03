resource "aws_key_pair" "public_key_management" {
  key_name   = var.key_pair_name_management_public
  public_key = file("${path.root}/keys/key-ec2-public-management-pops.pem.pub")
}

resource "aws_key_pair" "public_key_analysis" {
  key_name   = var.key_pair_name_analysis_public
  public_key = file("${path.root}/keys/key-ec2-data-analysis-pops.pem.pub")
}

resource "aws_key_pair" "private_key" {
  key_name   = var.key_pair_name_private
  public_key = file("${path.root}/keys/key-ec2-private-pops.pem.pub")
}

resource "aws_instance" "ec2_public_management" {
  count                       = length(var.azs)
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnets[count.index]
  associate_public_ip_address = true
  security_groups             = [var.sg_public_management_pops_id]
  iam_instance_profile        = "LabInstanceProfile"
  key_name                    = aws_key_pair.public_key_management.key_name

  tags = {
    Name = "ec2-public-management-${var.azs[count.index]}"
  }
}

resource "aws_instance" "ec2_public_analysis" {
  count                       = length(var.azs)
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnets[count.index]
  associate_public_ip_address = true
  security_groups             = [var.sg_public_analysis_pops_id]
  iam_instance_profile        = "LabInstanceProfile"
  key_name                    = aws_key_pair.public_key_analysis.key_name

  tags = {
    Name = "ec2-public-analysis-${var.azs[count.index]}"
  }
}

resource "aws_instance" "ec2_private" {
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet
  associate_public_ip_address = false
  security_groups             = [var.sg_private_pops_id]
  iam_instance_profile        = "LabInstanceProfile"
  key_name                    = aws_key_pair.private_key.key_name

  tags = {
    Name = "ec2-private-banco-dados"
  }
}
