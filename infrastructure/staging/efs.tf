module "efs" {
  source = "../modules/efs"

  name = "workflow-stage"

  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = "5"

  vpc_id  = module.network.vpc_id
  subnets = module.network.private_subnets

  num_subnets = length(module.network.private_subnets)

  efs_access_security_group_ids = [aws_security_group.efs.id]
}

module "efs-workernode" {
  source = "../modules/efs"

  name = "workflow-stage-workernode-storage"

  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = "20"

  vpc_id  = module.network.vpc_id
  subnets = module.network.private_subnets

  num_subnets = length(module.network.private_subnets)

  efs_access_security_group_ids = [aws_security_group.efs.id]
}
