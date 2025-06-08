resource "aws_key_pair" "public_key" {
  key_name   = var.key_pair_name_public
  public_key = file("${path.root}/keys/key-ec2-public-pops.pem.pub")
}

resource "aws_instance" "ec2-public-pops" {
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_public_id
  associate_public_ip_address = true
  security_groups             = [var.sg_public_pops_id]
  iam_instance_profile        = "LabInstanceProfile"
  key_name                    = aws_key_pair.public_key.key_name

  provisioner "file" {
    source      = var.path_to_public_script
    destination = "/home/ubuntu/public.sh"
  }

  provisioner "file" {
    source      = "${path.root}/keys/key-ec2-private-pops.pem"
    destination = "/home/ubuntu/.ssh/key-ec2-private-pops.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/.ssh/key-ec2-private-pops.pem"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-public-pops.pem")
    host        = self.public_ip

    bastion_host        = aws_instance.ec2-public-pops.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("${path.root}/keys/key-ec2-public-pops.pem")
  }

  tags = {
    Name = "ec2-public-pops"
  }
}

resource "aws_key_pair" "private_key" {
  key_name   = var.key_pair_name_private
  public_key = file("${path.root}/keys/key-ec2-private-pops.pem.pub")
}

resource "aws_instance" "ec2-private-pops" {
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_private_id
  associate_public_ip_address = false
  security_groups             = [var.sg_private_pops_id]
  iam_instance_profile        = "LabInstanceProfile"
  key_name                    = aws_key_pair.private_key.key_name

  depends_on = [aws_instance.ec2-public-pops]

  /*
  provisioner "file" {
    source      = var.path_to_private_script
    destination = "/home/ubuntu/private.sh"
  }

  provisioner "file" {
    source      = var.path_to_database_script
    destination = "/tmp/database"
  }


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("../../../keys/key-ec2-private-pops.pem")
    host        = self.private_ip

    bastion_host        = aws_instance.ec2-public-pops.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("../../../keys/key-ec2-public-pops.pem")
  }
  */

  tags = {
    Name = "ec2-private-pops"
  }
}

# ======================== Executando o Script de Configuração ========================
/*
resource "null_resource" "configurar_bd" {
  depends_on = [aws_instance.ec2-public-pops, aws_instance.ec2-private-pops]

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/private.sh",
      "sudo bash /home/ubuntu/private.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("../../../keys/key-ec2-private-pops.pem")
    host        = aws_instance.ec2-private-pops.private_ip

    bastion_host        = aws_instance.ec2-public-pops.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("../../../keys/key-ec2-public-pops.pem")
  }
}
*/

resource "null_resource" "configurar_frontend" {
  depends_on = [aws_instance.ec2-public-pops, aws_instance.ec2-private-pops]

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 ~/.ssh/key-ec2-private-pops.pem",
      "sudo chmod +x /home/ubuntu/public.sh",
      "sudo bash /home/ubuntu/public.sh"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.ec2-public-pops.public_ip
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-public-pops.pem")
  }
}

# ======================== Outputs (para visualizar os IPs) ========================
output "nginx_public_ip" {
  description = "IP Público do Servidor Nginx"
  value       = aws_instance.ec2-public-pops.public_ip
}

/*
output "backend_private_ip" {
  description = "IP Privado do Servidor MySQL"
  value       = aws_instance.ec2-private-pops.private_ip
}
*/
