data "aws_s3_bucket_object" "lambda_s3_trigger_goobi_package" {
  bucket = data.aws_s3_bucket.workflow-infra.bucket
  key    = "lambdas/s3_trigger_goobi.zip"
}

resource "aws_lambda_function" "lambda_s3_trigger_goobi_stage_ep" {
  description   = "lambda to call Goobi API for import after successful S3 upload"
  function_name = "s3_trigger_goobi_stage_ep"

  s3_bucket         = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.bucket
  s3_key            = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.key
  s3_object_version = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.version_id

  role    = aws_iam_role.lambda_stage_iam_role.arn
  handler = "s3_trigger_goobi.lambda_handler"
  runtime = "python3.9"
  timeout = "60"
  publish = true

  memory_size = "128"

  environment {
    variables = {
      API_ENDPOINT     = local.lambda_api_endpoint_ep
      TOKEN            = local.lambda_token_ep
      TEMPLATEID       = local.lambda_templateid_ep
      UPDATETEMPLATEID = local.lambda_updatetemplateid_ep
      HOTFOLDER        = "hotfolder"
    }
  }

  vpc_config {
    security_group_ids = [
      aws_security_group.interservice.id,
      aws_security_group.service_egress.id,
    ]

    subnet_ids = module.network.private_subnets
  }
}

resource "aws_lambda_permission" "allow_event_s3_trigger_goobi_stage_ep" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_s3_trigger_goobi_stage_ep.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.workflow-stage-upload.arn
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_s3_trigger_goobi_stage_ep" {
  name = "/aws/lambda/s3_trigger_goobi_stage_ep"

  retention_in_days = "14"
}

resource "aws_lambda_function" "lambda_s3_trigger_goobi_stage_digitised" {
  description   = "lambda to call Goobi API for import after successful S3 upload"
  function_name = "s3_trigger_goobi_stage_digitised"

  s3_bucket         = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.bucket
  s3_key            = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.key
  s3_object_version = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.version_id

  role    = aws_iam_role.lambda_stage_iam_role.arn
  handler = "s3_trigger_goobi.lambda_handler"
  runtime = "python3.9"
  timeout = "60"
  publish = true

  memory_size = "128"

  environment {
    variables = {
      API_ENDPOINT     = local.lambda_api_endpoint_digitised
      TOKEN            = local.lambda_token_digitised
      TEMPLATEID       = local.lambda_templateid_digitised
      UPDATETEMPLATEID = local.lambda_updatetemplateid_digitised
      HOTFOLDER        = "hotfolder"
    }
  }

  vpc_config {
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
  function_name = aws_lambda_function.lambda_s3_trigger_goobi_stage_digitised.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.workflow-stage-upload.arn
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_s3_trigger_goobi_stage_digitised" {
  name = "/aws/lambda/s3_trigger_goobi_stage_digitised"

  retention_in_days = "14"
}

resource "aws_lambda_function" "lambda_s3_trigger_goobi_stage_video" {
  description   = "lambda to call Goobi API for import after successful S3 upload"
  function_name = "s3_trigger_goobi_stage_video"

  s3_bucket         = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.bucket
  s3_key            = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.key
  s3_object_version = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.version_id

  role    = aws_iam_role.lambda_stage_iam_role.arn
  handler = "s3_trigger_goobi.lambda_handler"
  runtime = "python3.9"
  timeout = "60"
  publish = true

  memory_size = "128"

  environment {
    variables = {
      API_ENDPOINT     = local.lambda_api_endpoint_video
      TOKEN            = local.lambda_token_video
      TEMPLATEID       = local.lambda_templateid_video
      UPDATETEMPLATEID = local.lambda_updatetemplateid_video
      HOTFOLDER        = "hotfolder"
    }
  }

  vpc_config {
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
  function_name = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.workflow-stage-upload.arn
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_s3_trigger_goobi_stage_video" {
  name = "/aws/lambda/s3_trigger_goobi_stage_video"

  retention_in_days = "14"
}

resource "aws_lambda_function" "lambda_s3_trigger_goobi_stage_audio" {
  description   = "lambda to call Goobi API for import after successful S3 upload"
  function_name = "s3_trigger_goobi_stage_audio"

  s3_bucket         = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.bucket
  s3_key            = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.key
  s3_object_version = data.aws_s3_bucket_object.lambda_s3_trigger_goobi_package.version_id

  role    = aws_iam_role.lambda_stage_iam_role.arn
  handler = "s3_trigger_goobi.lambda_handler"
  runtime = "python3.9"
  timeout = "60"
  publish = true

  memory_size = "128"

  environment {
    variables = {
      API_ENDPOINT     = local.lambda_api_endpoint_audio
      TOKEN            = local.lambda_token_audio
      TEMPLATEID       = local.lambda_templateid_audio
      UPDATETEMPLATEID = local.lambda_updatetemplateid_audio
      HOTFOLDER        = "hotfolder"
    }
  }

  vpc_config {
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
  function_name = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.workflow-stage-upload.arn
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_s3_trigger_goobi_stage_audio" {
  name = "/aws/lambda/s3_trigger_goobi_stage_audio"

  retention_in_days = "14"
}