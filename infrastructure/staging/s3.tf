resource "aws_s3_bucket" "workflow-stage-configuration" {
  bucket = "wellcomedigitalworkflow-workflow-stage-configuration"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "workflow-stage-configuration_versioning" {
  bucket = aws_s3_bucket.workflow-stage-configuration.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "workflow-stage-configuration_lifecycle" {
  bucket = aws_s3_bucket.workflow-stage-configuration.id
  rule {
    id     = "expiration"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

resource "aws_s3_bucket" "workflow-stage-data" {
  bucket = "wellcomedigitalworkflow-workflow-stage-data"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "workflow-stage-data_versioning" {
  bucket = aws_s3_bucket.workflow-stage-data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "workflow-stage-data_lifecycle" {
  bucket = aws_s3_bucket.workflow-stage-data.id
  rule {
    id     = "expire_noncurrent_versions"
    status = "Enabled"
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
    noncurrent_version_expiration {
      noncurrent_days = 60
    }
    expiration {
      expired_object_delete_marker = true
    }
  }
  rule {
    id     = "transition_objects_to_standard_ia"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

data "aws_s3_bucket" "workflow-infra" {
  bucket = "wellcomecollection-workflow-infra"
}

resource "aws_s3_bucket" "workflow-export-bagit-stage" {
  bucket = "wellcomecollection-workflow-export-bagit-stage"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id      = "expire_all_objects"
    enabled = true

    expiration {
      days = 10
    }
  }
}

resource "aws_s3_bucket_policy" "workflow-export-bagit-stage-external-access-policy" {
  bucket = aws_s3_bucket.workflow-export-bagit-stage.id
  policy = data.aws_iam_policy_document.allow_external_export-bagit-stage_access.json
}

resource "aws_s3_bucket" "workflow-stage-harvesting-results" {
  bucket = "wellcomecollection-workflow-stage-harvesting-results"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "workflow-stage-harvesting-results_versioning" {
  bucket = aws_s3_bucket.workflow-stage-harvesting-results.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "workflow-stage-harvesting-results_lifecycle" {
  bucket = aws_s3_bucket.workflow-stage-harvesting-results.id

  rule {
    id = "expiration"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

resource "aws_s3_bucket" "workflow-stage-upload" {
  bucket = "wellcomecollection-workflow-stage-upload"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "workflow-stage-upload" {
  bucket = aws_s3_bucket.workflow-stage-upload.id
  policy = data.aws_iam_policy_document.workflow-stage-upload.json
}

data "aws_iam_policy_document" "workflow-stage-upload" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Delete*",
      "s3:Put*",
    ]

    resources = [
      aws_s3_bucket.workflow-stage-upload.arn,
      "${aws_s3_bucket.workflow-stage-upload.arn}/*",
    ]

    principals {
      identifiers = [
        "arn:aws:iam::404315009621:role/digitisation-developer",
      ]

      type = "AWS"
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification_workflow-stage-upload" {
  bucket = aws_s3_bucket.workflow-stage-upload.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_ep.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "editorial/"
    filter_suffix       = ".zip"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_ep.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "editorial/"
    filter_suffix       = ".ZIP"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_digitised.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "digitised/"
    filter_suffix       = ".zip"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_digitised.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "digitised/"
    filter_suffix       = ".ZIP"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".mpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".MPG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".mpeg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".MPEG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".mp4"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".MP4"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".mxf"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".MXF"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".JPG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".jpeg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".JPEG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".pdf"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".PDF"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".zip"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".ZIP"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".JPG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".pdf"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".PDF"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".mp3"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".MP3"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".wav"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_stage_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".WAV"
  }
}

