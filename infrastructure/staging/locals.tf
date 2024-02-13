locals {
  environment_name    = "workflow-stage"
  db_user_key         = "workflow/stage/rds_username"
  db_password_key     = "workflow/stage/rds_password"
  ia_username_key     = "workflow/ia_username"
  ia_password_key     = "workflow/ia_password"
  account_id_digirati = "653428163053"

  # The following are the AMI IDs for the latest Amazon Linux 2 ECS-optimised AMI
  container_host_ami_id = data.aws_ami.container_host_ami.image_id
  bastion_host_ami_id   = data.aws_ami.bastion_host_ami.image_id
}

data "aws_ami" "container_host_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["weco-amzn2-ecs-optimised-hvm-x86_64*"]
  }
}

data "aws_ami" "bastion_host_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["weco-amzn2-hvm-x86_64*"]
  }
}
