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

  provisioner "file" {
    source      = var.path_to_public_script
    destination = "/home/ubuntu/public.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /home/ubuntu/public.sh"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
    host        = self.public_ip
  }

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

  provisioner "file" {
    source      = var.path_to_public_data_analysis_script
    destination = "/home/ubuntu/public_data_analysis.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /home/ubuntu/public_data_analysis.sh"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-data-analysis-pops.pem")
    host        = self.public_ip
  }

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

  depends_on = [aws_instance.ec2_public_management]

  provisioner "file" {
    source      = var.path_to_private_script
    destination = "/home/ubuntu/private.sh"
  }

  provisioner "file" {
    source      = var.path_to_database_script
    destination = "/tmp/database"
  }

  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file("${path.root}/keys/key-ec2-private-pops.pem")
    host                = self.private_ip

    bastion_host        = aws_instance.ec2_public_management[0].public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
  }

  tags = {
    Name = "ec2-private-banco-dados"
  }
}

# ======================== Executando o Script de Configuração ========================
/*
resource "null_resource" "configurar_bd" {
  depends_on = [aws_instance.ec2-private-pops]

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/private.sh",
      "sudo bash /home/ubuntu/private.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-private-pops.pem")
    host        = aws_instance.ec2-private-pops.private_ip

    bastion_host        = aws_instance.ec2-public-management-pops.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
  }
}

resource "null_resource" "configurar_data_analysis" {
  depends_on = [aws_instance.ec2-public-data-analysis-pops]

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/public_data_analysis.sh"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.ec2-public-data-analysis-pops.public_ip
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-data-analysis-pops.pem")
  }
}

resource "null_resource" "configurar_frontend" {
  depends_on = [null_resource.configurar_bd]

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 ~/.ssh/key-ec2-private-pops.pem",
      "sudo chmod +x /home/ubuntu/public.sh",
      "sudo bash /home/ubuntu/public.sh ${aws_instance.ec2-private-pops.private_ip}"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.ec2-public-management-pops.public_ip
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
  }
}

# ======================== Outputs (para visualizar os IPs) ========================
output "nginx_public_ip" {
  description = "IP Público do Servidor Nginx"
  value       = aws_instance.ec2-public-management-pops.public_ip
}

output "backend_private_ip" {
  description = "IP Privado do Servidor MySQL"
  value       = aws_instance.ec2-private-pops.private_ip
}

output "data_analysis_public_ip" {
  description = "IP Público do Servidor de Análise de Dados"
  value       = aws_instance.ec2-public-data-analysis-pops.public_ip
}
*/