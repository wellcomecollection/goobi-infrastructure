module "lambda_s3_trigger_goobi_ep" {
  source            = "git::https://github.com/wellcomecollection/terraform-aws-lambda.git//?ref=v1.2.0"
  name              = "${local.environment_name}-lambda_s3_trigger_goobi_ep"
  runtime           = "python3.9"
  handler           = "s3_trigger_goobi.lambda_handler"
  description       = "lambda to call Goobi API for import after successful S3 upload"
  s3_bucket         = data.aws_s3_object.lambda_s3_trigger_goobi_package.bucket
  s3_key            = data.aws_s3_object.lambda_s3_trigger_goobi_package.key
  s3_object_version = data.aws_s3_object.lambda_s3_trigger_goobi_package.version_id
  timeout           = "60"
  vpc_config = {
    security_group_ids = [
      aws_security_group.interservice.id,
      aws_security_group.service_egress.id,
    ]

    subnet_ids = module.network.private_subnets
  }
  publish     = true
  memory_size = "128"
  environment = {
    variables = {
      API_ENDPOINT     = local.lambda_api_endpoint_ep
      TOKEN            = local.lambda_token_ep
      TEMPLATEID       = local.lambda_templateid_ep
      UPDATETEMPLATEID = local.lambda_updatetemplateid_ep
      HOTFOLDER        = "hotfolder"
    }
  }
}


data "aws_s3_object" "lambda_s3_trigger_goobi_package" {
  bucket = data.aws_s3_bucket.workflow-infra.bucket
  key    = "lambdas/s3_trigger_goobi.zip"
}

resource "aws_lambda_permission" "allow_event_s3_trigger_goobi_stage_ep" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_s3_trigger_goobi_ep.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.workflow-stage-upload.arn
}

module "lambda_s3_trigger_goobi_digitised" {
  source      = "git::https://github.com/wellcomecollection/terraform-aws-lambda.git//?ref=v1.2.0"
  description = "lambda to call Goobi API for import after successful S3 upload"
  name        = "${local.environment_name}_lambda_s3_trigger_goobi_digitised"

  s3_bucket         = data.aws_s3_object.lambda_s3_trigger_goobi_package.bucket
  s3_key            = data.aws_s3_object.lambda_s3_trigger_goobi_package.key
  s3_object_version = data.aws_s3_object.lambda_s3_trigger_goobi_package.version_id

  handler = "s3_trigger_goobi.lambda_handler"
  runtime = "python3.9"
  timeout = "60"
  publish = true

  memory_size = "128"

  environment = {
    variables = {
      API_ENDPOINT     = local.lambda_api_endpoint_digitised
      TOKEN            = local.lambda_token_digitised
      TEMPLATEID       = local.lambda_templateid_digitised
      UPDATETEMPLATEID = local.lambda_updatetemplateid_digitised
      HOTFOLDER        = "hotfolder"
    }
  }

  vpc_config = {
    security_group_ids = [
      aws_security_group.interservice.id,
      aws_security_group.service_egress.id,
    ]

    subnet_ids = module.network.private_subnets
  }
}

resource "aws_lambda_permission" "allow_event_s3_trigger_goobi_stage_digitised" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_s3_trigger_goobi_digitised.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.workflow-stage-upload.arn
}
module "lambda_s3_trigger_goobi_video" {
  source      = "git::https://github.com/wellcomecollection/terraform-aws-lambda.git//?ref=v1.2.0"
  description = "lambda to call Goobi API for import after successful S3 upload"
  name        = "${local.environment_name}_lambda_s3_trigger_goobi_video"

  s3_bucket         = data.aws_s3_object.lambda_s3_trigger_goobi_package.bucket
  s3_key            = data.aws_s3_object.lambda_s3_trigger_goobi_package.key
  s3_object_version = data.aws_s3_object.lambda_s3_trigger_goobi_package.version_id

  handler = "s3_trigger_goobi.lambda_handler"
  runtime = "python3.9"
  timeout = "60"
  publish = true

  memory_size = "128"

  environment = {
    variables = {
      API_ENDPOINT     = local.lambda_api_endpoint_video
      TOKEN            = local.lambda_token_video
      TEMPLATEID       = local.lambda_templateid_video
      UPDATETEMPLATEID = local.lambda_updatetemplateid_video
      HOTFOLDER        = "hotfolder"
    }
  }

  vpc_config = {
    security_group_ids = [
      aws_security_group.interservice.id,
      aws_security_group.service_egress.id,
    ]

    subnet_ids = module.network.private_subnets
  }
}

resource "aws_lambda_permission" "allow_event_s3_trigger_goobi_stage_video" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_s3_trigger_goobi_video.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.workflow-stage-upload.arn
}

module "lambda_s3_trigger_goobi_audio" {
  source      = "git::https://github.com/wellcomecollection/terraform-aws-lambda.git//?ref=v1.2.0"
  description = "lambda to call Goobi API for import after successful S3 upload"
  name        = "${local.environment_name}_lambda_s3_trigger_goobi_audio"

  s3_bucket         = data.aws_s3_object.lambda_s3_trigger_goobi_package.bucket
  s3_key            = data.aws_s3_object.lambda_s3_trigger_goobi_package.key
  s3_object_version = data.aws_s3_object.lambda_s3_trigger_goobi_package.version_id

  handler = "s3_trigger_goobi.lambda_handler"
  runtime = "python3.9"
  timeout = "60"
  publish = true

  memory_size = "128"

  environment = {
    variables = {
      API_ENDPOINT     = local.lambda_api_endpoint_audio
      TOKEN            = local.lambda_token_audio
      TEMPLATEID       = local.lambda_templateid_audio
      UPDATETEMPLATEID = local.lambda_updatetemplateid_audio
      HOTFOLDER        = "hotfolder"
    }
  }

  vpc_config = {
    security_group_ids = [
      aws_security_group.interservice.id,
      aws_security_group.service_egress.id,
    ]

    subnet_ids = module.network.private_subnets
  }
}

resource "aws_lambda_permission" "allow_event_s3_trigger_goobi_stage_audio" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_s3_trigger_goobi_audio.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.workflow-stage-upload.arn
}
