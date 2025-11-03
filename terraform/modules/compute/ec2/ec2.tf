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

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /opt/pops/keys
              chown ubuntu:ubuntu /opt/pops/keys
              EOF

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/pops/keys",
      "sudo chown ubuntu:ubuntu /opt/pops/keys"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = var.path_to_public_script
    destination = "/home/ubuntu/public.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.root}/keys/pops-srv-employee-firebase-adminsdk-fbsvc-e86c8fbf1b.json"
    destination = "/opt/pops/keys/pops-srv-employee-firebase-adminsdk-fbsvc-e86c8fbf1b.json"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = var.path_to_backend_script
    destination = "/home/ubuntu/backend.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.root}/keys/key-ec2-private-pops.pem"
    destination = "/home/ubuntu/.ssh/key-ec2-private-pops.pem"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/public.sh",
      "chmod +x /home/ubuntu/backend.sh",
      "chmod 400 /home/ubuntu/.ssh/key-ec2-private-pops.pem"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
      host        = self.public_ip
    }
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

  provisioner "file" {
    source      = var.path_to_grafana_script
    destination = "/home/ubuntu/grafana.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /home/ubuntu/public_data_analysis.sh",
      "chmod +x /home/ubuntu/grafana.sh"]
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
    destination = "/tmp/script.sql"
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

resource "null_resource" "configurar_data_analysis" {
  depends_on = [aws_instance.ec2_public_analysis]

  count = length(aws_instance.ec2_public_analysis)

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/public_data_analysis.sh",
      "sudo bash /home/ubuntu/grafana.sh"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.ec2_public_analysis[count.index].public_ip
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-data-analysis-pops.pem")
  }
}

resource "null_resource" "configurar_frontend" {
  depends_on = [
    aws_instance.ec2_public_management,
    aws_instance.ec2_private
  ]
  count = length(aws_instance.ec2_public_management)

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 ~/.ssh/key-ec2-private-pops.pem",
      "sudo chmod +x /home/ubuntu/public.sh",
      "sudo chmod +x /home/ubuntu/backend.sh"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.ec2_public_management[count.index].public_ip
    user        = "ubuntu"
    private_key = file("${path.root}/keys/key-ec2-public-management-pops.pem")
  }
}