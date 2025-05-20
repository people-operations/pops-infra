resource "aws_instance" "ec2-public-pops" {
  ami                    = "ami-0e86e20dae9224db8"  # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  associate_public_ip_address = true
  security_groups        = [aws_security_group.sg-public-pops.id]
  iam_instance_profile = "LabInstanceProfile"
  key_name = "key-ec2-public-pops"

  /* Arquivo para configurar a instância pública, por hora nosso projeto não vai utilizar
  provisioner "file" {
    source      = "C:\\eduInovatte\\edu-invtt-tf\\public.sh"
    destination = "/home/ubuntu/public.sh"
  }
  */

  provisioner "file" {
    source      = "C:\\keys\\key-ec2-private-pops.pem"
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
    private_key = file("C:\\keys\\key-ec2-public-pops.pem")
    host        = self.public_ip

    bastion_host        = aws_instance.ec2-public-pops.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("C:\\keys\\key-ec2-public-pops.pem")
  }

  tags = {
    Name = "ec2-public-pops"
  }
}

resource "aws_instance" "ec2-private-pops" {
  ami                    = "ami-0e86e20dae9224db8"  # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  associate_public_ip_address = false
  security_groups        = [aws_security_group.sg-private-pops.id]
  iam_instance_profile = "LabInstanceProfile"
  key_name = "key-ec2-private-pops"

  depends_on = [aws_instance.ec2-public-pops, aws_route_table_association.rt-private-association-pops]

  provisioner "file" {
    source      = "C:\\grupo_pops\\pops-infra\\private.sh"
    destination = "/home/ubuntu/private.sh"
  }

  provisioner "file" {
    source      = "C:\\grupo_pops\\pops-infra\\database"
    destination = "/tmp/database"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("C:\\keys\\key-ec2-private-pops.pem")
    host        = self.private_ip

    bastion_host        = aws_instance.ec2-public-pops.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("C:\\keys\\key-ec2-public-pops.pem")
  }

  tags = {
    Name = "ec2-private-pops"
  }
}

# ======================== Armazenando o IP do MySql no AWS SSM ========================

resource "aws_ssm_parameter" "private_ip" {
  name  = "/config/backend_private_ip"
  type  = "String"
  value = aws_instance.ec2-private-pops.private_ip
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
    private_key = file("C:\\keys\\key-ec2-private-pops.pem")
    host        = aws_instance.ec2-private-pops.private_ip

    bastion_host        = aws_instance.ec2-private-pops.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("C:\\keys\\key-ec2-public-pops.pem")
  }
}
/*
resource "null_resource" "configurar_frontend" {
  depends_on = [aws_instance.ec2-public-pops, aws_instance.ec2-private-pops, null_resource.configurar_bd]

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 ~/.ssh/key-ec2-private-pops.pem",
      "sudo chmod +x /home/ubuntu/public.sh",
      "sudo bash /home/ubuntu/public.sh ${aws_instance.ec2-private-edu-invtt.private_ip}"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.ec2-public-pops.public_ip
    user        = "ubuntu"
    private_key = file("C:\\keys\\key-ec2-public-pops.pem")
  }
}

# ======================== Outputs (para visualizar os IPs) ========================
output "nginx_public_ip" {
  description = "IP Público do Servidor Nginx"
  value       = aws_instance.ec2-public-pops.public_ip
}
*/

output "backend_private_ip" {
  description = "IP Privado do Servidor MySQL"
  value       = aws_instance.ec2-private-pops.private_ip
}

