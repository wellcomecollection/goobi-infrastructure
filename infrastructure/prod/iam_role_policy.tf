resource "aws_iam_role_policy" "ecs_goobi_s3_config_read" {
  role   = module.goobi.task_role
  policy = data.aws_iam_policy_document.s3_read_workflow-configuration.json
}

resource "aws_iam_role_policy" "ecs_goobi_s3_data_rw" {
  role   = module.goobi.task_role
  policy = data.aws_iam_policy_document.s3_rw_workflow-data.json
}

resource "aws_iam_role_policy" "ecs_goobi_s3_export_bagit_rw" {
  role   = module.goobi.task_role
  policy = data.aws_iam_policy_document.s3_rw_workflow-export-bagit.json
}

resource "aws_iam_role_policy" "ecs_goobi_s3_upload" {
  role   = module.goobi.task_role
  policy = data.aws_iam_policy_document.s3_workflow-upload.json
}

resource "aws_iam_role_policy" "ecs_goobi_s3_editorial_photography_upload_external" {
  role   = module.goobi.task_role
  policy = data.aws_iam_policy_document.s3_editorial_photography_upload_external.json
}

# Objects written to the editorial photography bucket get lifecycled
# to Glacier after about three months.
#
# If the photographers decide to update the shoot after that, Goobi needs
# to be able to get the XML from Glacier (which includes checksums for the
# previously stored images).
resource "aws_iam_role_policy" "ecs_goobi_s3_editorial_photography_allow_restore" {
  role   = module.goobi.task_role
  policy = data.aws_iam_policy_document.s3_editorial_photography_allow_restore.json
}

resource "aws_iam_role_policy" "ecs_goobi_s3_allow_storage_archive_access" {
  role   = module.goobi.task_role
  policy = data.aws_iam_policy_document.allow_storage_archive_access.json
}

resource "aws_iam_role_policy" "ecs_itm_s3_config_read" {
  role   = module.itm.task_role
  policy = data.aws_iam_policy_document.s3_read_workflow-configuration.json
}

resource "aws_iam_role_policy" "ecs_itm_s3_data_rw" {
  role   = module.itm.task_role
  policy = data.aws_iam_policy_document.s3_rw_workflow-data.json
}

resource "aws_iam_role_policy" "ecs_itm_s3_editorial_photography_upload_external" {
  role   = module.itm.task_role
  policy = data.aws_iam_policy_document.s3_editorial_photography_upload_external.json
}

resource "aws_iam_role_policy" "ecs_harvester_s3_config_read" {
  role   = module.harvester.task_role
  policy = data.aws_iam_policy_document.s3_read_workflow-configuration.json
}

resource "aws_iam_role_policy" "ecs_harvester_s3_rw_workflow-harvesting-results" {
  role   = module.harvester.task_role
  policy = data.aws_iam_policy_document.s3_rw_workflow-harvesting-results.json
}


resource "aws_iam_role_policy" "lambda_s3_upload_rw" {
  name   = "lambda_s3_upload"
  role   = aws_iam_role.lambda_iam_role.name
  policy = data.aws_iam_policy_document.s3_workflow-upload.json
}

resource "aws_iam_role_policy" "lambda_vpc_permissions" {
  role   = aws_iam_role.lambda_iam_role.name
  policy = data.aws_iam_policy_document.lambda_vpc_permissions.json
}

resource "aws_iam_role_policy" "lambda_cloudwatch_permissions" {
  role   = aws_iam_role.lambda_iam_role.name
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

resource "aws_iam_role_policy" "ecs_goobi_read_write_queue" {
  role   = module.goobi.task_role
  policy = module.queues.read_write_policy
}


# worker node
resource "aws_iam_role_policy" "ecs_worker_node_1_s3_config_read" {
  role   = module.worker_node_1.task_role
  policy = data.aws_iam_policy_document.s3_read_workflow-configuration.json
}

resource "aws_iam_role_policy" "ecs_worker_node_1_s3_data_rw" {
  role   = module.worker_node_1.task_role
  policy = data.aws_iam_policy_document.s3_rw_workflow-data.json
}

resource "aws_iam_role_policy" "ecs_worker_node_1_s3_export_bagit_rw" {
  role   = module.worker_node_1.task_role
  policy = data.aws_iam_policy_document.s3_rw_workflow-export-bagit.json
}

resource "aws_iam_role_policy" "ecs_worker_node_1_s3_storage_archive_access" {
  role   = module.worker_node_1.task_role
  policy = data.aws_iam_policy_document.allow_storage_archive_access.json
}

resource "aws_iam_role_policy" "ecs_worker_node_1_s3_editorial_photography_upload_external" {
  role   = module.worker_node_1.task_role
  policy = data.aws_iam_policy_document.s3_editorial_photography_upload_external.json
}

resource "aws_iam_role_policy" "ecs_worker_node_1_read_write_queue" {
  role   = module.worker_node_1.task_role
  policy = module.queues.read_write_policy
}

# worker node bagit
resource "aws_iam_role_policy" "ecs_worker_node_bagit_read_write_queue" {
  role   = module.worker_node_bagit.task_role
  policy = module.queues.read_write_policy
}

resource "aws_iam_role_policy" "ecs_worker_node_bagit_s3_config_read" {
  role   = module.worker_node_bagit.task_role
  policy = data.aws_iam_policy_document.s3_read_workflow-configuration.json
}

resource "aws_iam_role_policy" "ecs_worker_node_bagit_s3_data_rw" {
  role   = module.worker_node_bagit.task_role
  policy = data.aws_iam_policy_document.s3_rw_workflow-data.json
}

resource "aws_iam_role_policy" "ecs_worker_node_bagit_s3_export_bagit_rw" {
  role   = module.worker_node_bagit.task_role
  policy = data.aws_iam_policy_document.s3_rw_workflow-export-bagit.json
}

resource "aws_iam_role_policy" "ecs_worker_node_bagit_s3_storage_archive_access" {
  role   = module.worker_node_bagit.task_role
  policy = data.aws_iam_policy_document.allow_storage_archive_access.json
}
resource "aws_iam_role_policy" "ecs_worker_node_bagit_cloudwatch_permissions" {
  role   = module.worker_node_bagit.task_role
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}
