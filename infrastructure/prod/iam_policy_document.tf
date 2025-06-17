data "aws_iam_policy_document" "assume_ec2_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "alb_logs" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::wellcomedigitalworkflow-alb-logs/*",
    ]

    principals {
      identifiers = ["arn:aws:iam::156460612806:root"]
      type        = "AWS"
    }
  }
}

data "aws_iam_policy_document" "s3_read_workflow-configuration" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.workflow-configuration.arn,
      "${aws_s3_bucket.workflow-configuration.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_rw_workflow-data" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.workflow-data.arn,
      "${aws_s3_bucket.workflow-data.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_rw_workflow-export-bagit" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.workflow-export-bagit.arn,
      "${aws_s3_bucket.workflow-export-bagit.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_rw_workflow-harvesting-results" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.workflow-harvesting-results.arn,
      "${aws_s3_bucket.workflow-harvesting-results.arn}/*",
    ]
  }
}

locals {
  bagit_access_principles = [
    "arn:aws:iam::760097843905:root",
    "arn:aws:iam::975596993436:root",
  ]
}

data "aws_iam_policy_document" "allow_external_export-bagit_access" {
  statement {
    actions   = ["s3:GetObject*"]
    resources = [aws_s3_bucket.workflow-export-bagit.arn, "${aws_s3_bucket.workflow-export-bagit.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = local.bagit_access_principles
    }
  }
}

data "aws_iam_policy_document" "s3_workflow-upload" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.workflow-upload.arn,
      "${aws_s3_bucket.workflow-upload.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_editorial_photography_upload_external" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.ep_upload_external_bucket}",
      "arn:aws:s3:::${var.ep_upload_external_bucket}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_editorial_photography_allow_restore" {
  statement {
    actions = [
      "s3:RestoreObject",
    ]

    resources = [
      "arn:aws:s3:::${var.ep_upload_external_bucket}",
      "arn:aws:s3:::${var.ep_upload_external_bucket}/*",
    ]
  }
}

data "aws_iam_policy_document" "assume_lambda_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_vpc_permissions" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "allow_storage_archive_access" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:ListBucket",
    ]

    resources = ["arn:aws:s3:::${var.storage_archive_bucket}", "arn:aws:s3:::${var.storage_archive_bucket}/*"]
  }
}

