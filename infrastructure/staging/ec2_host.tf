resource "aws_instance" "access_host" {
  ami           = local.bastion_host_ami_id
  instance_type = var.access_host_instance_type
  key_name      = var.access_host_key_name
  vpc_security_group_ids = [
    aws_security_group.ssh_controlled_ingress.id,
    aws_security_group.efs.id,
    aws_security_group.access_host_full_egress.id
  ]
  subnet_id                   = element(module.network.public_subnets, 0)
  associate_public_ip_address = true
  #   user_data = 

  tags = {
    Name = "goobi-access-host-staging"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_security_group" "ssh_controlled_ingress" {
  description = "controls direct access to application instances"
  vpc_id      = module.network.vpc_id
  name        = "${local.environment_name}_ssh_controlled_ingress_${random_id.sg_append.hex}"

  ingress {
    protocol  = "tcp"
    to_port   = 22
    from_port = 22

    cidr_blocks = local.admin_cidr_ingress
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "access_host_full_egress" {
  description = "allows full gress to access host"
  vpc_id      = module.network.vpc_id
  name        = "${local.environment_name}_access_host_full_egress_${random_id.sg_append.hex}"

  egress {
    protocol  = "-1"
    to_port   = 0
    from_port = 0

    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_id" "sg_append" {
  keepers = {
    sg_id = local.environment_name
  }

  byte_length = 8
}
