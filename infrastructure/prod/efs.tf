module "efs" {
  source = "../modules/efs"

  name = "workflow"

  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = "10"

  vpc_id  = module.network.vpc_id
  subnets = module.network.private_subnets

  num_subnets = length(module.network.private_subnets)

  efs_access_security_group_ids = [aws_security_group.efs.id]
}

module "efs-workernode" {
  source = "../modules/efs"

  name = "workflow-workernode-storage"

  throughput_mode = "provisioned"
  provisioned_throughput_in_mibps = "20"

  vpc_id  = module.network.vpc_id
  subnets = module.network.private_subnets

  num_subnets = length(module.network.private_subnets)

  efs_access_security_group_ids = [aws_security_group.efs.id]
}
