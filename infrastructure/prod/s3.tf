resource "aws_s3_bucket" "workflow-configuration" {
  bucket = "wellcomedigitalworkflow-workflow-configuration"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }

    expiration {
      expired_object_delete_marker = true
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "workflow-data" {
  bucket = "wellcomedigitalworkflow-workflow-data"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire_noncurrent_versions"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    noncurrent_version_expiration {
      days = 60
    }
    expiration {
      expired_object_delete_marker = true
    }
  }

  lifecycle_rule {
    id      = "transition_objects_to_standard_ia"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket" "workflow-infra" {
  bucket = "wellcomecollection-workflow-infra"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 60
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

resource "aws_s3_bucket" "workflow-export-bagit" {
  bucket = "wellcomecollection-workflow-export-bagit"
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

resource "aws_s3_bucket_policy" "workflow-export-bagit-external-access-policy" {
  bucket = aws_s3_bucket.workflow-export-bagit.id
  policy = data.aws_iam_policy_document.allow_external_export-bagit_access.json
}

resource "aws_s3_bucket" "workflow-harvesting-results" {
  bucket = "wellcomecollection-workflow-harvesting-results"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

resource "aws_s3_bucket" "workflow-upload" {
  bucket = "wellcomecollection-workflow-upload"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "workflow-upload" {
  bucket = aws_s3_bucket.workflow-upload.id
  policy = data.aws_iam_policy_document.workflow-upload.json
}

data "aws_iam_policy_document" "workflow-upload" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Delete*",
      "s3:Put*",
    ]

    resources = [
      aws_s3_bucket.workflow-upload.arn,
      "${aws_s3_bucket.workflow-upload.arn}/*",
    ]

    principals {
      identifiers = [
        "arn:aws:iam::404315009621:role/digitisation-developer",
      ]

      type = "AWS"
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification_workflow-upload" {
  bucket = aws_s3_bucket.workflow-upload.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_ep.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "editorial/"
    filter_suffix       = ".zip"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_ep.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "editorial/"
    filter_suffix       = ".ZIP"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_digitised.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "digitised/"
    filter_suffix       = ".zip"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_digitised.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "digitised/"
    filter_suffix       = ".ZIP"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".mpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".MPG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".mpeg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".MPEG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".mp4"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".MP4"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".mxf"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".MXF"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".JPG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".jpeg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".JPEG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".pdf"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".PDF"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".zip"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "video/"
    filter_suffix       = ".ZIP"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".JPG"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".pdf"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".PDF"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".mp3"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".MP3"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".wav"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_trigger_goobi_audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audio/"
    filter_suffix       = ".WAV"
  }
}
